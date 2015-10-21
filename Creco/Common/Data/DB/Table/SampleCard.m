//
//  SampleCard.m
//  Creco
//
//  Created by Windward on 15/7/7.
//  Copyright (c) 2015年 Windward. All rights reserved.
//

#import "SampleCard.h"

@implementation SampleCard

+ (BOOL)replaceSampleCostIntoDBWithCode:(NSString *)code
                              card_code:(NSString *)card_code
                       card_master_code:(NSString *)card_master_code
                          calendar_memo:(NSString *)calendar_memo
                                  image:(NSString *)image
                                   date:(NSString *)date
                                   name:(NSString *)name
                                  price:(NSString *)price
                                  color:(NSString *)color
                       card_master_name:(NSString *)card_master_name
{
    NSString *sampleCardSql = [NSString stringWithFormat:@"REPLACE INTO %@ (code, card_code, card_master_code, calendar_memo, image, date, name, price, color, card_master_name) VALUES (?,?,?,?,?,?,?,?,?,?)", kDB_SampleCard];
    BOOL result = [[DB getInstance] executeUpdate:sampleCardSql,
                   code,
                   card_code,
                   card_master_code,
                   calendar_memo,
                   image,
                   date,
                   name,
                   price,
                   color,
                   card_master_name];
    return result;
}

+ (void)replaceSampleCardsIntoDBBy:(NSArray *)sampleCardsArr
{
    [[DB getInstance] beginTransaction];
    BOOL isRollBack = NO;
    @try {
        
        for (NSDictionary *calandarDic in sampleCardsArr)
        {
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            [formatter setDateFormat:@"yyyy-MM-dd"];
            NSDate *costDate = [formatter dateFromString:calandarDic[@"date"]];
            [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
            if (!costDate)
                costDate = [formatter dateFromString:calandarDic[@"date"]];
            NSString *dateStr = [formatter stringFromDate:costDate];
            
            ServerCardObject *serverCarObj = [CardMaster getServerCardObjectByService_code:nil
                                                                       andCard_master_code:calandarDic[@"card_master_code"]];
            
            BOOL result = [SampleCard replaceSampleCostIntoDBWithCode:calandarDic[@"code"]
                                                            card_code:calandarDic[@"card_code"]
                                                     card_master_code:calandarDic[@"card_master_code"]
                                                        calendar_memo:calandarDic[@"calendar_memo"]
                                                                image:calandarDic[@"image"]
                                                                 date:dateStr
                                                                 name:calandarDic[@"name"]
                                                                price:calandarDic[@"price"]
                                                                color:COLOR_DEFAULT_CARD
                                                     card_master_name:serverCarObj.card_master_name];
            
            if (!result)
                TDLog(@"Replace Failed!");
            
            NSString *str = calandarDic[@"image"];
            NSData *data = [[NSData alloc] initWithBase64EncodedString:str options:NSDataBase64DecodingIgnoreUnknownCharacters];
            
            NSString *year = [dateStr substringWithRange:NSMakeRange(0,4)];
            NSString *month = [dateStr substringWithRange:NSMakeRange(5,2)];
            NSString *day = [dateStr substringWithRange:NSMakeRange(8,2)];
            NSString *hour = [dateStr substringWithRange:NSMakeRange(11,2)];
            NSString *minute = [dateStr substringWithRange:NSMakeRange(14,2)];
            NSString *second = [dateStr substringWithRange:NSMakeRange(17,2)];
            NSString *time = [NSString stringWithFormat:@"%@%@%@%@%@%@", year, month, day, hour, minute, second];
            
            NSString *path = [NSString stringWithFormat:@"%@/%@%@%@", [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"], time, calandarDic[@"code"], @"_1.jpg"];
            [data writeToFile:path atomically:YES];
        }
    }
    @catch (NSException *exception) {
        isRollBack = YES;
        [[DB getInstance] rollback];
    }
    @finally {
        if (!isRollBack) {
            [[DB getInstance] commit];
        }
    }
}

+ (BOOL)deleteSampleCostInDBByCode:(NSString *)code
{
    NSString *delSampleCardSql = [NSString stringWithFormat:@"DELETE FROM %@ WHERE code = ?", kDB_SampleCard];
    return [[DB getInstance] executeUpdate:delSampleCardSql, code];
}

+ (DetailCostObject *)getDetailCostObjectByCard_code:(NSString *)card_code
{
    FMResultSet *rs = [[DB getInstance] executeQuery:[NSString stringWithFormat:@"SELECT * FROM %@ WHERE card_code = '%@'", kDB_SampleCard, card_code]];
    
    DetailCostObject *detailCostObject = nil;
    if ([rs next])
    {
        NSString *card_code = [rs stringForColumn:@"card_code"];
        NSString *code = [rs stringForColumn:@"code"];
        NSString *picture1 = [rs stringForColumn:@"image"];
        NSString *date = [rs stringForColumn:@"date"];
        NSString *name = [rs stringForColumn:@"name"];
        NSString *price = [rs stringForColumn:@"price"];
        int bestshot = 1;
        
        detailCostObject = [[DetailCostObject alloc] initWithCard_code:card_code
                                                                  code:code
                                                                  date:date
                                                                  name:name
                                                                  note:nil
                                                                 owner:nil
                                                                payday:nil
                                                                 price:price
                                                               disable:nil
                                                              picture1:picture1
                                                              picture2:nil
                                                              picture3:nil
                                                              bestshot:bestshot];
    }
    [rs close];
    return detailCostObject;
}

+ (UserCardObject *)getUserCardObjectByCard_code:(NSString *)card_code
{
    FMResultSet *rs = [[DB getInstance] executeQuery:[NSString stringWithFormat:@"SELECT * FROM %@ WHERE card_code = '%@'", kDB_SampleCard, card_code]];
    
    UserCardObject *userCardObject = nil;
    if ([rs next])
    {
        NSString *card_code = [rs stringForColumn:@"card_code"];
        NSString *card_name = [rs stringForColumn:@"card_master_name"];
        NSString *memo = [rs stringForColumn:@"calendar_memo"];
        NSString *color = [rs stringForColumn:@"color"];
        
        userCardObject = [[UserCardObject alloc] initWithService_code:nil
                                                            card_code:card_code
                                                            card_name:card_name
                                                                 memo:memo
                                                                color:color
                                                             card_seq:0];
    }
    [rs close];
    return userCardObject;
}

+ (NSMutableArray *)getAllSampleCards
{
    FMResultSet *rs = [[DB getInstance] executeQuery:[NSString stringWithFormat:@"SELECT * FROM %@", kDB_SampleCard]];
    
    NSMutableArray *allSampleCardsArr = [NSMutableArray array];
    while ([rs next])
    {
        NSString *card_code = [rs stringForColumn:@"card_code"];
        NSString *card_name = [rs stringForColumn:@"card_master_name"];
        NSString *memo = [rs stringForColumn:@"calendar_memo"];
        NSString *color = [rs stringForColumn:@"color"];
        
        UserCardObject *userCardObject = [[UserCardObject alloc] initWithService_code:nil
                                                                            card_code:card_code
                                                                            card_name:card_name
                                                                                 memo:memo
                                                                                color:color
                                                                             card_seq:0];
        [allSampleCardsArr addObject:userCardObject];
    }
    [rs close];
    
    NSMutableArray *deduplicateSampleCardsArray = [NSMutableArray array];
    for (int i = 0; i < allSampleCardsArr.count; i ++)
    {
        DetailCostObject *detailCostObj = allSampleCardsArr[i];
        
        BOOL hasSame = NO;
        for (DetailCostObject *deduplicateCostObj in deduplicateSampleCardsArray)
        {
            if ([detailCostObj.card_code isEqualToString:deduplicateCostObj.card_code]) {
                hasSame = YES;
                break;
            }
        }
        
        if (!hasSame)
            [deduplicateSampleCardsArray addObject:detailCostObj];
    }

    return deduplicateSampleCardsArray;
}

+ (NSMutableArray *)getAllSampleCosts
{
    FMResultSet *rs = [[DB getInstance] executeQuery:[NSString stringWithFormat:@"SELECT * FROM %@ ORDER BY date DESC, code DESC", kDB_SampleCard]];
    
    NSMutableArray *allSampleCostsArr = [NSMutableArray array];
    while ([rs next])
    {
        NSString *card_code = [rs stringForColumn:@"card_code"];
        if (![card_code isEqualToString:kAllCardCode]) {
            NSString *code = [rs stringForColumn:@"code"];
            NSString *picture1 = [rs stringForColumn:@"image"];
            NSString *date = [rs stringForColumn:@"date"];
            NSString *name = [rs stringForColumn:@"name"];
            NSString *price = [rs stringForColumn:@"price"];
            int bestshot = 1;
            
            DetailCostObject *detailCostObject = [[DetailCostObject alloc] initWithCard_code:card_code
                                                                                        code:code
                                                                                        date:date
                                                                                        name:name
                                                                                        note:nil
                                                                                       owner:nil
                                                                                      payday:nil
                                                                                       price:price
                                                                                     disable:nil
                                                                                    picture1:picture1
                                                                                    picture2:nil
                                                                                    picture3:nil
                                                                                    bestshot:bestshot];
            [allSampleCostsArr addObject:detailCostObject];
        }
    }
    [rs close];
    return allSampleCostsArr;
}

+ (NSMutableArray *)getAllSampleCostsOrderBy
{
    FMResultSet *rs = [[DB getInstance] executeQuery:[NSString stringWithFormat:@"SELECT * FROM %@ ORDER BY date ASC, code ASC", kDB_SampleCard]];
    
    NSMutableArray *allSampleCostsArr = [NSMutableArray array];
    while ([rs next])
    {
        NSString *card_code = [rs stringForColumn:@"card_code"];
        NSString *code = [rs stringForColumn:@"code"];
        NSString *picture1 = [rs stringForColumn:@"image"];
        NSString *date = [rs stringForColumn:@"date"];
        NSString *name = [rs stringForColumn:@"name"];
        NSString *price = [rs stringForColumn:@"price"];
        NSString *memo = [rs stringForColumn:@"calendar_memo"];
        int bestshot = 1;
        
        DetailCostObject *detailCostObject = [[DetailCostObject alloc] initWithCard_code:card_code
                                                                                    code:code
                                                                                    date:date
                                                                                    name:name
                                                                                    note:memo
                                                                                   owner:nil
                                                                                  payday:nil
                                                                                   price:price
                                                                                 disable:nil
                                                                                picture1:picture1
                                                                                picture2:nil
                                                                                picture3:nil
                                                                                bestshot:bestshot];
        [allSampleCostsArr addObject:detailCostObject];
    }
    [rs close];
    return allSampleCostsArr;
}

+ (NSMutableArray *)getSampleCardCostsBy:(NSString *)card_code
{
    FMResultSet *rs = nil;
    if ([card_code isEqualToString:kAllCardCode])
        rs = [[DB getInstance] executeQuery:[NSString stringWithFormat:@"SELECT * FROM %@ ORDER BY date DESC, code DESC", kDB_SampleCard]];
    else
        rs = [[DB getInstance] executeQuery:[NSString stringWithFormat:@"SELECT * FROM %@ WHERE card_code = '%@' ORDER BY date DESC, code DESC", kDB_SampleCard, card_code]];
    
    NSMutableArray *sampleCardCostsArr = [NSMutableArray array];
    while ([rs next])
    {
        NSString *card_code = [rs stringForColumn:@"card_code"];
        if (![card_code isEqualToString:kAllCardCode]) {
            NSString *code = [rs stringForColumn:@"code"];
            NSString *picture1 = [rs stringForColumn:@"image"];
            NSString *date = [rs stringForColumn:@"date"];
            NSString *name = [rs stringForColumn:@"name"];
            NSString *price = [rs stringForColumn:@"price"];
            NSString *memo = [rs stringForColumn:@"calendar_memo"];
            int bestshot = 1;
            
            DetailCostObject *detailCostObject = [[DetailCostObject alloc] initWithCard_code:card_code
                                                                                        code:code
                                                                                        date:date
                                                                                        name:name
                                                                                        note:memo
                                                                                       owner:nil
                                                                                      payday:nil
                                                                                       price:price
                                                                                     disable:nil
                                                                                    picture1:picture1
                                                                                    picture2:nil
                                                                                    picture3:nil
                                                                                    bestshot:bestshot];
            [sampleCardCostsArr addObject:detailCostObject];
        }
    }
    [rs close];
    return sampleCardCostsArr;
}

+ (NSMutableArray *)getSampleCardCostsByASC:(NSString *)card_code
{
    FMResultSet *rs = nil;
    if ([card_code isEqualToString:kAllCardCode])
        rs = [[DB getInstance] executeQuery:[NSString stringWithFormat:@"SELECT * FROM %@ ORDER BY date ASC, code ASC", kDB_SampleCard]];
    else
        rs = [[DB getInstance] executeQuery:[NSString stringWithFormat:@"SELECT * FROM %@ WHERE card_code = '%@' ORDER BY date ASC, code ASC", kDB_SampleCard, card_code]];
    
    NSMutableArray *sampleCardCostsArr = [NSMutableArray array];
    while ([rs next])
    {
        NSString *card_code = [rs stringForColumn:@"card_code"];
        if (![card_code isEqualToString:kAllCardCode]) {
            NSString *code = [rs stringForColumn:@"code"];
            NSString *picture1 = [rs stringForColumn:@"image"];
            NSString *date = [rs stringForColumn:@"date"];
            NSString *name = [rs stringForColumn:@"name"];
            NSString *price = [rs stringForColumn:@"price"];
            NSString *memo = [rs stringForColumn:@"calendar_memo"];
            int bestshot = 1;
            
            DetailCostObject *detailCostObject = [[DetailCostObject alloc] initWithCard_code:card_code
                                                                                        code:code
                                                                                        date:date
                                                                                        name:name
                                                                                        note:memo
                                                                                       owner:nil
                                                                                      payday:nil
                                                                                       price:price
                                                                                     disable:nil
                                                                                    picture1:picture1
                                                                                    picture2:nil
                                                                                    picture3:nil
                                                                                    bestshot:bestshot];
            [sampleCardCostsArr addObject:detailCostObject];
        }
    }
    [rs close];
    return sampleCardCostsArr;
}

+ (NSMutableArray *)getSampleCardCostsByDate:(NSString *)date {
    FMResultSet *rs = [[DB getInstance] executeQuery:[NSString stringWithFormat:@"SELECT * FROM %@ WHERE date LIKE '%@%@'", kDB_SampleCard, date, @"%"]];
    
    NSMutableArray *sampleCardCostsArr = [NSMutableArray array];
    while ([rs next])
    {
        NSString *card_code = [rs stringForColumn:@"card_code"];
        NSString *code = [rs stringForColumn:@"code"];
        NSString *picture1 = [rs stringForColumn:@"image"];
        NSString *date = [rs stringForColumn:@"date"];
        NSString *name = [rs stringForColumn:@"name"];
        NSString *price = [rs stringForColumn:@"price"];
        int bestshot = 1;
        
        DetailCostObject *detailCostObject = [[DetailCostObject alloc] initWithCard_code:card_code
                                                                                    code:code
                                                                                    date:date
                                                                                    name:name
                                                                                    note:nil
                                                                                   owner:nil
                                                                                  payday:nil
                                                                                   price:price
                                                                                 disable:nil
                                                                                picture1:picture1
                                                                                picture2:nil
                                                                                picture3:nil
                                                                                bestshot:bestshot];
        [sampleCardCostsArr addObject:detailCostObject];
    }
    [rs close];
    return sampleCardCostsArr;
}

+ (NSString *)getCardMasterNameBy:(NSString *)card_code
{
    FMResultSet *rs = [[DB getInstance] executeQuery:[NSString stringWithFormat:@"SELECT card_master_name FROM %@ WHERE card_code = '%@'", kDB_SampleCard, card_code]];
    
    NSString *card_name = nil;
    if ([rs next])
    {
        card_name = [rs stringForColumn:@"card_master_name"];
    }
    [rs close];
    return card_name;
}

+ (BOOL)cleanTable
{
    NSString *cleanSampleCardSql = [NSString stringWithFormat:@"DELETE FROM %@", kDB_SampleCard];
    return [[DB getInstance] executeUpdate:cleanSampleCardSql];
}

@end

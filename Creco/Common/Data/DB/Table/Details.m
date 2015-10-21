//
//  Details.m
//  Creco
//
//  Created by Windward on 15/6/23.
//  Copyright (c) 2015年 Windward. All rights reserved.
//

#import "Details.h"

@implementation Details

+ (BOOL)replaceDetailCostIntoDBWithCard_code:(NSString *)card_code
                                        code:(NSString *)code
                                        date:(NSString *)date
                                        name:(NSString *)name
                                        note:(NSString *)note
                                       owner:(NSString *)owner
                                      payday:(NSString *)payday
                                       price:(NSString *)price
                                     disable:(NSString *)disable
                                    picture1:(NSString *)picture1
                                    picture2:(NSString *)picture2
                                    picture3:(NSString *)picture3
                                    bestshot:(int)bestshot
{
    NSString *detailsSql = [NSString stringWithFormat:@"REPLACE INTO %@ (card_code, code, date, name, note, owner, payday, price, disable, picture1, picture2, picture3, bestshot) VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?)", kDB_Details];
    BOOL result = [[DB getInstance] executeUpdate:detailsSql,
                   card_code,
                   code,
                   date,
                   name,
                   note,
                   owner,
                   payday,
                   price,
                   disable,
                   picture1,
                   picture2,
                   picture3,
                   [NSNumber numberWithInt:bestshot]];
    return result;
}

+ (BOOL)replaceDetailCostIntoDBBy:(DetailCostObject *)detailCostObject
{
    return [self replaceDetailCostIntoDBWithCard_code:detailCostObject.card_code
                                                 code:detailCostObject.code
                                                 date:detailCostObject.date
                                                 name:detailCostObject.name
                                                 note:detailCostObject.note
                                                owner:detailCostObject.owner
                                               payday:detailCostObject.payday
                                                price:detailCostObject.price
                                              disable:detailCostObject.disable
                                             picture1:detailCostObject.picture1
                                             picture2:detailCostObject.picture2
                                             picture3:detailCostObject.picture3
                                             bestshot:detailCostObject.bestshot];
}

+ (BOOL)deleteDetailCostInDBByCard_code:(NSString *)card_code andCode:(NSString *)code
{
    NSString *delDetailsSql = [NSString stringWithFormat:@"DELETE FROM %@ WHERE card_code = ? AND code = ?", kDB_Details];
    return [[DB getInstance] executeUpdate:delDetailsSql, card_code, code];
}

+ (BOOL)deleteDetailCostInDBByCard_code:(NSString *)card_code {
    NSString *delDetailsSql = [NSString stringWithFormat:@"DELETE FROM %@ WHERE card_code = ?", kDB_Details];
    return [[DB getInstance] executeUpdate:delDetailsSql, card_code];
}

+ (DetailCostObject *)getDetailCostObjectByCard_code:(NSString *)card_code andCode:(NSString *)code
{
    FMResultSet *rs = [[DB getInstance] executeQuery:[NSString stringWithFormat:@"SELECT * FROM %@ WHERE card_code = '%@' AND code = '%@'", kDB_Details, card_code, code]];
    
    DetailCostObject *detailCostObject = nil;
    if ([rs next])
    {
        NSString *card_code = [rs stringForColumn:@"card_code"];
        NSString *code = [rs stringForColumn:@"code"];
        NSString *date = [rs stringForColumn:@"date"];
        NSString *name = [rs stringForColumn:@"name"];
        NSString *note = [rs stringForColumn:@"note"];
        NSString *owner = [rs stringForColumn:@"owner"];
        NSString *payday = [rs stringForColumn:@"payday"];
        NSString *price = [rs stringForColumn:@"price"];
        NSString *disable = [rs stringForColumn:@"disable"];
        NSString *picture1 = [rs stringForColumn:@"picture1"];
        NSString *picture2 = [rs stringForColumn:@"picture2"];
        NSString *picture3 = [rs stringForColumn:@"picture3"];
        int bestshot = [rs intForColumn:@"bestshot"];
        
        detailCostObject = [[DetailCostObject alloc] initWithCard_code:card_code
                                                                  code:code
                                                                  date:date
                                                                  name:name
                                                                  note:note
                                                                 owner:owner
                                                                payday:payday
                                                                 price:price
                                                               disable:disable
                                                              picture1:picture1
                                                              picture2:picture2
                                                              picture3:picture3
                                                              bestshot:bestshot];
    }
    [rs close];
    return detailCostObject;
}

+ (NSMutableArray *)getAllDetailCosts
{
    FMResultSet *rs = [[DB getInstance] executeQuery:[NSString stringWithFormat:@"SELECT * FROM %@ ORDER BY date DESC, code DESC", kDB_Details]];
    
    NSMutableArray *allDetailCostsArr = [NSMutableArray array];
    while ([rs next])
    {
        NSString *card_code = [rs stringForColumn:@"card_code"];
        NSString *code = [rs stringForColumn:@"code"];
        NSString *date = [rs stringForColumn:@"date"];
        NSString *name = [rs stringForColumn:@"name"];
        NSString *note = [rs stringForColumn:@"note"];
        NSString *owner = [rs stringForColumn:@"owner"];
        NSString *payday = [rs stringForColumn:@"payday"];
        NSString *price = [rs stringForColumn:@"price"];
        NSString *disable = [rs stringForColumn:@"disable"];
        NSString *picture1 = [rs stringForColumn:@"picture1"];
        NSString *picture2 = [rs stringForColumn:@"picture2"];
        NSString *picture3 = [rs stringForColumn:@"picture3"];
        int bestshot = [rs intForColumn:@"bestshot"];
        
        DetailCostObject *detailCostObject = [[DetailCostObject alloc] initWithCard_code:card_code
                                                                                    code:code
                                                                                    date:date
                                                                                    name:name
                                                                                    note:note
                                                                                   owner:owner
                                                                                  payday:payday
                                                                                   price:price
                                                                                 disable:disable
                                                                                picture1:picture1
                                                                                picture2:picture2
                                                                                picture3:picture3
                                                                                bestshot:bestshot];
        [allDetailCostsArr addObject:detailCostObject];
    }
    [rs close];
    return allDetailCostsArr;
}

+ (NSMutableArray *)getAllDetailCostsOrderBy
{
    FMResultSet *rs = [[DB getInstance] executeQuery:[NSString stringWithFormat:@"SELECT * FROM %@ ORDER BY date ASC, code ASC", kDB_Details]];
    
    NSMutableArray *allDetailCostsArr = [NSMutableArray array];
    while ([rs next])
    {
        NSString *card_code = [rs stringForColumn:@"card_code"];
        NSString *code = [rs stringForColumn:@"code"];
        NSString *date = [rs stringForColumn:@"date"];
        NSString *name = [rs stringForColumn:@"name"];
        NSString *note = [rs stringForColumn:@"note"];
        NSString *owner = [rs stringForColumn:@"owner"];
        NSString *payday = [rs stringForColumn:@"payday"];
        NSString *price = [rs stringForColumn:@"price"];
        NSString *disable = [rs stringForColumn:@"disable"];
        NSString *picture1 = [rs stringForColumn:@"picture1"];
        NSString *picture2 = [rs stringForColumn:@"picture2"];
        NSString *picture3 = [rs stringForColumn:@"picture3"];
        int bestshot = [rs intForColumn:@"bestshot"];
        
        DetailCostObject *detailCostObject = [[DetailCostObject alloc] initWithCard_code:card_code
                                                                                    code:code
                                                                                    date:date
                                                                                    name:name
                                                                                    note:note
                                                                                   owner:owner
                                                                                  payday:payday
                                                                                   price:price
                                                                                 disable:disable
                                                                                picture1:picture1
                                                                                picture2:picture2
                                                                                picture3:picture3
                                                                                bestshot:bestshot];
        [allDetailCostsArr addObject:detailCostObject];
    }
    [rs close];
    return allDetailCostsArr;
}


+ (NSMutableArray *)getCardDetailCostsBy:(NSString *)card_code
{
    FMResultSet *rs = [[DB getInstance] executeQuery:[NSString stringWithFormat:@"SELECT * FROM %@ WHERE card_code = '%@' ORDER BY date DESC, code DESC", kDB_Details, card_code]];
    
    NSMutableArray *cardDetailCostsArr = [NSMutableArray array];
    while ([rs next])
    {
        NSString *card_code = [rs stringForColumn:@"card_code"];
        NSString *code = [rs stringForColumn:@"code"];
        NSString *date = [rs stringForColumn:@"date"];
        NSString *name = [rs stringForColumn:@"name"];
        NSString *note = [rs stringForColumn:@"note"];
        NSString *owner = [rs stringForColumn:@"owner"];
        NSString *payday = [rs stringForColumn:@"payday"];
        NSString *price = [rs stringForColumn:@"price"];
        NSString *disable = [rs stringForColumn:@"disable"];
        NSString *picture1 = [rs stringForColumn:@"picture1"];
        NSString *picture2 = [rs stringForColumn:@"picture2"];
        NSString *picture3 = [rs stringForColumn:@"picture3"];
        int bestshot = [rs intForColumn:@"bestshot"];
        
        DetailCostObject *detailCostObject = [[DetailCostObject alloc] initWithCard_code:card_code
                                                                                    code:code
                                                                                    date:date
                                                                                    name:name
                                                                                    note:note
                                                                                   owner:owner
                                                                                  payday:payday
                                                                                   price:price
                                                                                 disable:disable
                                                                                picture1:picture1
                                                                                picture2:picture2
                                                                                picture3:picture3
                                                                                bestshot:bestshot];
        [cardDetailCostsArr addObject:detailCostObject];
    }
    [rs close];
    return cardDetailCostsArr;
}

+ (NSMutableArray *)getCardDetailCostsByASC:(NSString *)card_code
{
    FMResultSet *rs = [[DB getInstance] executeQuery:[NSString stringWithFormat:@"SELECT * FROM %@ WHERE card_code = '%@' ORDER BY date ASC, code ASC", kDB_Details, card_code]];
    
    NSMutableArray *cardDetailCostsArr = [NSMutableArray array];
    while ([rs next])
    {
        NSString *card_code = [rs stringForColumn:@"card_code"];
        NSString *code = [rs stringForColumn:@"code"];
        NSString *date = [rs stringForColumn:@"date"];
        NSString *name = [rs stringForColumn:@"name"];
        NSString *note = [rs stringForColumn:@"note"];
        NSString *owner = [rs stringForColumn:@"owner"];
        NSString *payday = [rs stringForColumn:@"payday"];
        NSString *price = [rs stringForColumn:@"price"];
        NSString *disable = [rs stringForColumn:@"disable"];
        NSString *picture1 = [rs stringForColumn:@"picture1"];
        NSString *picture2 = [rs stringForColumn:@"picture2"];
        NSString *picture3 = [rs stringForColumn:@"picture3"];
        int bestshot = [rs intForColumn:@"bestshot"];
        
        DetailCostObject *detailCostObject = [[DetailCostObject alloc] initWithCard_code:card_code
                                                                                    code:code
                                                                                    date:date
                                                                                    name:name
                                                                                    note:note
                                                                                   owner:owner
                                                                                  payday:payday
                                                                                   price:price
                                                                                 disable:disable
                                                                                picture1:picture1
                                                                                picture2:picture2
                                                                                picture3:picture3
                                                                                bestshot:bestshot];
        [cardDetailCostsArr addObject:detailCostObject];
    }
    [rs close];
    return cardDetailCostsArr;
}

+ (NSMutableArray *)getDetailCostsByDate:(NSString *)date
{
    FMResultSet *rs = [[DB getInstance] executeQuery:[NSString stringWithFormat:@"SELECT * FROM %@ WHERE date LIKE '%@%@'", kDB_Details, date, @"%"]];
    
    NSMutableArray *cardDetailCostsArr = [NSMutableArray array];
    while ([rs next])
    {
        NSString *card_code = [rs stringForColumn:@"card_code"];
        NSString *code = [rs stringForColumn:@"code"];
        NSString *date = [rs stringForColumn:@"date"];
        NSString *name = [rs stringForColumn:@"name"];
        NSString *note = [rs stringForColumn:@"note"];
        NSString *owner = [rs stringForColumn:@"owner"];
        NSString *payday = [rs stringForColumn:@"payday"];
        NSString *price = [rs stringForColumn:@"price"];
        NSString *disable = [rs stringForColumn:@"disable"];
        NSString *picture1 = [rs stringForColumn:@"picture1"];
        NSString *picture2 = [rs stringForColumn:@"picture2"];
        NSString *picture3 = [rs stringForColumn:@"picture3"];
        int bestshot = [rs intForColumn:@"bestshot"];
        
        DetailCostObject *detailCostObject = [[DetailCostObject alloc] initWithCard_code:card_code
                                                                                    code:code
                                                                                    date:date
                                                                                    name:name
                                                                                    note:note
                                                                                   owner:owner
                                                                                  payday:payday
                                                                                   price:price
                                                                                 disable:disable
                                                                                picture1:picture1
                                                                                picture2:picture2
                                                                                picture3:picture3
                                                                                bestshot:bestshot];
        [cardDetailCostsArr addObject:detailCostObject];
    }
    [rs close];
    return cardDetailCostsArr;
}

+ (BOOL)updateDetailCostsByDate:(NSString *)date code:code memo:(NSString *)memo bestShot:(int)bestShot
{
    NSString *entrySql = [NSString stringWithFormat:@"UPDATE %@ SET note = ?, bestshot = ? WHERE date = ? AND code = ?", kDB_Details];
    BOOL result = [[DB getInstance] executeUpdate:entrySql, memo, [NSString stringWithFormat:@"%d", bestShot], date, code];
    return result;
}

+ (BOOL)cleanTable
{
    NSString *cleanDetailsSql = [NSString stringWithFormat:@"DELETE FROM %@", kDB_Details];
    return [[DB getInstance] executeUpdate:cleanDetailsSql];
}

@end

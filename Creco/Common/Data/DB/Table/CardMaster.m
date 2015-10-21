//
//  CardMaster.m
//  Creco
//
//  Created by Windward on 15/6/21.
//  Copyright (c) 2015年 Windward. All rights reserved.
//

#import "CardMaster.h"

@implementation CardMaster

+ (BOOL)replaceServerCardIntoDBWithService_code:(NSString *)service_code
                               card_master_code:(NSString *)card_master_code
                                   service_name:(NSString *)service_name
                               card_master_name:(NSString *)card_master_name
                                    service_url:(NSString *)service_url
                                    description:(NSString *)description
                                additional_auth:(NSString *)additional_auth
                                    maintenance:(NSString *)maintenance
                                       card_seq:(int)card_seq
{
    NSString *cardMasterSql = [NSString stringWithFormat:@"REPLACE INTO %@ (service_code, card_master_code, service_name, card_master_name, service_url, description, additional_auth, maintenance, card_seq) VALUES (?,?,?,?,?,?,?,?,?)", kDB_CardMaster];
    BOOL result = [[DB getInstance] executeUpdate:cardMasterSql,
                   service_code,
                   card_master_code,
                   service_name,
                   card_master_name,
                   service_url,
                   description,
                   additional_auth,
                   maintenance,
                   [NSNumber numberWithInt:card_seq]];
    return result;
}

+ (BOOL)replaceServerCardIntoDBBy:(ServerCardObject *)serverCardObject
{
    return [self replaceServerCardIntoDBWithService_code:serverCardObject.service_code
                                        card_master_code:serverCardObject.card_master_code
                                            service_name:serverCardObject.service_name
                                        card_master_name:serverCardObject.card_master_name
                                             service_url:serverCardObject.service_url
                                             description:serverCardObject.descriptionStr
                                         additional_auth:serverCardObject.additional_auth
                                             maintenance:serverCardObject.maintenance
                                                card_seq:serverCardObject.card_seq];
}

+ (void)replaceServerCardsIntoDBBy:(NSArray *)serverCardObjsArray
{
    [[DB getInstance] beginTransaction];
    BOOL isRollBack = NO;
    @try {
        for (ServerCardObject *serverCardObj in serverCardObjsArray)
        {
            for (NSDictionary *cardDic in serverCardObj.cardsArray)
            {
                serverCardObj.card_master_code = cardDic[@"card_master_code"];
                serverCardObj.card_master_name = cardDic[@"card_master_name"];
                serverCardObj.card_seq = cardDic[@"card_seq"] ? [cardDic[@"card_seq"] intValue] : serverCardObj.card_seq;
                BOOL result = [CardMaster replaceServerCardIntoDBBy:serverCardObj];
                
                if (!result)
                    TDLog(@"Replace Failed!");
            }
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

+ (BOOL)deleteServerCardInDBByService_code:(NSString *)service_code andCard_master_code:(NSString *)card_master_code
{
    NSString *delCardMasterSql = [NSString stringWithFormat:@"DELETE FROM %@ WHERE service_code = ? AND card_master_code = ?", kDB_CardMaster];
    return [[DB getInstance] executeUpdate:delCardMasterSql, service_code, card_master_code];
}

+ (ServerCardObject *)getServerCardObjectByService_code:(NSString *)service_code andCard_master_code:(NSString *)card_master_code
{
    FMResultSet *rs = [[DB getInstance] executeQuery:[NSString stringWithFormat:@"SELECT * FROM %@ WHERE service_code = '%@' AND card_master_code = '%@'", kDB_CardMaster, service_code, card_master_code]];
    if (service_code.length == 0) {
        rs = [[DB getInstance] executeQuery:[NSString stringWithFormat:@"SELECT * FROM %@ WHERE card_master_code = '%@'", kDB_CardMaster, card_master_code]];
    }
    
    ServerCardObject *serverCardObject = nil;
    if ([rs next])
    {
        NSString *service_code = [rs stringForColumn:@"service_code"];
        NSString *card_master_code = [rs stringForColumn:@"card_master_code"];
        NSString *service_name = [rs stringForColumn:@"service_name"];
        NSString *card_master_name = [rs stringForColumn:@"card_master_name"];
        NSString *service_url = [rs stringForColumn:@"service_url"];
        NSString *description = [rs stringForColumn:@"description"];
        NSString *additional_auth = [rs stringForColumn:@"additional_auth"];
        NSString *maintenance = [rs stringForColumn:@"maintenance"];
        int card_seq = [rs intForColumn:@"card_seq"];
        
        serverCardObject = [[ServerCardObject alloc] initWithService_code:service_code
                                                         card_master_code:card_master_code
                                                             service_name:service_name
                                                         card_master_name:card_master_name
                                                              service_url:service_url
                                                              description:description
                                                          additional_auth:additional_auth
                                                              maintenance:maintenance
                                                                 card_seq:card_seq];
    }
    [rs close];
    return serverCardObject;
}

+ (NSMutableArray *)getAllServerCards
{
    FMResultSet *rs = [[DB getInstance] executeQuery:[NSString stringWithFormat:@"SELECT * FROM %@ ORDER BY card_seq ASC", kDB_CardMaster]];
    
    NSMutableArray *allServerCardsArr = [NSMutableArray array];
    while ([rs next])
    {
        NSString *service_code = [rs stringForColumn:@"service_code"];
        NSString *card_master_code = [rs stringForColumn:@"card_master_code"];
        NSString *service_name = [rs stringForColumn:@"service_name"];
        NSString *card_master_name = [rs stringForColumn:@"card_master_name"];
        NSString *service_url = [rs stringForColumn:@"service_url"];
        NSString *description = [rs stringForColumn:@"description"];
        NSString *additional_auth = [rs stringForColumn:@"additional_auth"];
        NSString *maintenance = [rs stringForColumn:@"maintenance"];
        int card_seq = [rs intForColumn:@"card_seq"];
        
        ServerCardObject *serverCardObject = [[ServerCardObject alloc] initWithService_code:service_code
                                                                           card_master_code:card_master_code
                                                                               service_name:service_name
                                                                           card_master_name:card_master_name
                                                                                service_url:service_url
                                                                                description:description
                                                                            additional_auth:additional_auth
                                                                                maintenance:maintenance
                                                                                   card_seq:card_seq];
        if ([card_master_code intValue] >= 0)
            [allServerCardsArr addObject:serverCardObject];
    }
    [rs close];
    return allServerCardsArr;
}

+ (NSMutableArray *)getCardMasterNameByServiceCode:serviceCode {
    FMResultSet *rs = [[DB getInstance] executeQuery:[NSString stringWithFormat:@"SELECT * FROM %@ WHERE service_code = '%@'", kDB_CardMaster, serviceCode]];
    
    NSMutableArray *cardMasterName = [NSMutableArray array];
    while ([rs next])
    {
        NSString *card_master_name = [rs stringForColumn:@"card_master_name"];
        [cardMasterName addObject:card_master_name];
    }
    [rs close];
    return cardMasterName;
}

+ (NSString *)getServiceNameByServiceCode:(NSString *)serviceCode {
    FMResultSet *rs = [[DB getInstance] executeQuery:[NSString stringWithFormat:@"SELECT * FROM %@ WHERE service_code = '%@'", kDB_CardMaster, serviceCode]];
    
    NSString *service_name = @"";
    while ([rs next])
    {
        service_name = [rs stringForColumn:@"service_name"];
    }
    return service_name;
}

+ (BOOL)cleanTable
{
    NSString *cleanCardMasterSql = [NSString stringWithFormat:@"DELETE FROM %@", kDB_CardMaster];
    return [[DB getInstance] executeUpdate:cleanCardMasterSql];
}

@end

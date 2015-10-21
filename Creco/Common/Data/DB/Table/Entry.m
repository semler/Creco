//
//  Entry.m
//  Creco
//
//  Created by Windward on 15/6/21.
//  Copyright (c) 2015年 Windward. All rights reserved.
//

#import "Entry.h"

@implementation Entry

+ (BOOL)replaceUserCardIntoDBWithService_code:(NSString *)service_code
                                    card_code:(NSString *)card_code
                                    card_name:(NSString *)card_name
                                         memo:(NSString *)memo
                                        color:(NSString *)color
                                     card_seq:(int)card_seq
{
    NSString *entrySql = [NSString stringWithFormat:@"REPLACE INTO %@ (service_code, card_code, card_name, memo, color, card_seq) VALUES (?,?,?,?,?,?)", kDB_Entry];
    BOOL result = [[DB getInstance] executeUpdate:entrySql,
                   service_code,
                   card_code,
                   card_name,
                   memo,
                   color,
                   [NSNumber numberWithInt:card_seq]];
    return result;
}

+ (BOOL)replaceUserCardIntoDBBy:(UserCardObject *)userCardObject
{
    return [self replaceUserCardIntoDBWithService_code:userCardObject.service_code
                                             card_code:userCardObject.card_code
                                             card_name:userCardObject.card_name
                                                  memo:userCardObject.memo
                                                 color:userCardObject.color
                                              card_seq:userCardObject.card_seq];
}

+ (BOOL)updateUserCardFromDBWithService_code:(NSString *)service_code
                                   card_code:(NSString *)card_code
                                   card_name:(NSString *)card_name
                                        memo:(NSString *)memo
                                       color:(NSString *)color
                                    card_seq:(int)card_seq
{
    NSString *entrySql = [NSString stringWithFormat:@"UPDATE %@ SET card_name = ?, memo = ?, color = ?, card_seq = ? WHERE service_code = ? AND card_code = ?", kDB_Entry];
    BOOL result = [[DB getInstance] executeUpdate:entrySql,
                   card_name,
                   memo,
                   color,
                   [NSNumber numberWithInt:card_seq],
                   service_code,
                   card_code];
    return result;
}

+ (BOOL)updateUserCardFromDBBy:(UserCardObject *)userCardObject
{
    return [self updateUserCardFromDBWithService_code:userCardObject.service_code
                                            card_code:userCardObject.card_code
                                            card_name:userCardObject.card_name
                                                 memo:userCardObject.memo
                                                color:userCardObject.color
                                             card_seq:userCardObject.card_seq];
}

+ (BOOL)deleteUserCardInDBByService_code:(NSString *)service_code andCard_code:(NSString *)card_code
{
    NSString *delEntrySql = [NSString stringWithFormat:@"DELETE FROM %@ WHERE service_code = ? AND card_code = ?", kDB_Entry];
    return [[DB getInstance] executeUpdate:delEntrySql, service_code, card_code];
}

+ (BOOL)deleteUserCardInDBByService_code:(NSString *)service_code
{
    NSString *delEntrySql = [NSString stringWithFormat:@"DELETE FROM %@ WHERE service_code = ?", kDB_Entry];
    return [[DB getInstance] executeUpdate:delEntrySql, service_code];
}

+ (UserCardObject *)getUserCardObjectByService_code:(NSString *)service_code andCard_code:(NSString *)card_code
{
    FMResultSet *rs = [[DB getInstance] executeQuery:[NSString stringWithFormat:@"SELECT * FROM %@ WHERE service_code = '%@' AND card_code = '%@'", kDB_Entry, service_code, card_code]];
    if (service_code.length == 0)
        rs = [[DB getInstance] executeQuery:[NSString stringWithFormat:@"SELECT * FROM %@ WHERE card_code = '%@'", kDB_Entry, card_code]];
    else if (card_code.length == 0)
        rs = [[DB getInstance] executeQuery:[NSString stringWithFormat:@"SELECT * FROM %@ WHERE service_code = '%@'", kDB_Entry, service_code]];
    
    UserCardObject *userCardObject = nil;
    if ([rs next])
    {
        NSString *service_code = [rs stringForColumn:@"service_code"];
        NSString *card_code = [rs stringForColumn:@"card_code"];
        NSString *card_name = [rs stringForColumn:@"card_name"];
        NSString *memo = [rs stringForColumn:@"memo"];
        NSString *color = [rs stringForColumn:@"color"];
        int card_seq = [rs intForColumn:@"card_seq"];
        
        userCardObject = [[UserCardObject alloc] initWithService_code:service_code
                                                            card_code:card_code
                                                            card_name:card_name
                                                                 memo:memo
                                                                color:color
                                                             card_seq:card_seq];
    }
    [rs close];
    return userCardObject;
}

+ (NSString *)getCardNameByCardCode:(NSString *)card_code {
    FMResultSet *rs = [[DB getInstance] executeQuery:[NSString stringWithFormat:@"SELECT card_name FROM %@ WHERE card_code = '%@'", kDB_Entry, card_code]];
    
    NSString *card_name = nil;
    if ([rs next])
    {
        card_name = [rs stringForColumn:@"card_name"];
    }
    [rs close];
    return card_name;
}

+ (NSMutableArray *)getAllUserCards
{
    FMResultSet *rs = [[DB getInstance] executeQuery:[NSString stringWithFormat:@"SELECT * FROM %@ ORDER BY card_seq ASC", kDB_Entry]];
    
    NSMutableArray *allUserCardsArr = [NSMutableArray array];
    while ([rs next])
    {
        NSString *service_code = [rs stringForColumn:@"service_code"];
        NSString *card_code = [rs stringForColumn:@"card_code"];
        NSString *card_name = [rs stringForColumn:@"card_name"];
        NSString *memo = [rs stringForColumn:@"memo"];
        NSString *color = [rs stringForColumn:@"color"];
        int card_seq = [rs intForColumn:@"card_seq"];
        
        UserCardObject *userCardObject = [[UserCardObject alloc] initWithService_code:service_code
                                                                            card_code:card_code
                                                                            card_name:card_name
                                                                                 memo:memo
                                                                                color:color
                                                                             card_seq:card_seq];
        [allUserCardsArr addObject:userCardObject];
    }
    [rs close];
    return allUserCardsArr;
}

+ (NSMutableArray *)getUserCardsByService_code:(NSString *)service_code {
    FMResultSet *rs = [[DB getInstance] executeQuery:[NSString stringWithFormat:@"SELECT * FROM %@ WHERE service_code = '%@'", kDB_Entry, service_code]];
    
    NSMutableArray *allUserCardsArr = [NSMutableArray array];
    while ([rs next])
    {
        NSString *service_code = [rs stringForColumn:@"service_code"];
        NSString *card_code = [rs stringForColumn:@"card_code"];
        NSString *card_name = [rs stringForColumn:@"card_name"];
        NSString *memo = [rs stringForColumn:@"memo"];
        NSString *color = [rs stringForColumn:@"color"];
        int card_seq = [rs intForColumn:@"card_seq"];
        
        UserCardObject *userCardObject = [[UserCardObject alloc] initWithService_code:service_code
                                                                            card_code:card_code
                                                                            card_name:card_name
                                                                                 memo:memo
                                                                                color:color
                                                                             card_seq:card_seq];
        [allUserCardsArr addObject:userCardObject];
    }
    [rs close];
    return allUserCardsArr;
}

+ (BOOL)updateUserCardByCard_code:(NSString *)card_code seq:(int)seq_code {
    NSString *entrySql = [NSString stringWithFormat:@"UPDATE %@ SET card_seq = ? WHERE card_code = ?", kDB_Entry];
    BOOL result = [[DB getInstance] executeUpdate:entrySql, [NSString stringWithFormat:@"%d", seq_code], card_code];
    return result;
}

+ (BOOL)updateUserCardByCard_code:(NSString *)card_code color:(NSString *)color name:(NSString *)name memo:(NSString *)memo {
    NSString *entrySql = [NSString stringWithFormat:@"UPDATE %@ SET color = ?, card_name = ?, memo = ? WHERE card_code = ?", kDB_Entry];
    BOOL result = [[DB getInstance] executeUpdate:entrySql, color, name, memo, card_code];
    return result;
}

+ (BOOL)updateUserCardSeqByCard_code:(NSString *)card_code Service_code:(NSString *)service_code seq:(int)seq_code {
    NSString *entrySql = [NSString stringWithFormat:@"UPDATE %@ SET card_seq = ? WHERE card_code = ? AND service_code = ?", kDB_Entry];
    BOOL result = [[DB getInstance] executeUpdate:entrySql, [NSString stringWithFormat:@"%d", seq_code], card_code, service_code];
    return result;
}

+ (BOOL)cleanTable
{
    NSString *cleanEntrySql = [NSString stringWithFormat:@"DELETE FROM %@", kDB_Entry];
    return [[DB getInstance] executeUpdate:cleanEntrySql];
}

@end

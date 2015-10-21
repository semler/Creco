//
//  WebId.m
//  Creco
//
//  Created by Windward on 15/7/7.
//  Copyright (c) 2015年 Windward. All rights reserved.
//

#import "WebId.h"

@implementation WebId

+ (BOOL)replaceUserWebIntoDBWithService_code:(NSString *)service_code
                                service_name:(NSString *)service_name
                                 web_id_code:(NSString *)web_id_code
                                   card_code:(NSString *)card_code
                                      web_id:(NSString *)web_id
                       initialization_vector:(NSString *)initialization_vector
                                    password:(NSString *)password
                              detail_get_flg:(BOOL)detail_get_flg
{
    NSString *webIdSql = [NSString stringWithFormat:@"REPLACE INTO %@ (service_code, service_name, web_id_code, card_code, web_id, initialization_vector, password, detail_get_flg) VALUES (?,?,?,?,?,?,?,?)", kDB_WebId];
    BOOL result = [[DB getInstance] executeUpdate:webIdSql,
                   service_code,
                   service_name,
                   web_id_code,
                   card_code,
                   web_id,
                   initialization_vector,
                   password,
                   [NSNumber numberWithBool:detail_get_flg]];
    return result;
}

+ (BOOL)replaceUserWebIntoDBBy:(UserWebObject *)userWebObject
{
    return [self replaceUserWebIntoDBWithService_code:userWebObject.service_code
                                         service_name:userWebObject.service_name
                                          web_id_code:userWebObject.web_id_code
                                            card_code:userWebObject.card_code
                                               web_id:userWebObject.web_id
                                initialization_vector:userWebObject.initialization_vector
                                             password:userWebObject.password
                                       detail_get_flg:userWebObject.detail_get_flg];
}

+ (BOOL)deleteUserWebInDBByService_code:(NSString *)service_code
{
    NSString *delWebIdSql = [NSString stringWithFormat:@"DELETE FROM %@ WHERE service_code  = ?", kDB_WebId];
    return [[DB getInstance] executeUpdate:delWebIdSql, service_code];
}

+ (UserWebObject *)getUserWebObjectByService_code:(NSString *)service_code
{
    FMResultSet *rs = [[DB getInstance] executeQuery:[NSString stringWithFormat:@"SELECT * FROM %@ WHERE service_code = '%@'", kDB_WebId, service_code]];
    
    UserWebObject *userWebObject = nil;
    if ([rs next])
    {
        NSString *service_code = [rs stringForColumn:@"service_code"];
        NSString *service_name = [rs stringForColumn:@"service_name"];
        NSString *web_id_code = [rs stringForColumn:@"web_id_code"];
        NSString *card_code = [rs stringForColumn:@"card_code"];
        NSString *web_id = [rs stringForColumn:@"web_id"];
        NSString *initialization_vector = [rs stringForColumn:@"initialization_vector"];
        NSString *password = [rs stringForColumn:@"password"];
        BOOL detail_get_flg = [rs boolForColumn:@"detail_get_flg"];
        
        userWebObject = [[UserWebObject alloc] initWithService_code:service_code
                                                       service_name:service_name
                                                        web_id_code:web_id_code
                                                          card_code:card_code
                                                             web_id:web_id
                                              initialization_vector:initialization_vector
                                                           password:password
                                                     detail_get_flg:detail_get_flg];
    }
    [rs close];
    return userWebObject;
}

+ (NSMutableArray *)getAllUserWebs
{
    FMResultSet *rs = [[DB getInstance] executeQuery:[NSString stringWithFormat:@"SELECT * FROM %@", kDB_WebId]];
    
    NSMutableArray *allUserWebsArr = [NSMutableArray array];
    while ([rs next])
    {
        NSString *service_code = [rs stringForColumn:@"service_code"];
        NSString *service_name = [rs stringForColumn:@"service_name"];
        NSString *web_id_code = [rs stringForColumn:@"web_id_code"];
        NSString *card_code = [rs stringForColumn:@"card_code"];
        NSString *web_id = [rs stringForColumn:@"web_id"];
        NSString *initialization_vector = [rs stringForColumn:@"initialization_vector"];
        NSString *password = [rs stringForColumn:@"password"];
        BOOL detail_get_flg = [rs boolForColumn:@"detail_get_flg"];
        
        UserWebObject *userWebObject = [[UserWebObject alloc] initWithService_code:service_code
                                                                      service_name:service_name
                                                                       web_id_code:web_id_code
                                                                         card_code:card_code
                                                                            web_id:web_id
                                                             initialization_vector:initialization_vector
                                                                          password:password
                                                                    detail_get_flg:detail_get_flg];
        [allUserWebsArr addObject:userWebObject];
    }
    [rs close];
    return allUserWebsArr;
}

+ (BOOL)cleanTable
{
    NSString *cleanWebIdSql = [NSString stringWithFormat:@"DELETE FROM %@", kDB_WebId];
    return [[DB getInstance] executeUpdate:cleanWebIdSql];
}

@end

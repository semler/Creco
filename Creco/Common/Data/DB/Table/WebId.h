//
//  WebId.h
//  Creco
//
//  Created by Windward on 15/7/7.
//  Copyright (c) 2015年 Windward. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UserWebObject.h"

@interface WebId : NSObject

+ (BOOL)replaceUserWebIntoDBWithService_code:(NSString *)service_code
                                service_name:(NSString *)service_name
                                 web_id_code:(NSString *)web_id_code
                                   card_code:(NSString *)card_code
                                      web_id:(NSString *)web_id
                       initialization_vector:(NSString *)initialization_vector
                                    password:(NSString *)password
                              detail_get_flg:(BOOL)detail_get_flg;
+ (BOOL)replaceUserWebIntoDBBy:(UserWebObject *)userWebObject;

+ (BOOL)deleteUserWebInDBByService_code:(NSString *)service_code;

+ (UserWebObject *)getUserWebObjectByService_code:(NSString *)service_code;

+ (NSMutableArray *)getAllUserWebs;

+ (BOOL)cleanTable;

@end

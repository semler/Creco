//
//  CardMaster.h
//  Creco
//
//  Created by Windward on 15/6/21.
//  Copyright (c) 2015年 Windward. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ServerCardObject.h"

@interface CardMaster : NSObject

+ (BOOL)replaceServerCardIntoDBWithService_code:(NSString *)service_code
                               card_master_code:(NSString *)card_master_code
                                   service_name:(NSString *)service_name
                               card_master_name:(NSString *)card_master_name
                                    service_url:(NSString *)service_url
                                    description:(NSString *)description
                                additional_auth:(NSString *)additional_auth
                                    maintenance:(NSString *)maintenance
                                       card_seq:(int)card_seq;
+ (BOOL)replaceServerCardIntoDBBy:(ServerCardObject *)serverCardObject;
+ (void)replaceServerCardsIntoDBBy:(NSArray *)serverCardObjsArray;

+ (BOOL)deleteServerCardInDBByService_code:(NSString *)service_code andCard_master_code:(NSString *)card_master_code;

+ (ServerCardObject *)getServerCardObjectByService_code:(NSString *)service_code andCard_master_code:(NSString *)card_master_code;

+ (NSMutableArray *)getAllServerCards;

+ (NSMutableArray *)getCardMasterNameByServiceCode:(NSString *)serviceCode;

+ (NSString *)getServiceNameByServiceCode:(NSString *)serviceCode;

+ (BOOL)cleanTable;

@end

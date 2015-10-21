//
//  Entry.h
//  Creco
//
//  Created by Windward on 15/6/21.
//  Copyright (c) 2015年 Windward. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UserCardObject.h"

@interface Entry : NSObject

+ (BOOL)replaceUserCardIntoDBWithService_code:(NSString *)service_code
                                    card_code:(NSString *)card_code
                                    card_name:(NSString *)card_name
                                         memo:(NSString *)memo
                                        color:(NSString *)color
                                     card_seq:(int)card_seq;
+ (BOOL)replaceUserCardIntoDBBy:(UserCardObject *)userCardObject;

+ (BOOL)deleteUserCardInDBByService_code:(NSString *)service_code andCard_code:(NSString *)card_code;
+ (BOOL)deleteUserCardInDBByService_code:(NSString *)service_code;

+ (UserCardObject *)getUserCardObjectByService_code:(NSString *)service_code andCard_code:(NSString *)card_code;
+ (NSString *)getCardNameByCardCode:(NSString *)card_code;

//If only have one object, it must be allCard Object
+ (NSMutableArray *)getAllUserCards;
+ (NSMutableArray *)getUserCardsByService_code:(NSString *)service_code;

+ (BOOL)updateUserCardByCard_code:(NSString *)card_code seq:(int)seq_code;
+ (BOOL)updateUserCardByCard_code:(NSString *)card_code color:(NSString *)color name:(NSString *)name memo:(NSString *)memo;
+ (BOOL)updateUserCardSeqByCard_code:(NSString *)card_code Service_code:(NSString *)service_code seq:(int)seq_code;

+ (BOOL)cleanTable;

@end

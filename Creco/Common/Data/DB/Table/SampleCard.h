//
//  SampleCard.h
//  Creco
//
//  Created by Windward on 15/7/7.
//  Copyright (c) 2015年 Windward. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DetailCostObject.h"
#import "UserCardObject.h"

@interface SampleCard : NSObject

+ (BOOL)replaceSampleCostIntoDBWithCode:(NSString *)code
                              card_code:(NSString *)card_code
                       card_master_code:(NSString *)card_master_code
                          calendar_memo:(NSString *)calendar_memo
                                  image:(NSString *)image
                                   date:(NSString *)date
                                   name:(NSString *)name
                                  price:(NSString *)price
                                  color:(NSString *)color
                       card_master_name:(NSString *)card_master_name;
+ (void)replaceSampleCardsIntoDBBy:(NSArray *)sampleCardsArr;

+ (BOOL)deleteSampleCostInDBByCode:(NSString *)code;

+ (DetailCostObject *)getDetailCostObjectByCard_code:(NSString *)card_code;
+ (UserCardObject *)getUserCardObjectByCard_code:(NSString *)card_code;

+ (NSMutableArray *)getAllSampleCards;//Return all UserCardObjects array

+ (NSMutableArray *)getAllSampleCosts;//Return all DetailCostObjects array
+ (NSMutableArray *)getAllSampleCostsOrderBy;

+ (NSMutableArray *)getSampleCardCostsBy:(NSString *)card_code;
+ (NSMutableArray *)getSampleCardCostsByASC:(NSString *)card_code;
+ (NSMutableArray *)getSampleCardCostsByDate:(NSString *)date;

+ (NSString *)getCardMasterNameBy:(NSString *)card_code;

+ (BOOL)cleanTable;

@end

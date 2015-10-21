//
//  Details.h
//  Creco
//
//  Created by Windward on 15/6/23.
//  Copyright (c) 2015年 Windward. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DetailCostObject.h"

@interface Details : NSObject

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
                                    bestshot:(int)bestshot;
+ (BOOL)replaceDetailCostIntoDBBy:(DetailCostObject *)detailCostObject;

+ (BOOL)deleteDetailCostInDBByCard_code:(NSString *)card_code andCode:(NSString *)code;
+ (BOOL)deleteDetailCostInDBByCard_code:(NSString *)card_code;

+ (DetailCostObject *)getDetailCostObjectByCard_code:(NSString *)card_code andCode:(NSString *)code;

+ (NSMutableArray *)getAllDetailCosts;
+ (NSMutableArray *)getAllDetailCostsOrderBy;
+ (NSMutableArray *)getCardDetailCostsBy:(NSString *)card_code;
+ (NSMutableArray *)getCardDetailCostsByASC:(NSString *)card_code;
+ (NSMutableArray *)getDetailCostsByDate:(NSString *)date;
+ (BOOL)updateDetailCostsByDate:(NSString *)date code:code memo:(NSString *)memo bestShot:(int)bestShot;

+ (BOOL)cleanTable;

@end

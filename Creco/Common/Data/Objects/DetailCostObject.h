//
//  DetailCostObject.h
//  Creco
//
//  Created by Windward on 15/6/7.
//  Copyright (c) 2015年 Windward. All rights reserved.
//

#import "BaseObject.h"

@interface DetailCostObject : BaseObject
@property (nonatomic, strong) NSString *card_code;//Primary key
@property (nonatomic, strong) NSString *code;
@property (nonatomic, strong) NSString *date;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *note;
@property (nonatomic, strong) NSString *owner;
@property (nonatomic, strong) NSString *payday;
@property (nonatomic, strong) NSString *price;
@property (nonatomic, strong) NSString *disable;
//Local DB
@property (nonatomic, strong) NSString *picture1;
@property (nonatomic, strong) NSString *picture2;
@property (nonatomic, strong) NSString *picture3;
@property (nonatomic) int bestshot;
//
- (id)initWithCard_code:(NSString *)card_code
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
@end

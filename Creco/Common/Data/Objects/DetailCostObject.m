//
//  DetailCostObject.m
//  Creco
//
//  Created by Windward on 15/6/7.
//  Copyright (c) 2015年 Windward. All rights reserved.
//

#import "DetailCostObject.h"

@implementation DetailCostObject

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
               bestshot:(int)bestshot
{
    if (self = [super init]) {
        _card_code = card_code;
        _code = code;
        _date = date;
        _name = name;
        _note = note;
        _owner = owner;
        _payday = payday;
        _price = price;
        _disable = disable;
        _picture1 = picture1;
        _picture2 = picture2;
        _picture3 = picture3;
        _bestshot = bestshot;
    }
    return self;
}

- (void)setDate:(NSString *)date
{
    if ([date rangeOfString:@"/"].location != NSNotFound)
        _date = [date stringByReplacingOccurrencesOfString:@"/" withString:@"-"];
    else
        _date = date;
}

- (void)setPayday:(NSString *)payday
{
    if ([payday rangeOfString:@"/"].location != NSNotFound)
        _payday = [payday stringByReplacingOccurrencesOfString:@"/" withString:@"-"];
    else
        _payday = payday;
}

@end

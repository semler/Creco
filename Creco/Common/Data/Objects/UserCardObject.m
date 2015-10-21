//
//  UserCardObject.m
//  Creco
//
//  Created by Windward on 15/6/21.
//  Copyright (c) 2015年 Windward. All rights reserved.
//

#import "UserCardObject.h"

@implementation UserCardObject

- (id)initWithService_code:(NSString *)service_code
                 card_code:(NSString *)card_code
                 card_name:(NSString *)card_name
                      memo:(NSString *)memo
                     color:(NSString *)color
                  card_seq:(int)card_seq
{
    if (self = [super init]) {
        _service_code = service_code;
        _card_code = card_code;
        _card_name = card_name;
        _memo = memo;
        _color = color;
        _card_seq = card_seq;
    }
    return self;
}

@end

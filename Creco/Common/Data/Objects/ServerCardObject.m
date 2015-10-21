//
//  ServerCardObject.m
//  Creco
//
//  Created by Windward on 15/5/29.
//  Copyright (c) 2015年 Windward. All rights reserved.
//

#import "ServerCardObject.h"

@implementation ServerCardObject

- (id)initWithService_code:(NSString *)service_code
          card_master_code:(NSString *)card_master_code
              service_name:(NSString *)service_name
          card_master_name:(NSString *)card_master_name
               service_url:(NSString *)service_url
               description:(NSString *)description
           additional_auth:(NSString *)additional_auth
               maintenance:(NSString *)maintenance
                  card_seq:(int)card_seq
{
    if (self = [super init]) {
        _service_code = service_code;
        _card_master_code = card_master_code;
        _service_name = service_name;
        _card_master_name = card_master_name;
        _service_url = service_url;
        _descriptionStr = description;
        _additional_auth = additional_auth;
        _maintenance = maintenance;
        _card_seq = card_seq;
    }
    return self;
}

- (void)setValue:(id)value forKey:(NSString *)key
{
    if ([key isEqualToString:@"description"])
        key = @"descriptionStr";
    
    [super setValue:value forKey:key];
}

- (void)setCards:(NSDictionary *)cards
{
    _cards = cards;
    if (cards.allValues)
        _cardsArray = cards.allValues;
}

@end

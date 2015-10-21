//
//  UserWebObject.m
//  Creco
//
//  Created by Windward on 15/7/7.
//  Copyright (c) 2015年 Windward. All rights reserved.
//

#import "UserWebObject.h"

@implementation UserWebObject

- (id)initWithService_code:(NSString *)service_code
              service_name:(NSString *)service_name
               web_id_code:(NSString *)web_id_code
                 card_code:(NSString *)card_code
                    web_id:(NSString *)web_id
     initialization_vector:(NSString *)initialization_vector
                  password:(NSString *)password
            detail_get_flg:(BOOL)detail_get_flg
{
    if (self = [super init]) {
        _service_code = service_code;
        _service_name = service_name;
        _web_id_code = web_id_code;
        _card_code = card_code;
        _web_id = web_id;
        _initialization_vector = initialization_vector;
        _password = password;
        _detail_get_flg = detail_get_flg;
    }
    return self;
}

@end

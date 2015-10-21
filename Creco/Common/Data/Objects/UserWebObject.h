//
//  UserWebObject.h
//  Creco
//
//  Created by Windward on 15/7/7.
//  Copyright (c) 2015年 Windward. All rights reserved.
//

#import "BaseObject.h"

@interface UserWebObject : BaseObject
@property (nonatomic, strong) NSString *service_code;
@property (nonatomic, strong) NSString *service_name;
@property (nonatomic, strong) NSString *web_id_code;
@property (nonatomic, strong) NSString *card_code;
@property (nonatomic, strong) NSString *web_id;
@property (nonatomic, strong) NSString *initialization_vector;
@property (nonatomic, strong) NSString *password;
@property (nonatomic) BOOL detail_get_flg;

- (id)initWithService_code:(NSString *)service_code
              service_name:(NSString *)service_name
               web_id_code:(NSString *)web_id_code
                 card_code:(NSString *)card_code
                    web_id:(NSString *)web_id
     initialization_vector:(NSString *)initialization_vector
                  password:(NSString *)password
            detail_get_flg:(BOOL)detail_get_flg;

@end

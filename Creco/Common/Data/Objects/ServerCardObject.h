//
//  ServerCardObject.h
//  Creco
//
//  Created by Windward on 15/5/29.
//  Copyright (c) 2015年 Windward. All rights reserved.
//

#import "BaseObject.h"

@interface ServerCardObject : BaseObject

@property (nonatomic, strong) NSString *service_code;//Primary key
@property (nonatomic, strong) NSString *card_master_code;//Primary key
@property (nonatomic, strong) NSString *service_name;
@property (nonatomic, strong) NSString *card_master_name;
@property (nonatomic, strong) NSString *service_url;
@property (nonatomic, strong) NSString *descriptionStr;
@property (nonatomic, strong) NSString *additional_auth;
@property (nonatomic, strong) NSString *maintenance;
@property (nonatomic) int card_seq;

@property (nonatomic, strong) NSDictionary *cards;
@property (nonatomic, strong) NSArray *cardsArray;

- (id)initWithService_code:(NSString *)service_code
          card_master_code:(NSString *)card_master_code
              service_name:(NSString *)service_name
          card_master_name:(NSString *)card_master_name
               service_url:(NSString *)service_url
               description:(NSString *)description
           additional_auth:(NSString *)additional_auth
               maintenance:(NSString *)maintenance
                  card_seq:(int)card_seq;

@end

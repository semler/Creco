//
//  UserCardObject.h
//  Creco
//
//  Created by Windward on 15/6/21.
//  Copyright (c) 2015年 Windward. All rights reserved.
//

#import "BaseObject.h"

@interface UserCardObject : BaseObject
@property (nonatomic, strong) NSString *service_code;//Primary key
@property (nonatomic, strong) NSString *card_code;//Primary key
@property (nonatomic, strong) NSString *card_name;
//Local DB
@property (nonatomic, strong) NSString *memo;
@property (nonatomic, strong) NSString *color;
@property (nonatomic) int card_seq;
//

- (id)initWithService_code:(NSString *)service_code
                 card_code:(NSString *)card_code
                 card_name:(NSString *)card_name
                      memo:(NSString *)memo
                     color:(NSString *)color
                  card_seq:(int)card_seq;

@end

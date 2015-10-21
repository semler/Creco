//
//  BaseObject.m
//  Creco
//
//  Created by Windward on 15/5/29.
//  Copyright (c) 2015年 Windward. All rights reserved.
//

#import "BaseObject.h"

@implementation BaseObject

- (void)setValue:(id)value forKey:(NSString *)key
{
    if ([value isKindOfClass:[NSNull class]])
        value = @"";
    else if ([value isKindOfClass:[NSNumber class]])
        value = [value stringValue];
    
    [super setValue:value forKey:key];
}

@end

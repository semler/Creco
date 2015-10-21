//
//  CardManager.m
//  Creco
//
//  Created by 于　超 on 2015/07/08.
//  Copyright (c) 2015年 Windward. All rights reserved.
//

#import "CardManager.h"

@implementation CardManager

static CardManager *cardManager = nil;

+ (CardManager *)sharedManager{
    if (!cardManager) {
        cardManager = [[CardManager alloc] init];
    }
    return cardManager;
}

- (id)init
{
    self = [super init];
    if (self) {
        _colorArray = [NSMutableArray arrayWithObjects:
                       @"ffe800",
                       @"a7ff00",
                       @"bf4040",
                       @"ea7500",
                       @"eaaf00",
                       @"8fbf00",
                       @"40bf9f",
                       @"ff80df",
                       @"00bbea",
                       @"4060bf",
                       @"7a60ca",
                       @"323232",nil];
    }
    
    return self;
}

-(void)setColor:(NSString *)color {
    _color = color;
    for (int i = 0; i < _colorArray.count; i ++) {
        if ([color isEqualToString:[_colorArray objectAtIndex:i]]) {
            _index = i;
            break;
        }
    }
}

@end

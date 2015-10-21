//
//  BigButton.m
//  Creco
//
//  Created by 于　超 on 2015/06/03.
//  Copyright (c) 2015年 Windward. All rights reserved.
//

#import "BigButton.h"

@implementation BigButton

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent*)event
{
    CGRect bounds = self.bounds;
    //若原热区小于44x44，则放大热区，否则保持原大小不变
    CGFloat widthDelta = MAX(22.0 - bounds.size.width, 0);
    CGFloat heightDelta = MAX(22.0 - bounds.size.height, 0);
    bounds = CGRectInset(bounds, -0.5 * widthDelta, -0.5 * heightDelta);
    return CGRectContainsPoint(bounds, point);
}

@end

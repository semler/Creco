//
//  UIViewAdditions.h
//  Omiai
//
//  Created by Ryuukou on 12-10-11.
//  Copyright (c) 2012年 Bravesoft. All rights reserved.

#import <UIKit/UIKit.h>

@interface UIView (UIViewAdditions)

@property(nonatomic) CGFloat left;
@property(nonatomic) CGFloat right;
@property(nonatomic) CGFloat top;
@property(nonatomic) CGFloat bottom;
@property(nonatomic) CGFloat width;
@property(nonatomic) CGFloat height;

- (void) circularBeadWithRadius:(float)radius;
+ (void)animationFadeIn:(UIView *)inView fadeOut:(UIView *)outView;

@end

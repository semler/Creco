//
//  UIViewAdditions.h
//  Omiai
//
//  Created by Ryuukou on 12-10-11.
//  Copyright (c) 2012年 Bravesoft. All rights reserved.

#import "UIViewAdditions.h"

@implementation UIView (UIViewAdditions)

- (CGFloat)left
{
  return self.frame.origin.x;
}

- (void)setLeft:(CGFloat)x
{
  CGRect frame = self.frame;
  frame.origin.x = x;
  self.frame = frame;
}

- (CGFloat)right
{
  return self.frame.origin.x + self.frame.size.width;
}

- (void)setRight:(CGFloat)right
{
  CGRect frame = self.frame;
  frame.origin.x = right - frame.size.width;
  self.frame = frame;
}

- (CGFloat)top
{
  return self.frame.origin.y;
}

- (void)setTop:(CGFloat)y
{
  CGRect frame = self.frame;
  frame.origin.y = y;
  self.frame = frame;
}

- (CGFloat)bottom
{
  return self.frame.origin.y + self.frame.size.height;
}

- (void)setBottom:(CGFloat)bottom
{
  CGRect frame = self.frame;
  frame.origin.y = bottom - frame.size.height;
  self.frame = frame;
}

- (CGFloat)width
{
  return self.frame.size.width;
}

- (void)setWidth:(CGFloat)width
{
  CGRect frame = self.frame;
  frame.size.width = width;
  self.frame = frame;
}

- (CGFloat)height
{
  return self.frame.size.height;
}

- (void)setHeight:(CGFloat)height
{
  CGRect frame = self.frame;
  frame.size.height = height;
  self.frame = frame;
}

- (void)circularBeadWithRadius:(float)radius {

    CALayer *layer = [self layer];
    layer.shadowOffset = CGSizeMake(0, 3);
    layer.shadowRadius = 10.0;
    layer.shadowColor = [UIColor blackColor].CGColor;
    layer.shadowOpacity = 1.0;
    layer.cornerRadius = radius;
}

+ (void)animationFadeIn:(UIView *)inView fadeOut:(UIView *)outView {
    
    inView.hidden = NO;
    
    // Fade in Fade out
    CGContextRef ctx = UIGraphicsGetCurrentContext();
	[UIView beginAnimations:nil context:ctx];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	[UIView setAnimationDuration:.5f];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDelegate:self];
    
    inView.alpha = 1.f;
    outView.alpha = 0.f;
    
	[UIView commitAnimations];
}

@end

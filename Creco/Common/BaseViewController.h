//
//  BaseViewController.h
//  Creco
//
//  Created by Windward on 14/9/15.
//  Copyright (c) 2014年 Windward. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BaseViewController : UIViewController
@property (nonatomic) BOOL isInMyView;

- (void)topicChanged;

- (void)onlyNeedStatusView;

- (void)setCustomLeftButtonBy:(UIImage *)leftImage;
- (void)clickLeftButton;
- (void)setCustomRightButtonBy:(UIImage *)rightImage;
- (void)clickRightButton;

- (void)addSubview:(UIView *)view;

@end

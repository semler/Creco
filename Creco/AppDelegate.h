//
//  AppDelegate.h
//  Creco
//
//  Created by Windward on 15/5/17.
//  Copyright (c) 2015年 Windward. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppTabBarViewController.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, strong) AppTabBarViewController *appTabBarVC;
@property (nonatomic, strong) UIImageView *defaultImageView;

- (void)customizeAppearance;

@end


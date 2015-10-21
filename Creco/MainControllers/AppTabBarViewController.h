//
//  AppTabBarViewController.h
//  Creco
//
//  Created by Windward on 15/5/17.
//  Copyright (c) 2015年 Windward. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RecordViewController.h"
#import "HomeViewController.h"

@interface AppTabBarViewController : UITabBarController
@property (nonatomic, strong) UITabBarItem *menuTabbarItem;
@property (nonatomic, strong) RecordViewController *recordVC;
@property (nonatomic, strong) HomeViewController *homeVC;
@end

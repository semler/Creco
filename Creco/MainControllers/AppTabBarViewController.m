//
//  AppTabBarViewController.m
//  Creco
//
//  Created by Windward on 15/5/17.
//  Copyright (c) 2015年 Windward. All rights reserved.
//

#import "AppTabBarViewController.h"
#import "CalendarViewController.h"
#import "MenuViewController.h"

@interface AppTabBarViewController ()
@end

@implementation AppTabBarViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navigationController.navigationBarHidden = YES;

    self.homeVC = [[HomeViewController alloc] init];
    UINavigationController *homeNavController = [[UINavigationController alloc] initWithRootViewController:self.homeVC];
    homeNavController.navigationBarHidden = YES;
    
    CalendarViewController *calendarVC = [[CalendarViewController alloc] init];
    UINavigationController *calendarNavController = [[UINavigationController alloc] initWithRootViewController:calendarVC];
    calendarNavController.navigationBarHidden = YES;
    
    self.recordVC = [[RecordViewController alloc] init];
    UINavigationController *recordNavController = [[UINavigationController alloc] initWithRootViewController:self.recordVC];
    
    MenuViewController *menuVC = [[MenuViewController alloc] init];
    UINavigationController *menuNavController = [[UINavigationController alloc] initWithRootViewController:menuVC];
    menuNavController.navigationBarHidden = YES;
    
    homeNavController.tabBarItem = [[UITabBarItem alloc] initWithTitle:nil image:[[UIImage imageNamed:@"icon_home"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] selectedImage:[[UIImage imageNamed:@"icon_home_on"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    homeNavController.tabBarItem.tag = 0;
    
    calendarNavController.tabBarItem = [[UITabBarItem alloc] initWithTitle:nil image:[[UIImage imageNamed:@"icon_calendar"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] selectedImage:[[UIImage imageNamed:@"icon_calendar_on"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    calendarNavController.tabBarItem.tag = 1;
    
    recordNavController.tabBarItem = [[UITabBarItem alloc] initWithTitle:nil image:[[UIImage imageNamed:@"icon_record"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] selectedImage:[[UIImage imageNamed:@"icon_record_on"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    recordNavController.tabBarItem.tag = 2;
    
    menuNavController.tabBarItem = [[UITabBarItem alloc] initWithTitle:nil image:[[UIImage imageNamed:@"icon_menu"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] selectedImage:[[UIImage imageNamed:@"icon_menu_on"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    menuNavController.tabBarItem.tag = 3;
    
    self.menuTabbarItem = menuNavController.tabBarItem;
    self.menuTabbarItem.badgeValue = [InfoRead getUnReadMessageCount] > 0 ? @"N" : nil;
    
    UIEdgeInsets imageEdgeInsets = UIEdgeInsetsMake(6, 0, -6, 0);
    homeNavController.tabBarItem.imageInsets = imageEdgeInsets;
    calendarNavController.tabBarItem.imageInsets = imageEdgeInsets;
    recordNavController.tabBarItem.imageInsets = imageEdgeInsets;
    menuNavController.tabBarItem.imageInsets = imageEdgeInsets;
    
    [self setViewControllers:@[homeNavController, calendarNavController, recordNavController, menuNavController]];
    
    DrawLine(homeNavController.navigationBar, 0, homeNavController.navigationBar.height-0.5f, homeNavController.navigationBar.width, 0.5f, COLOR_LINE);
    DrawLine(calendarNavController.navigationBar, 0, calendarNavController.navigationBar.height-0.5f, calendarNavController.navigationBar.width, 0.5f, COLOR_LINE);
    DrawLine(recordNavController.navigationBar, 0, recordNavController.navigationBar.height-0.5f, recordNavController.navigationBar.width, 0.5f, COLOR_LINE);
    DrawLine(menuNavController.navigationBar, 0, menuNavController.navigationBar.height-0.5f, menuNavController.navigationBar.width, 0.5f, COLOR_LINE);
    
    self.tabBar.backgroundImage = [ShareMethods createImageWithColor:[ShareMethods colorFromHexRGB:[[NSUserDefaults standardUserDefaults] valueForKey:kAppTopicColor]] size:CGSizeMake(kAllViewWidth, kTabbarHeight)];
    self.tabBar.shadowImage = nil;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(topicChanged)
                                                 name:kTopicIsChanged
                                               object:nil];
}

- (void)topicChanged
{
    self.tabBar.backgroundImage = [ShareMethods createImageWithColor:[ShareMethods colorFromHexRGB:[[NSUserDefaults standardUserDefaults] valueForKey:kAppTopicColor]] size:CGSizeMake(kAllViewWidth, kTabbarHeight)];
    self.tabBar.shadowImage = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    if (!self.navigationController.navigationBarHidden)
        [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kTopicIsChanged object:nil];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

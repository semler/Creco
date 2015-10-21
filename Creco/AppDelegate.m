//
//  AppDelegate.m
//  Creco
//
//  Created by Windward on 15/5/17.
//  Copyright (c) 2015年 Windward. All rights reserved.
//

#import "AppDelegate.h"
#import "UseStatuteViewController.h"
#import "AppTabBarViewController.h"
#import "PWSettingViewController.h"
#import "HowToUseScrollView.h"

@interface AppDelegate () <UIAlertViewDelegate>
{
    BOOL isEnterForeground;
}
@end

@implementation AppDelegate

/**
 *  custom this app's appearance
 */
- (void)customizeAppearance
{
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    [[UITextField appearance] setTintColor:kRGBColor(45.f, 116.f, 241.f, 1.f)];
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    [[UISearchBar appearance] setTintColor:[UIColor whiteColor]];
    [[UISwitch appearance] setOnTintColor:[ShareMethods colorFromHexRGB:[[NSUserDefaults standardUserDefaults] valueForKey:kAppTopicColor]]];
    
    [[UINavigationBar appearance] setBackgroundImage:[UIImage imageTopicNamed:@"nav_bg"]
                                      forBarPosition:UIBarPositionTopAttached
                                          barMetrics:UIBarMetricsDefault];
    [[UISearchBar appearance] setBackgroundImage:[UIImage imageTopicNamed:@"nav_bg"]];
    
    NSShadow *navShadow = [[NSShadow alloc] init];
    navShadow.shadowColor = [UIColor clearColor];
    navShadow.shadowOffset = CGSizeMake(0, 0);
    [[UINavigationBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName : [ShareMethods colorFromHexRGB:[[NSUserDefaults standardUserDefaults] valueForKey:kAppTopicColor]],
                                                           NSFontAttributeName: [UIFont boldSystemFontOfSize:16],
                                                           NSShadowAttributeName : navShadow}];
    
    [[UINavigationBar appearance] setShadowImage:[[UIImage alloc] init]];
    [[UILabel appearance] setBackgroundColor:[UIColor clearColor]];
}

- (void)registerPushNoitification
{
    //Register for push notification
    if (Is_iOS8OrLater)
    {
        [[UIApplication sharedApplication] registerForRemoteNotifications];
        UIUserNotificationType types = UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert;
        UIUserNotificationSettings *setting = [UIUserNotificationSettings settingsForTypes:types categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:setting];
    }else
    {
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:UIRemoteNotificationTypeBadge |
         UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert];
    }
    
    BOOL bPushEnable = NO;
    if (Is_iOS8OrLater)
    {
        UIUserNotificationSettings *pushSetting = [[UIApplication sharedApplication] currentUserNotificationSettings];
        if (pushSetting)
        {
            UIUserNotificationType pushType = pushSetting.types;
            if (pushType == UIUserNotificationTypeNone)
                bPushEnable = NO;
            else
                bPushEnable = YES;
        }
    }else
    {
        UIRemoteNotificationType pushType = [[UIApplication sharedApplication] enabledRemoteNotificationTypes];
        if (pushType == UIRemoteNotificationTypeNone)
            bPushEnable = NO;
        else
            bPushEnable = YES;
    }
    
    if (bPushEnable == NO)
    {
        TDLog(@"Push is Closed!");
    }
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    [NSThread sleepForTimeInterval:3.f];
    
    if (![[NSUserDefaults standardUserDefaults] valueForKey:kAppTopicColor]) {
        [[NSUserDefaults standardUserDefaults] setValue:DEFAULT_APP_STSYLE_COLOR forKey:kAppTopicColor];//Default Color
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    [self customizeAppearance];
    [self registerPushNoitification];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    self.appTabBarVC = [[AppTabBarViewController alloc] init];
    UINavigationController *rootNavController = [[UINavigationController alloc] initWithRootViewController:self.appTabBarVC];
    rootNavController.navigationBarHidden = YES;
    self.window.rootViewController = rootNavController;
    DrawLine(rootNavController.navigationBar, 0, rootNavController.navigationBar.height-0.5f, rootNavController.navigationBar.width, 0.5f, COLOR_LINE);
    
    // 起動回数
    int count = (int)[[NSUserDefaults standardUserDefaults] integerForKey:kStartCount];
    count++;
    [[NSUserDefaults standardUserDefaults] setInteger:count forKey:kStartCount];
    [[NSUserDefaults standardUserDefaults] synchronize];
    if (![[NSUserDefaults standardUserDefaults] boolForKey:kAppOpenMoreThanOnce])
    {
        UseStatuteViewController *useStatuteVC = [[UseStatuteViewController alloc] init];
        UINavigationController *useStatuteNavController = [[UINavigationController alloc] initWithRootViewController:useStatuteVC];
        useStatuteNavController.navigationBarHidden = YES;
        [self.window.rootViewController presentViewController:useStatuteNavController animated:NO completion:nil];
        
        HowToUseScrollView *howToUseView = [[HowToUseScrollView alloc] initWithFrame:CGRectMake(0, 0, self.window.width, self.window.height)];
        [self.window addSubview:howToUseView];
    }
    
    [self getPushDictionary:[launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey]];
    
    return YES;
}

- (void)getPushDictionary:(NSDictionary *)pushDic
{
    if (pushDic) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"取得完了しました"
                                                        message:nil
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        
        [NSObject cancelPreviousPerformRequestsWithTarget:self.appTabBarVC.homeVC];//Cancel request Detail api
    }
}

#pragma mark - UIAlertViewDelegate -

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0)
        [self.appTabBarVC.homeVC requestDetailsData];
}

#pragma mark -  PUSH -

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    NSString *deviceTokenStr = [[[[deviceToken description]
                                  stringByReplacingOccurrencesOfString:@"<"withString:@""]
                                 stringByReplacingOccurrencesOfString:@">" withString:@""]
                                stringByReplacingOccurrencesOfString:@" " withString:@""];
    [AppConfig shareConfig].deviceToken = deviceTokenStr;
    
    [self.appTabBarVC.homeVC initData];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    [self.appTabBarVC.homeVC initData];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    [self getPushDictionary:userInfo];
}

#pragma mark -

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    [self.appTabBarVC.homeVC requestDetailsData];
    isEnterForeground = YES;
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:kAppOpenMoreThanOnce]) {
        if ([[NSUserDefaults standardUserDefaults] boolForKey:kNeedEnterPassword]) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"removeCalendar" object:nil];
            PWSettingViewController *pwSettingVC = [[PWSettingViewController alloc] init];
            [self.window.rootViewController presentViewController:pwSettingVC animated:NO completion:nil];
            
            if (isEnterForeground) {
                isEnterForeground = NO;
                if (!self.defaultImageView)
                {
                    UIImage *defaultImg = [UIImage imageNamed:@"LaunchImage-800-Portrait-736h"];
                    if (Is_iPhone4Or4s) {
                        defaultImg = [UIImage imageNamed: @"LaunchImage-700"];
                    }else if (Is_iPhone5Or5s) {
                        defaultImg = [UIImage imageNamed:@"LaunchImage-700-568h"];
                    }else if (Is_iPhone6) {
                        defaultImg = [UIImage imageNamed:@"LaunchImage-800-667h"];
                    }else if (Is_iPhone6_Plus) {
                        defaultImg = [UIImage imageNamed:@"LaunchImage-800-Portrait-736h"];
                    }
                    
                    self.defaultImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, defaultImg.size.width, defaultImg.size.height)];
                    self.defaultImageView.image = defaultImg;
                }
                [self.window addSubview:self.defaultImageView];
            }
        }
    }
    
    [RequestManager requestPath:kGetMessageNotification parameters:nil success:^(AFHTTPRequestOperation *operation, id result) {
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
    }];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end

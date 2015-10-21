//
//  AppConfig.m
//  Creco
//
//  Created by Windward on 14/9/29.
//  Copyright (c) 2014年 Windward. All rights reserved.
//

#import "AppConfig.h"

@implementation AppConfig
@synthesize allCategorysArray;
@synthesize networkStatus;

- (id)init
{
    if (self = [super init])
    {
        self.networkStatus = AFNetworkReachabilityStatusUnknown;
    }
    return self;
}

+ (AppConfig *)shareConfig
{
    static dispatch_once_t pred = 0;
    __strong static id _shareObject = nil;
    dispatch_once(&pred, ^{
        _shareObject = [[self alloc] init];
    });
    
    return _shareObject;
}

- (NSString *)deviceToken
{
    if (_deviceToken.length == 0) {
        _deviceToken = @"";
    }
    return _deviceToken;
}

- (NSString *)uuid
{
    NSString *uuidStr = nil;
    if (![[NSUserDefaults standardUserDefaults] valueForKey:kDeviceIdentifier])
    {
        CFUUIDRef uuid_ref = CFUUIDCreate(NULL);
        CFStringRef uuid_string_ref= CFUUIDCreateString(NULL, uuid_ref);
        CFRelease(uuid_ref);
        uuidStr = (__bridge_transfer NSString *)uuid_string_ref;
        uuidStr = [uuidStr stringByReplacingOccurrencesOfString:@"-" withString:@""];
        uuidStr = [NSString stringWithFormat:@"IPHONE%@", uuidStr];
        uuidStr = [uuidStr substringToIndex:32];//keep 32 kb
        
        [[NSUserDefaults standardUserDefaults] setValue:uuidStr forKey:kDeviceIdentifier];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }else
        uuidStr = [[NSUserDefaults standardUserDefaults] valueForKey:kDeviceIdentifier];
    return uuidStr;
}

- (void)showLoadingView
{
    if (!loadingView)
    {
        loadingView = [[LoadingView alloc] initWithFrame:CGRectMake(0, 0, 150, 50) titleStr:@"読み込み中..."];
        loadingView.center = CGPointMake(kAppDelegate.window.width/2, kAppDelegate.window.height/2);
    }
    [loadingView.activityIndicatorView startAnimating];
    [kAppDelegate.window addSubview:loadingView];
}

- (void)hiddenLoadingView
{
    if ([loadingView superview])
    {
        [loadingView.activityIndicatorView stopAnimating];
        [loadingView removeFromSuperview];
    }
}

- (void)timeToRequestAggregationAPI:(NSInteger)fireTime
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(requestAggregationAPI) object:nil];
    [self performSelector:@selector(requestAggregationAPI) withObject:nil afterDelay:fireTime];
}

- (void)requestAggregationAPI
{
    [kAppDelegate.appTabBarVC.homeVC aggregationToGetDetailData];
}

- (void)timeToRequestDetailAPI:(NSInteger)fireTime
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(requestDetailAPI) object:nil];
    [self performSelector:@selector(requestDetailAPI) withObject:nil afterDelay:fireTime];
}

- (void)requestDetailAPI
{
    [kAppDelegate.appTabBarVC.homeVC requestDetailsData];
}

@end

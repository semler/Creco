//
//  AppConfig.h
//  Creco
//
//  Created by Windward on 14/9/29.
//  Copyright (c) 2014年 Windward. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LoadingView.h"
#import "AFNetworkReachabilityManager.h"

@interface AppConfig : NSObject
{
    LoadingView *loadingView;
}
@property (nonatomic, strong) NSMutableArray *allCategorysArray;
@property (nonatomic) AFNetworkReachabilityStatus networkStatus;
@property (nonatomic, strong) NSString *uuid;
@property (nonatomic, strong) NSString *deviceToken;
@property (nonatomic) BOOL isShowAPIAlert;

+ (AppConfig *)shareConfig;

- (void)showLoadingView;
- (void)hiddenLoadingView;

- (void)timeToRequestAggregationAPI:(NSInteger)fireTime;
- (void)timeToRequestDetailAPI:(NSInteger)fireTime;

@end

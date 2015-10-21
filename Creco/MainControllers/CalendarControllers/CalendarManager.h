//
//  CalendarManager.h
//  Creco
//
//  Created by 于　超 on 2015/07/07.
//  Copyright (c) 2015年 Windward. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CalendarManager : NSObject <NSURLSessionDataDelegate>

+ (CalendarManager *)sharedManager;

@property (strong, nonatomic) NSMutableArray *dataList;
@property (nonatomic) BOOL isSaveButtonOn;
@property (nonatomic) BOOL isKeybordOn;
@property (nonatomic) BOOL isCoverViewOn;
@property (strong, nonatomic) NSString *keyword;
@property (nonatomic) int currentIndex;
@property (strong, nonatomic) NSDate *calendarDate;
@property (nonatomic) BOOL isGoogle;

-(void)setGoogleImage: (DetailCostObject *)detail;

@end

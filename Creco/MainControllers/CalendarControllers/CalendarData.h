//
//  CalendarData.h
//  Creco
//
//  Created by 于　超 on 2015/07/13.
//  Copyright (c) 2015年 Windward. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CalendarData : NSObject

@property (nonatomic) int selectedButton;
@property (nonatomic) int bestShot;
@property (nonatomic) NSString *code;

@property (nonatomic) BOOL addFlg;

@property (strong, nonatomic) NSString *imagePath1;
@property (strong, nonatomic) NSString *imagePath2;
@property (strong, nonatomic) NSString *imagePath3;
@property (strong, nonatomic) NSMutableArray *pathArray;

-(void) setPath:(NSString *)date;

@end

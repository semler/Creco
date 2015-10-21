//
//  CalendarData.m
//  Creco
//
//  Created by 于　超 on 2015/07/13.
//  Copyright (c) 2015年 Windward. All rights reserved.
//

#import "CalendarData.h"

@implementation CalendarData

-(void) setPath:(NSString *)date {
    NSString *year = [date substringWithRange:NSMakeRange(0,4)];
    NSString *month = [date substringWithRange:NSMakeRange(5,2)];
    NSString *day = [date substringWithRange:NSMakeRange(8,2)];
    NSString *hour = [date substringWithRange:NSMakeRange(11,2)];
    NSString *minute = [date substringWithRange:NSMakeRange(14,2)];
    NSString *second = [date substringWithRange:NSMakeRange(17,2)];
    NSString *time = [NSString stringWithFormat:@"%@%@%@%@%@%@", year, month, day, hour, minute, second];
    
    _imagePath1 = [NSString stringWithFormat:@"%@/%@%@%@", [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"], time, _code, @"_1.jpg"];
    _imagePath2 = [NSString stringWithFormat:@"%@/%@%@%@", [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"], time, _code, @"_2.jpg"];
    _imagePath3 = [NSString stringWithFormat:@"%@/%@%@%@", [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"], time, _code, @"_3.jpg"];
    _pathArray = [NSMutableArray array];
    [_pathArray addObject:_imagePath1];
    [_pathArray addObject:_imagePath2];
    [_pathArray addObject:_imagePath3];
}

@end

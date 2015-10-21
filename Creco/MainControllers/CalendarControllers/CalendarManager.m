//
//  CalendarManager.m
//  Creco
//
//  Created by 于　超 on 2015/07/07.
//  Copyright (c) 2015年 Windward. All rights reserved.
//

#import "CalendarManager.h"

@implementation CalendarManager

static CalendarManager *calendarManager = nil;

+ (CalendarManager *)sharedManager{
    if (!calendarManager) {
        calendarManager = [[CalendarManager alloc] init];
    }
    return calendarManager;
}

- (id)init
{
    self = [super init];
    if (self) {
        _dataList = [NSMutableArray array];
    }
    return self;
}

-(void)setGoogleImage: (DetailCostObject *)detail {
    [self performSelector:@selector(search:) withObject:detail afterDelay:0.0];
}

-(void)search: (DetailCostObject *)detail{
    NSString *year = [detail.date substringWithRange:NSMakeRange(0,4)];
    NSString *month = [detail.date substringWithRange:NSMakeRange(5,2)];
    NSString *day = [detail.date substringWithRange:NSMakeRange(8,2)];
    NSString *hour = [detail.date substringWithRange:NSMakeRange(11,2)];
    NSString *minute = [detail.date substringWithRange:NSMakeRange(14,2)];
    NSString *second = [detail.date substringWithRange:NSMakeRange(17,2)];
    NSString *time = [NSString stringWithFormat:@"%@%@%@%@%@%@", year, month, day, hour, minute, second];
    NSString *path = [NSString stringWithFormat:@"%@/%@%@%@", [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"], time, detail.code, @"_1.jpg"];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    // ファイルが存在するか?
    if ([fileManager fileExistsAtPath:path]) {
        return;
    }
    
    // google
    NSString *keyword = detail.name;
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    NSString *urlBaseString = @"http://ajax.googleapis.com/ajax/services/search/images?v=1.0&hl=ja&q=%@";
    NSString *urlString = [NSString stringWithFormat:urlBaseString, keyword];
    NSURL *url = [NSURL URLWithString:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:nil  ];
    
    NSURLSessionDataTask *jsonData = [session dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (!error) {
            NSHTTPURLResponse *httpResp = (NSHTTPURLResponse *) response;
            if (httpResp.statusCode == 200) {
                NSLog(@"success!");
                NSError *jsonError;
                
                NSDictionary *rawJSON = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&jsonError];
                
                NSMutableArray *array = [NSMutableArray array];
                if (!jsonError) {
                    NSDictionary *responseData = rawJSON[@"responseData"];
                    if ([responseData isKindOfClass:[NSDictionary class]]) {
                        NSArray *results = responseData[@"results"];
                        for (NSDictionary *result in results) {
                            NSString *imageURL = result[@"url"];
                            [array addObject:imageURL];
                        }
                        if (array != nil && array.count != 0) {
                            NSURL *url = [NSURL URLWithString:[array objectAtIndex:0]];
                            NSData *imageData = [NSData dataWithContentsOfURL:url];
                            UIImage *image = [UIImage imageWithData:imageData];
                            
                            NSData *dataImage = UIImageJPEGRepresentation(image, 0.8f);
                            [dataImage writeToFile:path atomically:YES];
                        }
                        
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
                        });
                    }
                }
            }
        }
    }];
    [jsonData resume];
}

@end

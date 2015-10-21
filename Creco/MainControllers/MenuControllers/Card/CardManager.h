//
//  CardManager.h
//  Creco
//
//  Created by 于　超 on 2015/07/08.
//  Copyright (c) 2015年 Windward. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CardManager : NSObject

+ (CardManager *)sharedManager;

@property (nonatomic) NSMutableArray *colorArray;
@property (nonatomic) NSString *color;
@property (nonatomic) int index;

-(void)setColor:(NSString *)color;

@end

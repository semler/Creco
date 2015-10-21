//
//  DB.h
//  Help_Help
//
//  Created by Windward on 13-5-10.
//  Copyright (c) 2013年 Windward. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDatabase.h"
#import "FMDatabaseAdditions.h"

@interface DB : NSObject

+ (FMDatabase *)getInstance;
+ (void)close;

@end

//
//  RequestManager.h
//  Creco
//
//  Created by Windward on 14/9/20.
//  Copyright (c) 2014年 Windward. All rights reserved.
//

#import "AFHTTPRequestOperationManager.h"

@interface RequestManager : AFHTTPRequestOperationManager

+ (instancetype)manager;

+ (void)requestPath:(NSString *)path
         parameters:(NSDictionary *)parameters
            success:(void (^)(AFHTTPRequestOperation *operation, id result))success
            failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;
@end

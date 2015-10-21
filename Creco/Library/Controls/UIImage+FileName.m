//
//  UIImage+FileName.m
//  Help_Help
//
//  Created by Windward on 14-1-23.
//  Copyright (c) 2014年 Windward. All rights reserved.
//

#import "UIImage+FileName.h"

//#pragma clang diagnostic push
//#pragma clang diagnostic ignored "-Wobjc-protocol-method-implementation"

@implementation UIImage (FileName)

+ (UIImage *)imageTopicNamed:(NSString *)imageName
{
    imageName = [imageName stringByAppendingFormat:@"_%@", [[NSUserDefaults standardUserDefaults] valueForKey:kAppTopicColor]];
    return [UIImage imageNamed:imageName];
}

@end
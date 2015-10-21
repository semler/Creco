//
//  ShareMethods.h
//  Help_Help
//
//  Created by Windward on 13-5-6.
//  Copyright (c) 2013年 Windward. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ShareMethods : NSObject

+ (void)showAlertBy:(NSString *)str;
+ (void)showExplainWithContent:(NSString *)content andTitle:(NSString *)title;
+ (BOOL)judgeUserNameFormat:(NSString *)userStr;
+ (BOOL)judgePasswordFormat:(NSString *)password;
+ (BOOL)isHasCamera;
+ (UIImage *)fixOrientation:(UIImage *)aImage;
+ (UIImage *)scaleImage:(UIImage *)image toWidth:(int)toWidth toHeight:(int)toHeight;
+ (UIImage *)createImageWithColor:(UIColor *)color size:(CGSize)size;
+ (UIColor *)colorFromHexRGB:(NSString *)inColorString;

+ (UIImage *)getOverlappingImageByArray:(NSMutableArray *)imgArr;

+ (NSString *)moneyStrToDecimal:(NSString *)str;

@end


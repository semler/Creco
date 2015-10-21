//
//  ShareMethods.m
//  Help_Help
//
//  Created by Windward on 13-5-6.
//  Copyright (c) 2013年 Windward. All rights reserved.
//

#import "ShareMethods.h"
#import "CommonCrypto/CommonDigest.h" /***FOR SHA1 ***/

@implementation ShareMethods

//show alert with message
+ (void)showAlertBy:(NSString *)str
{
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle:str
                          message:nil
                          delegate:nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil];
    [alert show];
}

//show alert with title and content
+ (void)showExplainWithContent:(NSString *)content andTitle:(NSString *)title
{
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
													message:content
												   delegate:nil
										  cancelButtonTitle:@"OK"
										  otherButtonTitles:nil];
	[alert show];
}

//judge user format
+ (BOOL)judgeUserNameFormat:(NSString *)userStr
{
    NSString *emailReg = @"[A-Z0-9a-z_.]+@[A-Za-z0-9_.]+\\.[A-Za-z]{2,4}";
	NSPredicate *emailCheck = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailReg];
    
    NSString *phoneReg = @"1[3|5|8]\\d{9}";
	NSPredicate *phoneCheck = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", phoneReg];
    
    if ([emailCheck evaluateWithObject:userStr] || [phoneCheck evaluateWithObject:userStr])
        return YES;
    else
        return NO;
}

//judge password format
+ (BOOL)judgePasswordFormat:(NSString *)password
{
    NSString *passwordReg = @"[A-Z0-9a-z_@.]{3,26}";
	NSPredicate *passwordCheck = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", passwordReg];
    
    if ([passwordCheck evaluateWithObject:password])
        return YES;
    else
        return NO;
}

//judge has camera or not
+ (BOOL)isHasCamera
{
	if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
		return YES;
	} else {
		return NO;
	}
}

//change image orientation to right orientation
+ (UIImage *)fixOrientation:(UIImage *)aImage
{
    if (aImage==nil || !aImage) {
        return nil;
    }
    // No-op if the orientation is already correct
    if (aImage.imageOrientation == UIImageOrientationUp)
        return aImage;
    
    // We need to calculate the proper transformation to make the image upright.
    // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
    CGAffineTransform transform = CGAffineTransformIdentity;
    UIImageOrientation orientation=aImage.imageOrientation;
    int orientation_=orientation;
    switch (orientation_) {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, aImage.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, aImage.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
    }
    
    switch (orientation_) {
        case UIImageOrientationUpMirrored:{
            
        }
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
    }
    
    // Now we draw the underlying CGImage into a new context, applying the transform
    // calculated above.
    CGContextRef ctx = CGBitmapContextCreate(NULL, aImage.size.width, aImage.size.height,
                                             CGImageGetBitsPerComponent(aImage.CGImage), 0,
                                             CGImageGetColorSpace(aImage.CGImage),
                                             CGImageGetBitmapInfo(aImage.CGImage));
    CGContextConcatCTM(ctx, transform);
    switch (aImage.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            // Grr...
            CGContextDrawImage(ctx, CGRectMake(0,0,aImage.size.height,aImage.size.width), aImage.CGImage);
            break;
            
        default:
            CGContextDrawImage(ctx, CGRectMake(0,0,aImage.size.width,aImage.size.height), aImage.CGImage);
            break;
    }
    
    // And now we just create a new UIImage from the drawing context
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    aImage=img;
    img=nil;
    
    return aImage;
}
//

#pragma mark - image scale utility -

+ (UIImage *)scaleImage:(UIImage *)image toWidth:(int)toWidth toHeight:(int)toHeight
{
    if (image.size.width <= toWidth && image.size.height <= toHeight)
        return image;
    
    CGSize originalSize = image.size;
    CGSize newSize;
    
    if (originalSize.width >= originalSize.height) {
        newSize.width = toWidth;
        newSize.height = toWidth/originalSize.width*originalSize.height;
    }else
    {
        newSize.height = toHeight;
        newSize.width = toHeight/originalSize.height*originalSize.width;
    }
	
    UIGraphicsBeginImageContext(newSize);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return scaledImage;
}

//Create Image By Color
+ (UIImage *)createImageWithColor:(UIColor *)color size:(CGSize)size
{
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

//Create UIColor form HexString
+ (UIColor *) colorFromHexRGB:(NSString *) inColorString
{
    UIColor *result = nil;
    unsigned int colorCode = 0;
    unsigned char redByte, greenByte, blueByte;
    
    if (nil != inColorString)
    {
        NSScanner *scanner = [NSScanner scannerWithString:inColorString];
        (void) [scanner scanHexInt:&colorCode]; // ignore error
    }
    redByte = (unsigned char) (colorCode >> 16);
    greenByte = (unsigned char) (colorCode >> 8);
    blueByte = (unsigned char) (colorCode); // masks off high bits
    result = [UIColor
              colorWithRed: (float)redByte / 0xff
              green: (float)greenByte/ 0xff
              blue: (float)blueByte / 0xff
              alpha:1.0];
    return result;
}

+ (UIImage *)getOverlappingImageByArray:(NSMutableArray *)imgArr
{
    if (imgArr.count == 0) {
        return nil;
    }
    
    if (imgArr.count > 3) {
        [imgArr removeObjectsInRange:NSMakeRange(3, imgArr.count-3)];
    }else if (imgArr.count < 3)
    {
        [imgArr addObject:[UIImage imageNamed:@"small_no_card"]];
        if (imgArr.count < 3)
            [imgArr addObject:[UIImage imageNamed:@"small_no_card"]];
    }
    
    CGFloat x = 0.f;
    CGFloat y = 0.f;
    CGFloat padding = 12.f;
    
    UIImageView *beforeCardImgView = nil;
    UIView *overlappingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    for (int i = 0; i < imgArr.count; i ++)
    {
        UIImage *cardImg = imgArr[i];
        UIImageView *cardImgView = [[UIImageView alloc] initWithFrame:CGRectMake(x, y, cardImg.size.width, cardImg.size.height)];
        cardImgView.image = cardImg;
        cardImgView.userInteractionEnabled = YES;
        if (beforeCardImgView)
            [overlappingView insertSubview:cardImgView belowSubview:beforeCardImgView];
        else
            [overlappingView addSubview:cardImgView];
        beforeCardImgView = cardImgView;
        
        if (i != imgArr.count - 1) {
            x = x+padding;
            y = y-padding;
        }
    }
    
    UIImage *placeholderImg = [UIImage imageNamed:@"small_no_card"];
    overlappingView.frame = CGRectMake(0, 0, x+placeholderImg.size.width, -y+placeholderImg.size.height);
    ;
    
    for (UIImageView *cardImageView in overlappingView.subviews)
        cardImageView.frame = CGRectMake(cardImageView.left, cardImageView.top+padding*(imgArr.count-1), cardImageView.width, cardImageView.height);
    
    UIGraphicsBeginImageContextWithOptions(overlappingView.frame.size, NO, Is_iPhone6_Plus ? 3.f : 2.f);
    [overlappingView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *overlappingImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    TDLog(@"Changed Image Size:%@", NSStringFromCGSize(overlappingImage.size));
    return overlappingImage;
}

+ (NSString *)moneyStrToDecimal:(NSString *)str
{
    NSString *str1 = nil;
    NSString *str2 = nil;
    NSString *returnStr = nil;
    
    str = [str stringByReplacingOccurrencesOfString:@"," withString:@""];
    if ([str rangeOfString:@"."].length != 0) {
        NSArray *strArray = [str componentsSeparatedByString:@"."];
        str1 = [strArray objectAtIndex:0];
        str2 = [strArray objectAtIndex:1];
    } else {
        str1 = str;
    }
    
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
    returnStr = [formatter stringFromNumber:[NSNumber numberWithDouble:[str1 doubleValue]]];
    
    if (str2) returnStr = [returnStr stringByAppendingString:[NSString stringWithFormat:@".%@",str2]];
    
    return returnStr;
}

@end

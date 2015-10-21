//
//  CatSayView.h
//  Creco
//
//  Created by Windward on 15/5/20.
//  Copyright (c) 2015年 Windward. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CatSayView : UIView
@property (nonatomic, strong) NSString *sayWord;
- (void)say:(NSString *)word;
- (void)say:(NSString *)word withImage:(UIImage *)catImg;
@end

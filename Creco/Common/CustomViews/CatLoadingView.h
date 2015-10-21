//
//  CatLoadingView.h
//  Creco
//
//  Created by Windward on 15/5/21.
//  Copyright (c) 2015年 Windward. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CatLoadingView : UIView

+ (CatLoadingView *)addIntoTheView:(UIView *)superView ByWordStr:(NSString *)wordStr andWithPoint:(CGPoint)point;

- (void)start;
- (void)stop;

@end

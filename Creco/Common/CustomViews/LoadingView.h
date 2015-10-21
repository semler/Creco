//
//  Created by Windward on 11-12-6.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface LoadingView : UIView

@property (nonatomic, strong) UILabel *textLabel;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicatorView;

- (id)initWithFrame:(CGRect)frame titleStr:(NSString *)string;

@end

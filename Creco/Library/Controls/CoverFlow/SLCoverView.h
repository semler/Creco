//
//  SLCoverView.h
//  SLCoverFlow
//
//  Created by SmartCat on 13-6-19.
//  Copyright (c) 2013年 SmartCat. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserCardObject.h"

@interface SLCoverView : UIView

// the cover image view
@property (nonatomic, strong, readonly) UIImageView *imageView;

- (id)initWithFrame:(CGRect)frame andUserCardObject:(UserCardObject *)userCardObj;

@end

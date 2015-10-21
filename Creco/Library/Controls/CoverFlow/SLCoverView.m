//
//  SLCoverView.m
//  SLCoverFlow
//
//  Created by SmartCat on 13-6-19.
//  Copyright (c) 2013年 SmartCat. All rights reserved.
//

#import "SLCoverView.h"
#import <QuartzCore/QuartzCore.h>
#import "UserCardObject.h"

@interface SLCoverView ()
{
    BOOL isFront;
    
    UIImage *originImage;
    
    UserCardObject *nowUserCardObj;
    
    UITextView *memoLabel;
}
@end
@implementation SLCoverView

- (id)initWithFrame:(CGRect)frame andUserCardObject:(UserCardObject *)userCardObj
{
    self = [super initWithFrame:frame];
    if (self) {
        nowUserCardObj = userCardObj;
        
        _imageView = [[UIImageView alloc] initWithFrame:self.bounds];
        _imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        _imageView.userInteractionEnabled = YES;
        [self addSubview:_imageView];
        
        if (userCardObj) {
            memoLabel = [[UITextView alloc] init];
            memoLabel.textAlignment = NSTextAlignmentCenter;
            memoLabel.textColor = [ShareMethods colorFromHexRGB:@"505050"];
            memoLabel.font = [UIFont systemFontOfSize:10];
            memoLabel.alpha = 0.f;
            memoLabel.text = userCardObj.memo;
            memoLabel.editable = NO;
            [_imageView addSubview:memoLabel];
            
            UITapGestureRecognizer *singleRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTapFrom)];
            singleRecognizer.numberOfTapsRequired = 1;
            [self addGestureRecognizer:singleRecognizer];
        }
        
        isFront = YES;
    }
    return self;
}

- (void)handleSingleTapFrom
{    
    if (!originImage)
        originImage = self.imageView.image;
    
    if (memoLabel.width == 0 || memoLabel.height == 0)
        memoLabel.frame = CGRectMake(5.f, 18.f, _imageView.width-10.f, _imageView.height-30.f);
    
    memoLabel.alpha = isFront;
    
    [UIView transitionWithView:self duration:0.7f options:(isFront ? UIViewAnimationOptionTransitionFlipFromRight : UIViewAnimationOptionTransitionFlipFromLeft) | UIViewAnimationOptionCurveEaseOut animations:^{
        self.imageView.image = isFront ? [UIImage imageNamed:@"card_behind"] : originImage;
    } completion:^(BOOL finished) {
        isFront = !isFront;
    }];
}

@end

//
//  HowToUseScrollView.m
//  Creco
//
//  Created by Windward on 14/12/1.
//  Copyright (c) 2014年 Windward. All rights reserved.
//

#import "HowToUseScrollView.h"
#import "PWSettingViewController.h"

@implementation HowToUseScrollView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        self.showsHorizontalScrollIndicator = NO;
        self.showsVerticalScrollIndicator = NO;
        self.pagingEnabled = YES;
        self.bounces = NO;
        self.delegate = self;
        
        for (int i = 0; i < 5; i ++)
        {
            UIImageView *guideImageView = [[UIImageView alloc] initWithFrame:CGRectMake(frame.size.width*i, 0, frame.size.width, frame.size.height)];
            guideImageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"tutorial_%d", i+1]];
            guideImageView.userInteractionEnabled = YES;
            [self addSubview:guideImageView];
        }
        
        self.contentSize = CGSizeMake(frame.size.width*6/*important*/, frame.size.height);
    }
    return self;
}

#pragma mark - UIScrollView Delegate -

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat pageWidth = scrollView.frame.size.width;
    int page = floor((scrollView.contentOffset.x - pageWidth/2)/pageWidth) + 1;
    if (page == 5 && scrollView.contentOffset.x == self.width*5)
    {
        [self setHidden:YES];
        [[UIApplication sharedApplication] setStatusBarHidden:NO];
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end

//
//  CatLoadingView.m
//  Creco
//
//  Created by Windward on 15/5/21.
//  Copyright (c) 2015年 Windward. All rights reserved.
//

#import "CatLoadingView.h"
#define kMoveAnimationSecond    2.f

@interface CatLoadingView ()
@property (nonatomic, strong) NSMutableArray *catMoveUpImageViewsArr;
@property (nonatomic) NSInteger nowShowIndex;
@end

@implementation CatLoadingView

+ (CatLoadingView *)addIntoTheView:(UIView *)superView ByWordStr:(NSString *)wordStr andWithPoint:(CGPoint)point
{
    UIImage *catImage = [UIImage imageNamed:@"cat_loading_1_up"];
    CatLoadingView *catLoadingView = [[CatLoadingView alloc] initWithFrame:CGRectMake(point.x, point.y, superView.width, catImage.size.height)];
    [superView addSubview:catLoadingView];
    
    catLoadingView.catMoveUpImageViewsArr = [NSMutableArray array];
 
    CGFloat updateLabelWidth = 60.f;
    CGFloat padding = ((superView.width-updateLabelWidth)-(catImage.size.width*8))/8;
    CGFloat theX = padding;
    for (int i = 1; i <= 8; i ++)
    {
        UIImage *normalImage = [UIImage imageNamed:[NSString stringWithFormat:@"cat_loading_%d", i]];
        UIImage *moveUpImage = [UIImage imageNamed:[NSString stringWithFormat:@"cat_loading_%d_up", i]];
        UIImageView *catMoveUpImageView = [[UIImageView alloc] initWithFrame:CGRectMake(theX, 0, moveUpImage.size.width, moveUpImage.size.height)];
        catMoveUpImageView.contentMode = UIViewContentModeScaleAspectFit;
        catMoveUpImageView.clipsToBounds = YES;
        catMoveUpImageView.animationImages = @[moveUpImage, normalImage];
        catMoveUpImageView.animationDuration = kMoveAnimationSecond;
        catMoveUpImageView.image = normalImage;
        catMoveUpImageView.animationRepeatCount = 1;
        catMoveUpImageView.hidden = YES;
        [catLoadingView addSubview:catMoveUpImageView];
        
        [catLoadingView.catMoveUpImageViewsArr addObject:catMoveUpImageView];
        
        if (i == 4) {
            UILabel *updateWordLabel = [[UILabel alloc] initWithFrame:CGRectMake(catMoveUpImageView.right, 0, updateLabelWidth, catMoveUpImageView.height)];
            updateWordLabel.text = wordStr;
            updateWordLabel.textAlignment = NSTextAlignmentCenter;
            updateWordLabel.textColor = [ShareMethods colorFromHexRGB:@"505050"];
            updateWordLabel.font = [UIFont systemFontOfSize:12];
            [catLoadingView addSubview:updateWordLabel];
            
            theX = updateWordLabel.right;
        } else {
            theX = padding+catMoveUpImageView.right;
        }
    }
    
    return catLoadingView;
}

- (void)start
{
    if (self.hidden) self.hidden = NO;
    
    if (self.nowShowIndex < [self.catMoveUpImageViewsArr count])
    {
        UIImageView *catMoveUpImageView = [self.catMoveUpImageViewsArr objectAtIndex:self.nowShowIndex];
        catMoveUpImageView.hidden = NO;
        [catMoveUpImageView startAnimating];
        
        [catMoveUpImageView performSelector:@selector(stopAnimating) withObject:nil afterDelay:kMoveAnimationSecond];
        self.nowShowIndex ++;
        [self performSelector:@selector(start) withObject:nil afterDelay:self.nowShowIndex == self.catMoveUpImageViewsArr.count ?kMoveAnimationSecond : kMoveAnimationSecond/2];
    }else
    {
        for (UIImageView *catMoveUpImageView in self.catMoveUpImageViewsArr)
        {
            [catMoveUpImageView startAnimating];
            [catMoveUpImageView performSelector:@selector(stopAnimating) withObject:nil afterDelay:kMoveAnimationSecond/2];
            [self performSelector:@selector(setCatMoveUpImageViewToHidden:) withObject:catMoveUpImageView afterDelay:kMoveAnimationSecond/2];
        }
        
        self.nowShowIndex = 0;
        [self performSelector:@selector(start) withObject:nil afterDelay:kMoveAnimationSecond];
    }
}

- (void)setCatMoveUpImageViewToHidden:(UIImageView *)catMoveUpImageView
{
    [catMoveUpImageView setHidden:YES];
}

- (void)stop
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    
    self.hidden = YES;
    for (UIImageView *catMoveUpImageView in self.catMoveUpImageViewsArr)
    {
        [catMoveUpImageView stopAnimating];
        catMoveUpImageView.hidden = YES;
    }
    
    self.nowShowIndex = 0;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end

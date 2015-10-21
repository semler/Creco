//
//  CatSayView.m
//  Creco
//
//  Created by Windward on 15/5/20.
//  Copyright (c) 2015年 Windward. All rights reserved.
//

#import "CatSayView.h"

@interface CatSayView ()
{
    UIImageView *catImageView;
    UIImageView *wordBoxImageView;
    UILabel *wordLabel;
    
    CGPoint catPiont;
}
@end
@implementation CatSayView

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        UIImage *cateImage = [UIImage imageTopicNamed:@"cat_1"];
        catImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 10.f, cateImage.size.width, cateImage.size.height)];
        catImageView.image = cateImage;
        catImageView.userInteractionEnabled = YES;
        [self addSubview:catImageView];
        
        UIImage *wordBoxImage = [UIImage imageNamed:@"chara_say_box"];
        wordBoxImageView = [[UIImageView alloc] initWithFrame:CGRectMake(catImageView.right+5.f, 0, wordBoxImage.size.width, wordBoxImage.size.height)];
        wordBoxImageView.image = wordBoxImage;
        wordBoxImageView.userInteractionEnabled = YES;
        wordBoxImageView.contentMode = UIViewContentModeScaleAspectFill;
        wordBoxImageView.clipsToBounds = YES;
        [self addSubview:wordBoxImageView];
        
        wordLabel = [[UILabel alloc] initWithFrame:CGRectMake(25.f, 0, wordBoxImageView.width-40.f, wordBoxImageView.height)];
        wordLabel.numberOfLines = 2;
        wordLabel.font = [UIFont boldSystemFontOfSize:12];
        wordLabel.textColor = [ShareMethods colorFromHexRGB:@"636363"];
        wordLabel.adjustsFontSizeToFitWidth = YES;
        [wordBoxImageView addSubview:wordLabel];
        
        catPiont = catImageView.center;
    }
    return self;
}

- (void)say:(NSString *)word
{
    self.sayWord = word;
    
    if (word.length > 0)
    {
        wordLabel.text = word;
        catImageView.center = catPiont;
        wordBoxImageView.hidden = NO;
    }else
    {
        catImageView.image = [UIImage imageTopicNamed:@"cat_1"];
        catImageView.center = CGPointMake(self.width/2, catPiont.y-6);
        wordBoxImageView.hidden = YES;
    }
}

- (void)say:(NSString *)word withImage:(UIImage *)catImg
{
    [self say:word];
    if (catImg) catImageView.image = catImg;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end

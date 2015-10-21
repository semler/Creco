//
//  NewsCell.m
//  Creco
//
//  Created by Windward on 15/6/15.
//  Copyright (c) 2015年 Windward. All rights reserved.
//

#import "NewsCell.h"

@interface NewsCell ()
{
    UIImageView *newsIconImgView;
    UILabel *titleLabel;
    UIView *contentDataView;
    UILabel *contentLabel;
    UILabel *dateLabel;
    UILabel *lineLabel;
    UIButton *upOrDownBtn;
    
    NewsObject *nowNewsObj;
}
@end
@implementation NewsCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        UIImage *newsImg = [UIImage imageNamed:@"news_icon"];
        newsIconImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, newsImg.size.width, newsImg.size.height)];
        newsIconImgView.userInteractionEnabled = YES;
        newsIconImgView.image = newsImg;
        [self.contentView addSubview:newsIconImgView];
        
        CGFloat leftPaddingX = 19.f;
        CGFloat rightPaddingX = 16.f;
        titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(leftPaddingX, kNewsCellDefaultPaddingY, kNewsCellContentWidth, kNewsCellContentDefaultHeight)];
        titleLabel.numberOfLines = 2;
        titleLabel.font = [UIFont boldSystemFontOfSize:14];
        titleLabel.textColor = [ShareMethods colorFromHexRGB:@"555555"];
        [self.contentView addSubview:titleLabel];
        
        dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(titleLabel.left, titleLabel.bottom, 100, 20.f)];
        dateLabel.font = [UIFont systemFontOfSize:10];
        dateLabel.textColor = [ShareMethods colorFromHexRGB:@"7e8699"];
        [self.contentView addSubview:dateLabel];
        
        contentDataView = [[UIView alloc] initWithFrame:CGRectMake(0, kDefaultNewsCellHeight, kAllViewWidth, 0)];
        contentDataView.backgroundColor = kRGBColor(227, 230, 231, 1.f);
        contentDataView.layer.borderWidth = 0.5f;
        contentDataView.layer.borderColor = COLOR_LINE.CGColor;
        [self.contentView addSubview:contentDataView];
        
        contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(titleLabel.left, titleLabel.top, kAllViewWidth-titleLabel.left*2, 0)];
        contentLabel.numberOfLines = 0;
        contentLabel.font = [UIFont systemFontOfSize:13];
        contentLabel.textColor = [ShareMethods colorFromHexRGB:@"555555"];
        [contentDataView addSubview:contentLabel];
        
        lineLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, kDefaultNewsCellHeight-0.5f, kAllViewWidth, 0.5f)];
        lineLabel.backgroundColor = COLOR_LINE;
        [self.contentView addSubview:lineLabel];
        
        UIImage *downImg = [UIImage imageNamed:@"btn_down"];
        upOrDownBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        upOrDownBtn.frame = CGRectMake(kAllViewWidth-rightPaddingX-downImg.size.width*2, (kDefaultNewsCellHeight-downImg.size.height*4)/2, downImg.size.width*3, downImg.size.height*4);
        [upOrDownBtn setImage:downImg forState:UIControlStateNormal];
        [upOrDownBtn setImage:[UIImage imageNamed:@"btn_up"] forState:UIControlStateSelected];
        [upOrDownBtn addTarget:self action:@selector(showOrHiddenAllWord) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:upOrDownBtn];
    }
    return self;
}

- (void)showOrHiddenAllWord
{
    upOrDownBtn.selected = !upOrDownBtn.selected;
    nowNewsObj.isShowAllWord = !nowNewsObj.isShowAllWord;
    lineLabel.hidden = nowNewsObj.isShowAllWord;
    contentDataView.hidden = !nowNewsObj.isShowAllWord;
    [(UITableView *)self.superview.superview reloadData];
    
    if (nowNewsObj.isShowAllWord) {
        if (![InfoRead getMessageIsReadOrNotByCode:nowNewsObj.code]) {
            [InfoRead updateInfoReadInDBByCode:nowNewsObj.code andIsRead:1];
            newsIconImgView.hidden = YES;
            
            kAppDelegate.appTabBarVC.menuTabbarItem.badgeValue = [InfoRead getUnReadMessageCount] > 0 ? @"N" : nil;
        }
        
        contentDataView.frame = CGRectMake(contentDataView.left, contentDataView.top, contentDataView.width, nowNewsObj.contentHeight+kNewsCellDefaultPaddingY*2);
        contentLabel.frame = CGRectMake(contentLabel.left, contentLabel.top, contentLabel.width, nowNewsObj.contentHeight);
    }else
    {
        contentDataView.frame = CGRectMake(contentDataView.left, contentDataView.top, contentDataView.width, 0);
        contentLabel.frame = CGRectMake(contentLabel.left, contentLabel.top, contentLabel.width, 0);
    }
}

- (void)setNewsDataBy:(NewsObject *)newsObject
{
    nowNewsObj = newsObject;
    
    titleLabel.text = newsObject.title;
    contentLabel.text = newsObject.content;
    dateLabel.text = newsObject.modified;
    upOrDownBtn.selected = newsObject.isShowAllWord;
    lineLabel.hidden = newsObject.isShowAllWord;
    contentDataView.hidden = !newsObject.isShowAllWord;
    
    if (newsObject.isShowAllWord)
    {
        contentDataView.frame = CGRectMake(contentDataView.left, contentDataView.top, contentDataView.width, newsObject.contentHeight+kNewsCellDefaultPaddingY*2);
        contentLabel.frame = CGRectMake(contentLabel.left, contentLabel.top, contentLabel.width, newsObject.contentHeight);
    }else
    {
        contentDataView.frame = CGRectMake(contentDataView.left, contentDataView.top, contentDataView.width, 0);
        contentLabel.frame = CGRectMake(contentLabel.left, contentLabel.top, contentLabel.width, 0);
    }
    
    CGFloat cellHeight = kDefaultNewsCellHeight;
    if (newsObject.isShowAllWord)
        cellHeight = kDefaultNewsCellHeight+newsObject.contentHeight-kNewsCellContentDefaultHeight;

    newsIconImgView.hidden = [InfoRead getMessageIsReadOrNotByCode:newsObject.code];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end

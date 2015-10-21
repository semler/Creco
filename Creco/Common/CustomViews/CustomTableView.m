//
//  CustomTableView.m
// 
//  Version 1.0
//
//  Created by hsit on 12-1-30.
//  Copyright (c) 2012年 QQ:115940737. All rights reserved.
//

#import "CustomTableView.h"
#import <QuartzCore/QuartzCore.h>

@implementation StateView

@synthesize indicatorView;
@synthesize arrowView;
@synthesize stateLabel;
@synthesize timeLabel;
@synthesize viewType;
@synthesize currentState;

- (id)initWithFrame:(CGRect)frame viewType:(int)type{
    CGFloat width = frame.size.width;
    
    self = [super initWithFrame:CGRectMake(frame.origin.x, frame.origin.y, width, k_STATE_VIEW_HEIGHT)];
    
    if (self) {
        viewType = type == k_VIEW_TYPE_HEADER ? k_VIEW_TYPE_HEADER : k_VIEW_TYPE_FOOTER;
        self.backgroundColor = [UIColor clearColor];
        
        indicatorView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake((k_STATE_VIEW_INDICATE_WIDTH - 20) / 2, (k_STATE_VIEW_HEIGHT - 20) / 2, 20, 20)];
        indicatorView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
        indicatorView.hidesWhenStopped = YES;
        [self addSubview:indicatorView];
        
        arrowView = [[UIImageView alloc] init];
        NSString * imageNamed = type == k_VIEW_TYPE_HEADER ? @"arrow_down" : @"arrow_up";
        arrowView.image = [UIImage imageNamed:imageNamed];
        arrowView.frame = CGRectMake((k_STATE_VIEW_INDICATE_WIDTH - arrowView.image.size.width) / 2, (k_STATE_VIEW_HEIGHT - arrowView.image.size.height) / 2, arrowView.image.size.width, arrowView.image.size.height);
        [self addSubview:arrowView];
        
        stateLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, width, 20)];
        stateLabel.font = [UIFont systemFontOfSize:12.0f];
        stateLabel.backgroundColor = [UIColor clearColor];
        stateLabel.textAlignment = NSTextAlignmentCenter;
        stateLabel.text = type == k_VIEW_TYPE_HEADER ? @"プルダウンで更新..." : @"Load more";
        [self addSubview:stateLabel];
        
        timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 20, width, k_STATE_VIEW_HEIGHT - 20)];
        timeLabel.font = [UIFont systemFontOfSize:12.0f];
        timeLabel.backgroundColor = [UIColor clearColor];
        timeLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:timeLabel];
        [self updateTimeLabel];
    }
    return self;
}

- (void)changeState:(int)state{
    [indicatorView stopAnimating];
    arrowView.hidden = NO;
    [UIView beginAnimations:nil context:nil];
    switch (state) {
        case k_PULL_STATE_NORMAL:
            currentState = k_PULL_STATE_NORMAL;
            stateLabel.text = viewType == k_VIEW_TYPE_HEADER ? @"プルダウンで更新..." : @"上拖加载更多";
            arrowView.layer.transform = CATransform3DMakeRotation(M_PI * 2, 0, 0, 1);
            break;
        case k_PULL_STATE_DOWN:
            currentState = k_PULL_STATE_DOWN;
            stateLabel.text = @"指を離すと更新...";
            arrowView.layer.transform = CATransform3DMakeRotation(M_PI, 0, 0, 1);
            break;
            
        case k_PULL_STATE_UP:
            currentState = k_PULL_STATE_UP;
            stateLabel.text = @"指を離すと更新...";
            arrowView.layer.transform = CATransform3DMakeRotation(M_PI, 0, 0, 1);
            break;
            
        case k_PULL_STATE_LOAD:
            currentState = k_PULL_STATE_LOAD;
            stateLabel.text = viewType == k_VIEW_TYPE_HEADER ? @"更新中..." : @"更新中...";
            [indicatorView startAnimating];
            arrowView.hidden = YES;
            break;
            
        case k_PULL_STATE_END:
            currentState = k_PULL_STATE_END;
            stateLabel.text = viewType == k_VIEW_TYPE_HEADER ? stateLabel.text : @"";//@"已加载全部数据";
            arrowView.hidden = YES;
            break;
            
        default:
            currentState = k_PULL_STATE_NORMAL;
            stateLabel.text = viewType == k_VIEW_TYPE_HEADER ? @"プルダウンで更新..." : @"上拖加载更多";
            arrowView.layer.transform = CATransform3DMakeRotation(M_PI * 2, 0, 0, 1);
            break;
    }
    [UIView commitAnimations];
}

- (void)updateTimeLabel{
    NSDate * date = [NSDate date];
    NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterFullStyle];
    [formatter setDateFormat:@"yy/MM/dd HH:mm"];
    timeLabel.text = [NSString stringWithFormat:@"最終更新: %@", [formatter stringFromDate:date]];
}

@end

#define kDefaultBeginPage   0

@implementation CustomTableView
{
    UIImageView *timeoutImageView;
    UIImageView *failedImageView;
    UILabel *noDataLabel;
}
@synthesize page;
@synthesize resultData;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        headerView = [[StateView alloc] initWithFrame:CGRectMake(0, -40, frame.size.width, frame.size.height) viewType:k_VIEW_TYPE_HEADER];
        footerView = [[StateView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height) viewType:k_VIEW_TYPE_FOOTER];
        footerView.hidden = YES;
        [self addSubview:headerView];
        [self setTableFooterView:footerView];
        
        UIImage *failedImage = [UIImage imageNamed:@"failed"];
        failedImageView = [[UIImageView alloc] initWithFrame:CGRectMake((self.width-failedImage.size.width)/2, (self.height-failedImage.size.height)/2, failedImage.size.width, failedImage.size.height)];
        failedImageView.image = failedImage;
        failedImageView.hidden = YES;
        failedImageView.userInteractionEnabled = YES;
        [self addSubview:failedImageView];
        
        UIImage *timeoutImage = [UIImage imageNamed:@"timeout"];
        timeoutImageView = [[UIImageView alloc] initWithFrame:CGRectMake((self.width-timeoutImage.size.width)/2, (self.height-timeoutImage.size.height)/2, timeoutImage.size.width, timeoutImage.size.height)];
        timeoutImageView.image = timeoutImage;
        timeoutImageView.hidden = YES;
        timeoutImageView.userInteractionEnabled = YES;
        [self addSubview:timeoutImageView];
        
        noDataLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.width, 40)];
        noDataLabel.text = @"記事はまだありません";
        noDataLabel.center = timeoutImageView.center;
        noDataLabel.textAlignment = NSTextAlignmentCenter;
        noDataLabel.backgroundColor = [UIColor clearColor];
        noDataLabel.hidden = YES;
        [self addSubview:noDataLabel];
        
        page = kDefaultBeginPage;
    }
    return self;
}

- (void)tableViewDidDragging
{
    CGFloat offsetY = self.contentOffset.y;
    
    if (headerView.currentState == k_PULL_STATE_LOAD ||
        footerView.currentState == k_PULL_STATE_LOAD) {
        return;
    }
    
    if (offsetY < -k_STATE_VIEW_HEIGHT - 10) {
        [headerView changeState:k_PULL_STATE_DOWN];
    } else {
        [headerView changeState:k_PULL_STATE_NORMAL];
    }
    
    if (footerView.currentState == k_PULL_STATE_END) {
        return;
    }
    
    CGFloat height = self.frame.size.height+k_STATE_VIEW_HEIGHT;
    CGFloat contentOffSetY = self.contentOffset.y;
    CGFloat distanceFromBottom = self.contentSize.height-contentOffSetY;
    
    if (distanceFromBottom < height && (self.contentSize.height >= self.frame.size.height)) {
        [footerView changeState:k_PULL_STATE_UP];
    } else {
        [footerView changeState:k_PULL_STATE_NORMAL];
    }
}

- (int)tableViewDidEndDragging
{
    CGFloat offsetY = self.contentOffset.y;
    
    if (headerView.currentState == k_PULL_STATE_LOAD ||
        footerView.currentState == k_PULL_STATE_LOAD) {
        return k_RETURN_DO_NOTHING;
    }
    
    if (offsetY < -k_STATE_VIEW_HEIGHT - 10) {
        [headerView changeState:k_PULL_STATE_LOAD];
        [UIView animateWithDuration:0.2f animations:^{
            self.contentInset = UIEdgeInsetsMake(k_STATE_VIEW_HEIGHT, 0, 0, 0);
        }];
        noDataLabel.hidden = YES;
        timeoutImageView.hidden = YES;
        failedImageView.hidden = YES;
        return k_RETURN_REFRESH;
    }
    
    CGFloat height = self.frame.size.height+k_STATE_VIEW_HEIGHT;
    CGFloat contentOffSetY = self.contentOffset.y;
    CGFloat distanceFromBottom = self.contentSize.height-contentOffSetY;
    
    if (footerView.currentState != k_PULL_STATE_END && 
        distanceFromBottom < height && (self.contentSize.height >= self.frame.size.height)) {
        [footerView changeState:k_PULL_STATE_LOAD];
        return k_RETURN_LOADMORE;
    } 
    return k_RETURN_DO_NOTHING;
}

- (void)reloadData:(BOOL)dataIsAllLoaded
{
    noDataLabel.hidden = YES;
    timeoutImageView.hidden = YES;
    failedImageView.hidden = YES;
    
    [self reloadData];
    
    [UIView animateWithDuration:0.25f animations:^{
        self.contentInset = UIEdgeInsetsZero;
    } completion:^(BOOL finished) {
        [headerView changeState:k_PULL_STATE_NORMAL];
        
        footerView.hidden = NO;
        [footerView changeState:dataIsAllLoaded ? k_PULL_STATE_END : k_PULL_STATE_NORMAL];
        [self setTableFooterView:!dataIsAllLoaded ? footerView : nil];
        if (dataIsAllLoaded && self.resultData.count > 0) {
            /*
            footerView.userInteractionEnabled = NO;
            footerView.frame = CGRectMake(footerView.left, self.contentSize.height-12.f, footerView.width, footerView.height);
            [self addSubview:footerView];
            */
            footerView.hidden = YES;
        }
        
        [headerView updateTimeLabel];
        [footerView updateTimeLabel];
    }];
}

- (void)requestTimeout
{
    [self.resultData removeAllObjects];
    
    timeoutImageView.hidden = NO;
    noDataLabel.hidden = YES;
    failedImageView.hidden = YES;
    
    footerView.hidden = YES;
    [self reloadData];
    
    [UIView animateWithDuration:0.25f animations:^{
        self.contentInset = UIEdgeInsetsZero;
    } completion:^(BOOL finished) {
        [headerView changeState:k_PULL_STATE_NORMAL];
        [footerView changeState:k_PULL_STATE_NORMAL];
        
        [headerView updateTimeLabel];
        [footerView updateTimeLabel];
    }];
}

- (void)noData
{
    [self reloadData:YES];
    
    noDataLabel.hidden = NO;
    timeoutImageView.hidden = YES;
    failedImageView.hidden = YES;
}

- (void)requestFailed
{
    [self.resultData removeAllObjects];
    
    failedImageView.hidden = NO;
    timeoutImageView.hidden = YES;
    noDataLabel.hidden = YES;
    
    footerView.hidden = YES;
    [self reloadData];
    
    [UIView animateWithDuration:0.25f animations:^{
        self.contentInset = UIEdgeInsetsZero;
    } completion:^(BOOL finished) {
        [headerView changeState:k_PULL_STATE_NORMAL];
        [footerView changeState:k_PULL_STATE_NORMAL];
        
        [headerView updateTimeLabel];
        [footerView updateTimeLabel];
    }];
}

@end
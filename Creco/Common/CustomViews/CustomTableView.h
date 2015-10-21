//
//  CustomTableView.h
//  
//  Version 1.0
//  Created by Chyo on 12-1-30.
//  Copyright (c) 2012年 QQ:115940737. All rights reserved.
//

#import <UIKit/UIKit.h>

#define k_PULL_STATE_NORMAL         0     //  pull to load
#define k_PULL_STATE_DOWN           1     //  release to load
#define k_PULL_STATE_LOAD           2     //  loading
#define k_PULL_STATE_UP             3     //  load more
#define k_PULL_STATE_END            4     //  loaded

#define k_RETURN_DO_NOTHING         0     //  do nothing
#define k_RETURN_REFRESH            1     //  refresh
#define k_RETURN_LOADMORE           2     //  load more

#define k_VIEW_TYPE_HEADER          0     //  header view
#define k_VIEW_TYPE_FOOTER          1     //  footer view

#define k_STATE_VIEW_HEIGHT         40
#define k_STATE_VIEW_INDICATE_WIDTH 60

@interface StateView : UIView {
@private
    UIActivityIndicatorView * indicatorView;
    UIImageView             * arrowView;
    UILabel                 * stateLabel;
    UILabel                 * timeLabel;
    int                       viewType;
    int                       currentState;
}

@property (nonatomic, retain) UIActivityIndicatorView * indicatorView;
@property (nonatomic, retain) UIImageView             * arrowView;
@property (nonatomic, retain) UILabel                 * stateLabel;
@property (nonatomic, retain) UILabel                 * timeLabel;
@property (nonatomic)         int                       viewType; 
@property (nonatomic)         int                       currentState; 

- (id)initWithFrame:(CGRect)frame viewType:(int)type;

- (void)changeState:(int)state;

- (void)updateTimeLabel;

@end

@interface CustomTableView : UITableView{
    StateView * headerView;
    StateView * footerView;
}
@property (nonatomic) int page;
@property (nonatomic, strong) NSMutableArray *resultData;

- (void)tableViewDidDragging;
- (int)tableViewDidEndDragging;
- (void)reloadData:(BOOL)dataIsAllLoaded;
- (void)requestTimeout;
- (void)noData;
- (void)requestFailed;

@end
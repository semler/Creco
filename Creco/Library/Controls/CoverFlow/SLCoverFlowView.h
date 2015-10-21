//
//  SLCoverFlowView.h
//  SLCoverFlow
//
//  Created by SmartCat on 13-6-13.
//  Copyright (c) 2013年 SmartCat. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SLCoverView.h"

@protocol SLCoverFlowViewDelegate;
@protocol SLCoverFlowViewDataSource;

@interface SLCoverFlowView : UIView

@property (nonatomic, assign) id<SLCoverFlowViewDelegate> delegate;
@property (nonatomic, assign) id<SLCoverFlowViewDataSource> dataSource;

// size of cover view
@property (nonatomic, assign) CGSize coverSize;
// space between cover views
@property (nonatomic, assign) CGFloat coverSpace;
// angle of side cover views
@property (nonatomic, assign) CGFloat coverAngle;
// scale of middle cover view
@property (nonatomic, assign) CGFloat coverScale;

@property (nonatomic, assign, readonly) NSInteger numberOfCoverViews;

- (void)reloadData;

- (SLCoverView *)leftMostVisibleCoverView;
- (SLCoverView *)rightMostVisibleCoverView;
- (void) move:(int)index;
- (void) scroll:(BOOL)canScroll;

- (void)setCenterViewByIndex:(NSInteger)centerIndex;

@end

@protocol SLCoverFlowViewDelegate <NSObject>
@optional
- (void)coverFlowViewNowMovingIndex:(NSInteger)movingIndex;
- (void)coverFlowViewMovedEndAtIndex:(NSInteger)index;
@end

@protocol SLCoverFlowViewDataSource <NSObject>
- (NSInteger)numberOfCovers:(SLCoverFlowView *)coverFlowView;
- (SLCoverView *)coverFlowView:(SLCoverFlowView *)coverFlowView coverViewAtIndex:(NSInteger)index;
@end

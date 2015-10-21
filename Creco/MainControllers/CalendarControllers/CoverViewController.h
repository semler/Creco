//
//  CoverViewController.h
//  Creco
//
//  Created by 于　超 on 2015/06/03.
//  Copyright (c) 2015年 Windward. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CoverViewDelegate;

@interface CoverViewController : UIViewController

@property (nonatomic, assign) id<CoverViewDelegate> delegate;
@property (nonatomic, strong) DetailCostObject *detailCostObject;
@property (nonatomic) int index;

@end

@protocol CoverViewDelegate <NSObject>

- (void)removeCoverFlow;

@end

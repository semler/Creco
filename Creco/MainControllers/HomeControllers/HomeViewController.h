//
//  HomeViewController.h
//  Creco
//
//  Created by Windward on 15/5/17.
//  Copyright (c) 2015年 Windward. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HomeViewController : BaseViewController

- (void)reloadData;
- (void)initData;
- (void)aggregationToGetDetailData;
- (void)requestDetailsData;

@end

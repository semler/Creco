//
//  RecordCostCell.h
//  Creco
//
//  Created by Windward on 15/6/7.
//  Copyright (c) 2015年 Windward. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ClickEveryDetailCostViewDelegate <NSObject>
- (void)clickTheDetailCostViewWith:(DetailCostObject *)detailCostObj;
@end

@interface RecordCostCell : UITableViewCell
@property (nonatomic, assign) id <ClickEveryDetailCostViewDelegate> clickDelegate;
- (void)reloadDataBy:(NSArray *)everydayCostsArray;
@end

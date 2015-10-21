//
//  NewsCell.h
//  Creco
//
//  Created by Windward on 15/6/15.
//  Copyright (c) 2015年 Windward. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NewsObject.h"

#define kDefaultNewsCellHeight   80.f
#define kNewsCellContentWidth    kAllViewWidth-50.f-10.f
#define kNewsCellContentDefaultHeight 35.f
#define kNewsCellDefaultPaddingY 10.f

@interface NewsCell : UITableViewCell
- (void)setNewsDataBy:(NewsObject *)newsObject;
@end

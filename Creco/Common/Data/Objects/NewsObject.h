//
//  NewsObject.h
//  Creco
//
//  Created by Windward on 15/6/15.
//  Copyright (c) 2015年 Windward. All rights reserved.
//

#import "BaseObject.h"

@interface NewsObject : BaseObject
@property (nonatomic, strong) NSString *close_date;
@property (nonatomic, strong) NSString *code;
@property (nonatomic, strong) NSString *content;
@property (nonatomic, strong) NSString *created;
@property (nonatomic, strong) NSString *disable;
@property (nonatomic, strong) NSString *id;
@property (nonatomic, strong) NSString *modified;
@property (nonatomic, strong) NSString *open_date;
@property (nonatomic, strong) NSString *title;

//Not Server Data
@property (nonatomic, readonly) CGFloat contentHeight;
@property (nonatomic) BOOL isShowAllWord;

@end

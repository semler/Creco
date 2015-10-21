//
//  WebViewController.h
//  Creco
//
//  Created by Windward on 15/6/16.
//  Copyright (c) 2015年 Windward. All rights reserved.
//

#import "BaseViewController.h"

@interface WebViewController : BaseViewController
@property (nonatomic, strong) NSString *requestUrl;
@property (nonatomic) BOOL isUseStatute;
@end

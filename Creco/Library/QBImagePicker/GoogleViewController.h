//
//  GoogleViewController.h
//  Creco
//
//  Created by 于　超 on 2015/06/09.
//  Copyright (c) 2015年 Windward. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QBImagePickerController.h"

@protocol GoogleViewDelegate;

@interface GoogleViewController : UIViewController

@property (nonatomic,weak) id<GoogleViewDelegate> delegate;
@property (nonatomic, weak) QBImagePickerController *imagePickerController;
@property (nonatomic, strong) NSMutableArray *imageURLs;

@end

@protocol GoogleViewDelegate <NSObject>


@end
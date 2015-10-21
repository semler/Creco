//
//  PopView.h
//  Creco
//
//  Created by TangYanQiong on 15/7/10.
//  Copyright (c) 2015年 Windward. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum _PopViewType
{
    PopViewTypeUseStatute = 1,
    PopViewTypeAddCertification = 2,
    PopViewTypeInitApp = 3
} PopViewType;

typedef void (^CertificationSuccessed)(NSDictionary *certDic);
typedef void (^AgreeInitApp)(BOOL isAgree);

@interface PopView : UIView
@property (nonatomic, copy) CertificationSuccessed certificationBlock;
@property (nonatomic, copy) AgreeInitApp initAppBlock;

- (id)initWithPopViewType:(PopViewType)popViewType
               withString:(NSString *)string
         andIntoSuperView:(UIView *)superView;
- (void)showPopView;

@end

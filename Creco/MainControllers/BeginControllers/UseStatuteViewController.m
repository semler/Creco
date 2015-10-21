//
//  UseStatuteViewController.m
//  Creco
//
//  Created by Windward on 15/7/8.
//  Copyright (c) 2015年 Windward. All rights reserved.
//

#import "UseStatuteViewController.h"
#import "PWSettingViewController.h"

@interface UseStatuteViewController ()
{
    UIButton *checkBoxBtn;
    UIButton *crecoStartBtn;
}
@end

@implementation UseStatuteViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    
    UILabel *useStauteLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 26.f, kAllViewWidth, 50.f)];
    useStauteLabel.text = @"利用規約";
    useStauteLabel.font = [UIFont boldSystemFontOfSize:32];
    useStauteLabel.textAlignment = NSTextAlignmentCenter;
    useStauteLabel.textColor = [ShareMethods colorFromHexRGB:DEFAULT_APP_STSYLE_COLOR];
    [self.view addSubview:useStauteLabel];
    
    UIImage *catImage = [UIImage imageNamed:@"cat_loading_1_up"];
    CGFloat padding = (self.view.width-(catImage.size.width*1.2*8))/9;
    CGFloat theX = padding;
    CGFloat theY = 0.f;
    for (int i = 1; i <= 8; i ++)
    {
        UIImage *moveUpImage = [UIImage imageNamed:[NSString stringWithFormat:@"cat_loading_%d_up", i]];
        UIImageView *catMoveUpImageView = [[UIImageView alloc] initWithFrame:CGRectMake(theX, self.view.height-catImage.size.height*1.2f-1.f, moveUpImage.size.width*1.2f, moveUpImage.size.height*1.2f)];
        catMoveUpImageView.contentMode = UIViewContentModeScaleAspectFit;
        catMoveUpImageView.clipsToBounds = YES;
        catMoveUpImageView.image = moveUpImage;
        [self.view addSubview:catMoveUpImageView];
        
        theX = padding+catMoveUpImageView.right;
        theY = catMoveUpImageView.top;
    }
    
    UIImage *crecoStartImg = [UIImage imageNamed:@"app_start_btn_normal"];
    crecoStartBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    crecoStartBtn.frame = CGRectMake((kAllViewWidth-crecoStartImg.size.width)/2, theY-crecoStartImg.size.height-20.f, crecoStartImg.size.width, crecoStartImg.size.height);
    [crecoStartBtn setImage:crecoStartImg forState:UIControlStateNormal];
    [crecoStartBtn setImage:[UIImage imageNamed:@"app_start_btn_disabled"] forState:UIControlStateDisabled];
    [crecoStartBtn addTarget:self action:@selector(goSettingPWVC) forControlEvents:UIControlEventTouchUpInside];
    crecoStartBtn.enabled = NO;
    [self.view addSubview:crecoStartBtn];
    
    UIImage *checkImg = [UIImage imageNamed:@"check_box"];
    checkBoxBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    checkBoxBtn.frame = CGRectMake(0, crecoStartBtn.top-checkImg.size.height-20.f, checkImg.size.width+150.f, checkImg.size.height);
    [checkBoxBtn setImage:checkImg forState:UIControlStateNormal];
    [checkBoxBtn setImage:[UIImage imageNamed:@"check_box_selected"] forState:UIControlStateSelected];
    checkBoxBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    [checkBoxBtn setTitle:@" 利用規約に同意する" forState:UIControlStateNormal];
    [checkBoxBtn setTitleColor:[ShareMethods colorFromHexRGB:DEFAULT_APP_STSYLE_COLOR] forState:UIControlStateNormal];
    [checkBoxBtn addTarget:self action:@selector(agreeOrNot) forControlEvents:UIControlEventTouchUpInside];
    checkBoxBtn.titleLabel.font = [UIFont systemFontOfSize:16];
    [self.view addSubview:checkBoxBtn];
    
    UIImage *frameImg = [UIImage imageNamed:@"useStatute_frame"];
    UIImageView *frameImageView = [[UIImageView alloc] initWithFrame:CGRectMake((kAllViewWidth-frameImg.size.width)/2, useStauteLabel.bottom, frameImg.size.width, checkBoxBtn.top-20.f-useStauteLabel.bottom)];
    frameImageView.userInteractionEnabled = YES;
    frameImageView.image = frameImg;
    [self.view addSubview:frameImageView];
    checkBoxBtn.center = CGPointMake(frameImageView.center.x, checkBoxBtn.center.y);
    
    UITextView *contentTextView = [[UITextView alloc] initWithFrame:CGRectMake(10.f, 10.f, frameImageView.width-20.f, frameImageView.height-12.f)];
    contentTextView.editable = NO;
    contentTextView.font = [UIFont systemFontOfSize:14];
    [frameImageView addSubview:contentTextView];
    
    [RequestManager requestPath:kGetAgreement parameters:nil success:^(AFHTTPRequestOperation *operation, id result) {
        if (result)
            contentTextView.text = result[@"agreement"];
        else
            contentTextView.text = [NSString stringWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"UseStatute" ofType:@"txt"]
                                                             encoding:NSUTF8StringEncoding
                                                                error:nil];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        contentTextView.text = [NSString stringWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"UseStatute" ofType:@"txt"]
                                                         encoding:NSUTF8StringEncoding
                                                            error:nil];
    }];
}

- (void)agreeOrNot
{
    checkBoxBtn.selected = !checkBoxBtn.selected;
    crecoStartBtn.enabled = checkBoxBtn.selected;
}

- (void)goSettingPWVC
{
    //App default value is setting
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kNeedEnterPassword];
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:kAutoUpdate];
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kPDFNoitification];
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kCostMoneyNotitication];
    [[NSUserDefaults standardUserDefaults] setValue:@"100,000" forKey:kNotifyCostMoneyLimit];
    
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kAppOpenMoreThanOnce];
    [[NSUserDefaults standardUserDefaults] synchronize];
    //
    
    PWSettingViewController *pwSettingVC = [[PWSettingViewController alloc] init];
    [self.navigationController pushViewController:pwSettingVC animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

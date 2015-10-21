//
//  PWSettingViewController.m
//  Creco
//
//  Created by Windward on 15/5/17.
//  Copyright (c) 2015年 Windward. All rights reserved.
//

#import "PWSettingViewController.h"
#import <AudioToolbox/AudioToolbox.h>

@interface PWSettingViewController ()
{
    CGFloat keyboradHeight;
    NSString *settingNewPWStr;
    NSString *nowEnterPWStr;
    
    UILabel *wordLabel;
    NSInteger enterTimes;
}
@end

@implementation PWSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self onlyNeedStatusView];
    
    UIImage *logoImg = [UIImage imageNamed:@"logo"];
    UIImageView *logoImageView = [[UIImageView alloc] initWithFrame:CGRectMake((kAllViewWidth-logoImg.size.width)/2, Is_iPhone4Or4s?28.f:73.f, logoImg.size.width, logoImg.size.height)];
    logoImageView.image = logoImg;
    [self addSubview:logoImageView];
    
    wordLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, logoImageView.bottom+15.f, kAllViewWidth, 29.f)];
    wordLabel.textColor = [ShareMethods colorFromHexRGB:@"a5a5a5"];
    wordLabel.font = [UIFont systemFontOfSize:12];
    wordLabel.textAlignment = NSTextAlignmentCenter;
    wordLabel.numberOfLines = 0;
    [self.view addSubview:wordLabel];
    
    [self initKeyboard];
    [self initPWLine];
    [self initPWImage];
    
    enterTimes = 0;
    nowEnterPWStr = @"";
    if (self.isResetPW)
        wordLabel.text = @"現在のパスコードを入力してください";
    else
    {
        if (![[NSUserDefaults standardUserDefaults] valueForKey:kAppPassword])
            wordLabel.text = @"パスコードを登録します\n４桁の数字を入力してください";
        else
            wordLabel.text = @"パスコードを入力してください";
    }
}

- (void)initKeyboard
{
    keyboradHeight = 217.f;//(107*4+2*3)/2=217
    
    UIView *keyboardView = [[UIView alloc] initWithFrame:CGRectMake(0, kAllViewHeight+44+kTabbarHeight-keyboradHeight, kAllViewWidth, keyboradHeight)];
    keyboardView.backgroundColor = [UIColor whiteColor];
    [self addSubview:keyboardView];
    
    CGFloat btnWidth = (kAllViewWidth-1*2)/3;
    CGFloat btnHeight = 107.f/2;
    for (int j = 0; j < 4; j ++)
    {
        for (int i = 0; i < 3; i ++)
        {
            int nowNumber = i+3*j+1;
            NSString *numberStr = nil;
            if (nowNumber == 10)
                numberStr = nil;
            else if (nowNumber == 11)
                numberStr = @"0";
            else
                numberStr = [NSString stringWithFormat:@"%d", nowNumber];
            
            UIButton *actionButton = [UIButton buttonWithType:UIButtonTypeCustom];
            actionButton.frame = CGRectMake((btnWidth+1)*i, (btnHeight+1)*j, btnWidth, btnHeight);
            actionButton.backgroundColor = [ShareMethods colorFromHexRGB:@"7e8699"];
            [actionButton setBackgroundImage:[ShareMethods createImageWithColor:[ShareMethods colorFromHexRGB:@"a7b2cc"] size:CGSizeMake(btnWidth, btnHeight)] forState:UIControlStateHighlighted];
            [keyboardView addSubview:actionButton];
            
            if (nowNumber != 10) {
                if (nowNumber == 12) {
                    [actionButton setImage:[UIImage imageNamed:@"del_pw"] forState:UIControlStateNormal];
                    [actionButton addTarget:self action:@selector(deletePassword) forControlEvents:UIControlEventTouchUpInside];
                }else
                {
                    [actionButton setTitle:numberStr forState:UIControlStateNormal];
                    [actionButton setTitleColor:[ShareMethods colorFromHexRGB:@"ffffff"] forState:UIControlStateNormal];
                    actionButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Thin" size:36];
                    [actionButton addTarget:self action:@selector(setPWNumber:) forControlEvents:UIControlEventTouchUpInside];
                }
            }else
            {
                if (self.isResetPW) {
                    [actionButton setTitle:@"キャンセル" forState:UIControlStateNormal];
                    [actionButton setTitleColor:[ShareMethods colorFromHexRGB:@"a5a5a5"] forState:UIControlStateNormal];
                    actionButton.titleLabel.font = [UIFont systemFontOfSize:12];
                    [actionButton addTarget:self action:@selector(clickLeftButton) forControlEvents:UIControlEventTouchUpInside];
                }
            }
        }
    }
}

- (void)initPWLine
{
    CGFloat lineWidth = 14.f;
    CGFloat lineHeight = 2.f;
    CGFloat linePadding = 32.f;
    CGFloat lineOriginX = (kAllViewWidth-4*lineWidth-linePadding*3)/2;
    CGFloat lineOriginY = wordLabel.bottom+60.f;//kAllViewHeight+20+44+kTabbarHeight-keyboradHeight-141.f-lineHeight;
    for (int i = 0; i < 4; i ++)
    {
        DrawLine(self.view, lineOriginX, lineOriginY, lineWidth, lineHeight, [ShareMethods colorFromHexRGB:@"7e8699"]);
        lineOriginX = lineOriginX+lineWidth+linePadding;
    }
}

- (void)initPWImage
{
    UIImage *pwCakeImg = [UIImage imageNamed:@"cake_1"];
    CGFloat pwCakeWidth = pwCakeImg.size.width;
    CGFloat pwCakePadding = 19.f;
    CGFloat pwCakeOriginX = (kAllViewWidth-4*pwCakeWidth-pwCakePadding*3)/2;
    CGFloat pwCakeOriginY = wordLabel.bottom+60.f+10.f;//kAllViewHeight+20+44+kTabbarHeight-keyboradHeight-133.f;
    for (int i = 0; i < 4; i ++)
    {
        pwCakeImg = [UIImage imageNamed:[NSString stringWithFormat:@"cake_%d", i+1]];
        UIImageView *pwImageView = [[UIImageView alloc] initWithFrame:CGRectMake(pwCakeOriginX, pwCakeOriginY, pwCakeImg.size.width, pwCakeImg.size.height)];
        pwImageView.image = pwCakeImg;
        pwImageView.bottom = pwCakeOriginY;
        pwImageView.tag = kDefaultViewTag+i;
        pwImageView.hidden = YES;
        [self.view addSubview:pwImageView];
        
        pwCakeOriginX = pwCakeOriginX+pwCakeImg.size.width+(i==2?pwCakePadding-3:pwCakePadding);
    }
}

- (void)deletePassword
{
    if (nowEnterPWStr.length == 0)
        return;
    
    nowEnterPWStr = [nowEnterPWStr substringToIndex:nowEnterPWStr.length-1];
    for (int i = (int)nowEnterPWStr.length; i < 4; i ++)
    {
        UIImageView *pwImageView = (UIImageView *)[self.view viewWithTag:kDefaultViewTag+i];
        if (!pwImageView.hidden) pwImageView.hidden = YES;
    }
}

- (void)setPWNumber:(UIButton *)numberBtn
{
    if (nowEnterPWStr.length == 4)
        return;
    
    nowEnterPWStr = [nowEnterPWStr stringByAppendingString:numberBtn.titleLabel.text];
    for (int i = 0; i < nowEnterPWStr.length; i ++)
    {
        UIImageView *pwImageView = (UIImageView *)[self.view viewWithTag:kDefaultViewTag+i];
        if (pwImageView.hidden) pwImageView.hidden = NO;
    }
    
    if (nowEnterPWStr.length == 4)
    {
        if (self.isResetPW)
        {
            if (enterTimes == 0) {
                if ([nowEnterPWStr isEqualToString:[[NSUserDefaults standardUserDefaults] valueForKey:kAppPassword]]) {
                    wordLabel.text = @"新しいパスコードを入力してください";
                    wordLabel.textColor = [ShareMethods colorFromHexRGB:@"a5a5a5"];
                    [self clearAllCakePWImg];
                    nowEnterPWStr = @"";
                    enterTimes++;
                }else
                    [self wrongWordEnter];
            }else if (enterTimes == 1)
            {
                wordLabel.text = @"新しいパスコードをもう一度入力してください";
                wordLabel.textColor = [ShareMethods colorFromHexRGB:@"a5a5a5"];
                settingNewPWStr = [nowEnterPWStr copy];
                [self clearAllCakePWImg];
                nowEnterPWStr = @"";
                enterTimes++;
            }else if (enterTimes == 2)
            {
                if ([nowEnterPWStr isEqualToString:settingNewPWStr]) {
                    [[NSUserDefaults standardUserDefaults] setValue:nowEnterPWStr forKey:kAppPassword];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                    [ShareMethods showAlertBy:@"パスコードを変更しました"];
                    
                    [self.navigationController performSelector:@selector(popViewControllerAnimated:) withObject:[NSNumber numberWithBool:YES] afterDelay:0.6f];
                }else
                    [self wrongWordEnter];
            }
        }else
        {
            if ([[NSUserDefaults standardUserDefaults] valueForKey:kAppPassword]) {
                if ([nowEnterPWStr isEqualToString:[[NSUserDefaults standardUserDefaults] valueForKey:kAppPassword]])
                    [self performSelector:@selector(dismissSelf) withObject:nil afterDelay:0.5f];
                else
                    [self wrongWordEnter];
            }else
            {
                if (enterTimes == 0) {
                    wordLabel.text = @"確認のため、もう一度パスコードを入力してください";
                    wordLabel.textColor = [ShareMethods colorFromHexRGB:@"a5a5a5"];
                    settingNewPWStr = [nowEnterPWStr copy];
                    [self clearAllCakePWImg];
                    nowEnterPWStr = @"";
                    enterTimes++;
                }else if (enterTimes == 1)
                {
                    if ([nowEnterPWStr isEqualToString:settingNewPWStr]) {
                        [[NSUserDefaults standardUserDefaults] setValue:nowEnterPWStr forKey:kAppPassword];
                        [[NSUserDefaults standardUserDefaults] synchronize];
                        
                        [self performSelector:@selector(dismissSelf) withObject:nil afterDelay:0.5f];
                    }else
                        [self wrongWordEnter];
                }
            }
        }
    }
}

- (void)dismissSelf
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)wrongWordEnter
{
    wordLabel.text = @"パスコードが間違っています。再入力してください";
    wordLabel.textColor = [UIColor redColor];
    
    [self clearAllCakePWImg];
    nowEnterPWStr = @"";
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
}

- (void)clearAllCakePWImg
{
    [self performSelector:@selector(reallyClear) withObject:nil afterDelay:0.5f];
}

- (void)reallyClear
{
    for (int i = 0; i < 4; i ++)
    {
        UIImageView *pwImageView = (UIImageView *)[self.view viewWithTag:kDefaultViewTag+i];
        pwImageView.hidden = YES;
    }
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

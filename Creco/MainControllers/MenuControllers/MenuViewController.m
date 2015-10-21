//
//  MenuViewController.m
//  Creco
//
//  Created by Windward on 15/5/17.
//  Copyright (c) 2015年 Windward. All rights reserved.
//

#import "MenuViewController.h"
#import "SettingViewController.h"
#import "NewsViewController.h"
#import "WebViewController.h"
#import "TopicViewController.h"
#import <MessageUI/MessageUI.h>
#import "CardViewController.h"
#import "ListViewController.h"
#import "WebIdViewController.h"
#import "UIAlertView+BlocksKit.h"
#import "PopView.h"
#import "UseStatuteViewController.h"
#import "HowToUseScrollView.h"

#define kMenuArray          @[@"FAQ", @"運営会社", @"利用規約", @"改善要望・ご意見", @"応援レビューを書く", @"初期化"]
#define kMenuCellHeight     45.f

@interface MenuViewController () <UITableViewDataSource, UITableViewDelegate, MFMailComposeViewControllerDelegate, UIAlertViewDelegate>
{
    UITableView *menuTable;
    UIImageView *badgeNewsImageView;
    
    NSInteger webidApiCount;
    BOOL isWebidApiDeleteFailed;
}
@end

@implementation MenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self onlyNeedStatusView];
    [self setCustomLeftButtonBy:nil];
    self.view.backgroundColor = COLOR_VIEW_OTHER_BACKGROUND;
    
    int topViewHeight = kAllViewWidth/320*180;
    UIView *topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kAllViewWidth, topViewHeight)];
    topView.backgroundColor = [UIColor whiteColor];
    [self addSubview:topView];
    
    DrawLine(topView, 0, topViewHeight/2-0.5f, topView.width, 0.5f, COLOR_LINE);
    DrawLine(topView, 0, topViewHeight-0.5f, topView.width, 0.5f, COLOR_LINE);
    DrawLine(topView, topView.width/3, 0, 0.5f, topViewHeight, COLOR_LINE);
    DrawLine(topView, topView.width/3*2+0.5f, 0, 0.5f, topViewHeight, COLOR_LINE);
    
    for (int j = 0; j < 2; j ++)
    {
        for (int i = 0; i < 3; i ++)
        {
            int nowIndex = i+3*j;
            NSString *actionImgStr = nil;
            switch (nowIndex) {
                case 0:
                    actionImgStr = @"menu_icon_card";
                    break;
                case 1:
                    actionImgStr = @"menu_icon_pdf";
                    break;
                case 2:
                    actionImgStr = @"menu_icon_web";
                    break;
                case 3:
                    actionImgStr = @"menu_icon_setting";
                    break;
                case 4:
                    actionImgStr = @"menu_icon_kisekae";
                    break;
                case 5:
                    actionImgStr = @"menu_icon_news";
                    break;
                default:
                    break;
            }
            
            UIImage *actionImg = [UIImage imageNamed:actionImgStr];
            UIButton *actionButton = [UIButton buttonWithType:UIButtonTypeCustom];
            actionButton.tag = nowIndex;
            actionButton.frame = CGRectMake(topView.width/3*i+(topView.width/3-actionImg.size.width)/2, topViewHeight/2*j+(topViewHeight/2-actionImg.size.height-topViewHeight/(Is_iPhone5Or5s ? 10 : 8)), actionImg.size.width, actionImg.size.height);
            [actionButton setImage:actionImg forState:UIControlStateNormal];
            [actionButton addTarget:self action:@selector(actionGoTo:) forControlEvents:UIControlEventTouchUpInside];
            [topView addSubview:actionButton];
            
            if (nowIndex == 5) {
                UIImage *badgeNewsImg = [UIImage imageNamed:@"badge_news"];
                badgeNewsImageView = [[UIImageView alloc] initWithFrame:CGRectMake(actionButton.width-badgeNewsImg.size.width/2, -badgeNewsImg.size.height/2, badgeNewsImg.size.width, badgeNewsImg.size.height)];
                badgeNewsImageView.image = badgeNewsImg;
                badgeNewsImageView.userInteractionEnabled = YES;
                [actionButton addSubview:badgeNewsImageView];
            }
        }
    }
    
    CGFloat menuHeight = (kAllViewHeight+44.f-topView.bottom-10.f+20.f-3.f) < kMenuArray.count*kMenuCellHeight ? (kAllViewHeight+44.f-topView.bottom-10.f+20.f) : kMenuArray.count*kMenuCellHeight;
    menuTable = [[UITableView alloc] initWithFrame:CGRectMake(0, topView.bottom+10.f, kAllViewWidth, menuHeight) style:UITableViewStylePlain];
    menuTable.delegate = self;
    menuTable.dataSource = self;
    menuTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:menuTable];
    
    DrawLine(self.view, 0, menuTable.top-0.5f, self.view.width, 0.5f, COLOR_LINE);
}

- (void)unReadCountChanged
{
    badgeNewsImageView.hidden = [InfoRead getUnReadMessageCount] > 0 ? NO : YES;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    if (!self.navigationController.navigationBarHidden)
        [self.navigationController setNavigationBarHidden:YES animated:YES];
    
    badgeNewsImageView.hidden = [InfoRead getUnReadMessageCount] > 0 ? NO : YES;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(unReadCountChanged)
                                                 name:kUnReadMesageCountChanged
                                               object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:YES];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kUnReadMesageCountChanged object:nil];
}

- (void)actionGoTo:(UIButton *)button
{
    switch (button.tag) {
        case 0://Card Manager
        {
            CardViewController *cardVC = [[CardViewController alloc] init];
            [self.navigationController pushViewController:cardVC animated:YES];
        }
            break;
        case 1://PDF
        {
            ListViewController *listVC = [[ListViewController alloc] init];
            [self.navigationController pushViewController:listVC animated:YES];
        }
            break;
        case 2://WEB ID Manger
        {
            WebIdViewController *webVC = [[WebIdViewController alloc] init];
            [self.navigationController pushViewController:webVC animated:YES];
        }
            break;
        case 3://Setting Manger
        {
            SettingViewController *settingVC = [[SettingViewController alloc] init];
            [self.navigationController pushViewController:settingVC animated:YES];
        }
            break;
        case 4://Kisekae Manger
        {
            TopicViewController *topicVC = [[TopicViewController alloc] init];
            [self.navigationController pushViewController:topicVC animated:YES];
        }
            break;
        case 5://News Notification
        {
            NewsViewController *newsVC = [[NewsViewController alloc] init];
            [self.navigationController pushViewController:newsVC animated:YES];
        }
            break;
        default:
            break;
    }
}

#pragma mark - UITableView DataSource -

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return kMenuArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kMenuCellHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellStr = @"MenuCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellStr];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellStr];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.textLabel.textColor = [ShareMethods colorFromHexRGB:@"505050"];
        cell.textLabel.font = [UIFont systemFontOfSize:14];
        
        DrawLine(cell, 0, kMenuCellHeight-0.5f, tableView.width, 0.5f, COLOR_LINE);
    }
    
    cell.textLabel.text = kMenuArray[indexPath.row];

    return cell;
}

#pragma mark - UITableView Delegate -

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    switch (indexPath.row) {
        case 0: case 1: case 2:
        {
            WebViewController *webVC = [[WebViewController alloc] init];
            webVC.navigationItem.title = kMenuArray[indexPath.row];
            if (indexPath.row == 2)
                webVC.isUseStatute = YES;
            else
                webVC.requestUrl = indexPath.row == 0 ? kFAQURL : kCompanyURL;
            [(UINavigationController *)kAppDelegate.window.rootViewController pushViewController:webVC animated:YES];
        }
            break;
        case 3:
        {
            if ([MFMailComposeViewController canSendMail])
            {
                MFMailComposeViewController *controller = [[MFMailComposeViewController alloc] init];
                controller.mailComposeDelegate = self;
                controller.navigationBar.tintColor = [ShareMethods colorFromHexRGB:[[NSUserDefaults standardUserDefaults] valueForKey:kAppTopicColor]];
                [controller setToRecipients:[NSArray arrayWithObject:@"staffs+1.0_8.2_AxiR87Qd@creco.cards"]];//邮件收件地址：staffs+APP version_ios version_(usercode)@creco.cards
                [controller setSubject:@"【CRECO】改善要望・ご意見"];
                [kAppDelegate.window.rootViewController presentViewController:controller animated:YES completion:^{
                    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
                }];
            }else
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"mailto:"]];
        }
            break;
        case 4:
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:kAppStoreURL]];
            break;
        case 5:
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"本当に初期化しますか？"
                                                            message:nil
                                                           delegate:self
                                                  cancelButtonTitle:@"いいえ" otherButtonTitles:@"はい", nil];
            [alert show];
        }
            break;
        default:
            break;
    }
}

#pragma mark - MailDelegate -

- (void)mailComposeController:(MFMailComposeViewController *)controller
          didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    NSString *mailStatusStr = nil;
    switch (result) {
        case MFMailComposeResultCancelled:
            mailStatusStr = @"送信をキャンセルしました。";
            [self dismissViewControllerAnimated:YES completion:nil];
            break;
        case MFMailComposeResultSaved:
            mailStatusStr = @"メールを保存しました。";
            [self dismissViewControllerAnimated:YES completion:nil];
            break;
        case MFMailComposeResultSent:
            mailStatusStr = @"送信に成功しました。";
            [self dismissViewControllerAnimated:YES completion:nil];
            break;
        case MFMailComposeResultFailed:
            mailStatusStr = @"インターネットに接続されていないため、送信はできません。";
            break;
        default:
            break;
    }
    
    [ShareMethods showAlertBy:mailStatusStr];
}

#pragma mark - UIAlertViewDelegate -

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1)//Confirm Init App
    {
        PopView *initAppPopView = [[PopView alloc] initWithPopViewType:PopViewTypeInitApp withString:nil andIntoSuperView:self.view];
        [initAppPopView showPopView];
        initAppPopView.initAppBlock = ^(BOOL isArgee)
        {
            if (isArgee)
                [self confirmInitApp];
        };
    }
}

- (void)confirmInitApp
{
    [AppConfig shareConfig].isShowAPIAlert = YES;
    isWebidApiDeleteFailed = NO;
    
    [[AppConfig shareConfig] showLoadingView];
    
    NSArray *websArray = [WebId getAllUserWebs];
    webidApiCount = websArray.count;
    
    if (webidApiCount == 0)
        [self initAppData];
    else
    {
        for (UserWebObject *userWebObj in websArray)
        {
            [RequestManager requestPath:kWEBIDDelete
                             parameters:@{@"service_code":userWebObj.service_code,
                                          @"web_id_code":userWebObj.web_id_code}
                                success:^(AFHTTPRequestOperation *operation, id result) {
                                    
                                    BOOL isSuccessed = NO;
                                    if ([result[@"status"] integerValue] == 1)
                                    {
                                        isSuccessed = YES;
                                        
                                        [WebId deleteUserWebInDBByService_code:userWebObj.service_code];
                                        [Entry deleteUserCardInDBByService_code:userWebObj.service_code andCard_code:userWebObj.card_code];
                                        
                                        webidApiCount--;
                                        if (webidApiCount == 0)
                                            [self initAppData];
                                    }
                                    
                                    if (!isSuccessed) {
                                        [[AppConfig shareConfig] hiddenLoadingView];
                                        if (!isWebidApiDeleteFailed) {
                                            isWebidApiDeleteFailed = YES;
                                            
                                            [UIAlertView bk_showAlertViewWithTitle:@"初期化に失敗しました。もう一度操作をお願いします"
                                                                           message:nil
                                                                 cancelButtonTitle:@"NO"
                                                                 otherButtonTitles:@[@"YES"]
                                                                           handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
                                                                               [AppConfig shareConfig].isShowAPIAlert = NO;
                                                                               if (buttonIndex == 1)
                                                                                   [self confirmInitApp];
                                                                           }];
                                        }
                                    }
                                } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                    [[AppConfig shareConfig] hiddenLoadingView];
                                    if (!isWebidApiDeleteFailed) {
                                        isWebidApiDeleteFailed = YES;
                                        
                                        [UIAlertView bk_showAlertViewWithTitle:@"初期化に失敗しました。もう一度操作をお願いします"
                                                                       message:nil
                                                             cancelButtonTitle:@"NO"
                                                             otherButtonTitles:@[@"YES"]
                                                                       handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
                                                                           [AppConfig shareConfig].isShowAPIAlert = NO;
                                                                           if (buttonIndex == 1)
                                                                               [self confirmInitApp];
                                                                       }];
                                    }
                                }];
        }
    }
}

- (void)initAppData
{
    [Entry cleanTable];
    [Details cleanTable];
    [WebId cleanTable];
    [InfoRead cleanTable];
    [Pdf cleanTable];
    
    //Set Default AllCard To Entry Table
    [Entry replaceUserCardIntoDBWithService_code:kAllCardCode
                                       card_code:kAllCardCode
                                       card_name:@"全てのカード"
                                            memo:nil
                                           color:nil
                                        card_seq:0];
    
    //App default value is init setting
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kNeedEnterPassword];
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:kAutoUpdate];
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kPDFNoitification];
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kCostMoneyNotitication];
    [[NSUserDefaults standardUserDefaults] setValue:@"100,000" forKey:kNotifyCostMoneyLimit];
    
    [[NSUserDefaults standardUserDefaults] setValue:DEFAULT_APP_STSYLE_COLOR forKey:kAppTopicColor];//Default Color
    
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kAppPassword];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kUserCode];
    
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kDetailApiLastUpdateDate];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kAggregationApiLastUpdateDate];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kPDFApiLastUpdateDate];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kReviewPDFLastDate];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kMessageApiLastUpdateDate];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kReviewMessageLastDate];
    
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:kAppOpenMoreThanOnce];
    [[NSUserDefaults standardUserDefaults] synchronize];
    //
    
    [kAppDelegate customizeAppearance];
    [[AppConfig shareConfig] hiddenLoadingView];
    
    //Go to init app view
    kAppDelegate.appTabBarVC = [[AppTabBarViewController alloc] init];
    UINavigationController *rootNavController = [[UINavigationController alloc] initWithRootViewController:kAppDelegate.appTabBarVC];
    rootNavController.navigationBarHidden = YES;
    kAppDelegate.window.rootViewController = rootNavController;
    DrawLine(rootNavController.navigationBar, 0, rootNavController.navigationBar.height-0.5f, rootNavController.navigationBar.width, 0.5f, COLOR_LINE);
    
    UseStatuteViewController *useStatuteVC = [[UseStatuteViewController alloc] init];
    UINavigationController *useStatuteNavController = [[UINavigationController alloc] initWithRootViewController:useStatuteVC];
    useStatuteNavController.navigationBarHidden = YES;
    [kAppDelegate.window.rootViewController presentViewController:useStatuteNavController animated:NO completion:nil];
    
    HowToUseScrollView *howToUseView = [[HowToUseScrollView alloc] initWithFrame:CGRectMake(0, 0, kAppDelegate.window.width, kAppDelegate.window.height)];
    [kAppDelegate.window addSubview:howToUseView];
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

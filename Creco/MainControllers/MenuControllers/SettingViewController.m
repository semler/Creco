//
//  SettingViewController.m
//  Creco
//
//  Created by Windward on 15/6/10.
//  Copyright (c) 2015年 Windward. All rights reserved.
//

#import "SettingViewController.h"
#import "PWSettingViewController.h"
#import "SevenSwitch.h"

#define kSettingArray          @[@"パスコード設定", @"パスコード省略", @"自動更新", @"請求書PDF通知", @"月間合計利用額通知"]
#define kSettingCellHeight     45.f

@interface SettingViewController () <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>
{
    UITableView *settingTable;
    UITextField *moneyText;
    
    UIButton *bgButton;
    
    CGFloat selfOriginY;
}
@end

@implementation SettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    self.navigationItem.title = @"設定";
    self.view.backgroundColor = COLOR_VIEW_OTHER_BACKGROUND;
    
    settingTable = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kAllViewWidth, kAllViewHeight) style:UITableViewStylePlain];
    settingTable.delegate = self;
    settingTable.dataSource = self;
    settingTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    settingTable.backgroundColor = [UIColor clearColor];
    [self.view addSubview:settingTable];
    
    bgButton = [UIButton buttonWithType:UIButtonTypeCustom];
    bgButton.frame = settingTable.frame;
    [bgButton addTarget:self action:@selector(putBackKeyboard) forControlEvents:UIControlEventTouchUpInside];
    bgButton.hidden = YES;
    [self.view addSubview:bgButton];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    selfOriginY = self.view.top;
}

- (void)clickLeftButton
{
    [super clickLeftButton];
    
    [[NSUserDefaults standardUserDefaults] setValue:moneyText.text forKey:kNotifyCostMoneyLimit];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)putBackKeyboard
{
    [moneyText resignFirstResponder];
    bgButton.hidden = YES;
    
    if (Is_iPhone4Or4s)
        self.view.frame = CGRectMake(self.view.left, selfOriginY, self.view.width, self.view.height);
    
    [[NSUserDefaults standardUserDefaults] setValue:moneyText.text forKey:kNotifyCostMoneyLimit];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)switchValueChanged:(UISwitch *)nowSwitch
{
    switch (nowSwitch.tag) {
        case 1://パスコード省略
            [[NSUserDefaults standardUserDefaults] setBool:!nowSwitch.on forKey:kNeedEnterPassword];
            [[NSUserDefaults standardUserDefaults] synchronize];
            break;
        case 2://自動更新
            [[NSUserDefaults standardUserDefaults] setBool:nowSwitch.on forKey:kAutoUpdate];
            [[NSUserDefaults standardUserDefaults] synchronize];
            break;
        case 3://請求PDF通知
            [[NSUserDefaults standardUserDefaults] setBool:nowSwitch.on forKey:kPDFNoitification];
            [[NSUserDefaults standardUserDefaults] synchronize];
            break;
        case 4://月間合計利用額通知
            [[NSUserDefaults standardUserDefaults] setBool:nowSwitch.on forKey:kCostMoneyNotitication];
            [[NSUserDefaults standardUserDefaults] synchronize];
            break;
        default:
            break;
    }
}

#pragma mark - UITableView DataSource -

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return kSettingArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == kSettingArray.count-1)
        return 90.f;
    return kSettingCellHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellStr = @"SettingCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellStr];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellStr];
        cell.textLabel.textColor = [ShareMethods colorFromHexRGB:@"505050"];
        cell.textLabel.font = [UIFont systemFontOfSize:14];
        
        DrawLine(cell, 0, indexPath.row == kSettingArray.count-1 ? 90.f :kSettingCellHeight-0.5f, tableView.width, 0.5f, COLOR_LINE);
    }

    if (indexPath.row == 0)
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    else
    {
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        UISwitch *onOrOffSwitch = (UISwitch *)[cell.contentView viewWithTag:kDefaultViewTag];
        if (!onOrOffSwitch) {
            onOrOffSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
            onOrOffSwitch.frame = CGRectMake(tableView.width-15.f-onOrOffSwitch.width, (kSettingCellHeight-onOrOffSwitch.height)/2, onOrOffSwitch.width, onOrOffSwitch.height);
            [onOrOffSwitch addTarget:self action:@selector(switchValueChanged:) forControlEvents:UIControlEventTouchUpInside];
            [cell.contentView addSubview:onOrOffSwitch];
        }
        onOrOffSwitch.tag = indexPath.row;
        
        switch (indexPath.row) {
            case 1:
                onOrOffSwitch.on = ![[NSUserDefaults standardUserDefaults] boolForKey:kNeedEnterPassword];
                break;
            case 2:
                onOrOffSwitch.on = [[NSUserDefaults standardUserDefaults] boolForKey:kAutoUpdate];
                break;
            case 3:
                onOrOffSwitch.on = [[NSUserDefaults standardUserDefaults] boolForKey:kPDFNoitification];
                break;
            case 4:
                onOrOffSwitch.on = [[NSUserDefaults standardUserDefaults] boolForKey:kCostMoneyNotitication];
                break;
            default:
                break;
        }
    }
    
    if (indexPath.row != kSettingArray.count-1)
        cell.textLabel.text = kSettingArray[indexPath.row];
    else
    {
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(13.f, 10.f, 200, 20.f)];
        titleLabel.font = cell.textLabel.font;
        titleLabel.textColor = cell.textLabel.textColor;
        titleLabel.text = kSettingArray[indexPath.row];
        [cell.contentView addSubview:titleLabel];
        
        if (!moneyText) {
            moneyText = [[UITextField alloc] initWithFrame:CGRectMake(titleLabel.left, cell.bottom, 215.f, 25.f)];
            moneyText.layer.cornerRadius = 5.f;
            moneyText.clipsToBounds = YES;
            moneyText.backgroundColor = kRGBColor(236.f, 236.f, 236.f, 1.f);
            moneyText.textAlignment = NSTextAlignmentRight;
            moneyText.delegate = self;
            moneyText.keyboardType = UIKeyboardTypeNumberPad;
            moneyText.text = [[NSUserDefaults standardUserDefaults] valueForKey:kNotifyCostMoneyLimit];
            [cell.contentView addSubview:moneyText];
            
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(textFieldTextDidChange:)
                                                         name:UITextFieldTextDidChangeNotification
                                                       object:moneyText];
        }
        
        UILabel *wordLabel = [[UILabel alloc] initWithFrame:CGRectMake(tableView.width-15.f-65.f, titleLabel.bottom+8.f, 60, kSettingCellHeight)];
        wordLabel.font = cell.textLabel.font;
        wordLabel.textColor = cell.textLabel.textColor;
        wordLabel.text = @"円以上";
        wordLabel.textAlignment = NSTextAlignmentRight;
        [cell.contentView addSubview:wordLabel];
    }
    return cell;
}

#pragma mark - UITableView Delegate -

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    if (indexPath.row == 0)
    {
        PWSettingViewController *pwSettingVC = [[PWSettingViewController alloc] init];
        pwSettingVC.isResetPW = YES;
        [(UINavigationController *)kAppDelegate.window.rootViewController pushViewController:pwSettingVC animated:YES];
    }
}

#pragma mark - UITextFieldDelegate -

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if (Is_iPhone4Or4s)
        self.view.frame = CGRectMake(self.view.left, selfOriginY-60.f, self.view.width, self.view.height);
    bgButton.hidden = NO;
    return YES;
}

#pragma mark - UITextField Notification -

- (void)textFieldTextDidChange:(NSNotification *)notification
{
    UITextField *textfield = [notification object];
    textfield.text = [ShareMethods moneyStrToDecimal:textfield.text];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UITextFieldTextDidChangeNotification
                                                  object:moneyText];
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

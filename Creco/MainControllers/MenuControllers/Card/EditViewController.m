//
//  EditViewController.m
//  Creco
//
//  Created by 于　超 on 2015/06/22.
//  Copyright (c) 2015年 Windward. All rights reserved.
//

#import "EditViewController.h"
#import "ColorViewController.h"
#import "CardManager.h"

#define screenWidth            [UIScreen mainScreen].bounds.size.width
#define screenHeight           [UIScreen mainScreen].bounds.size.height

@interface EditViewController ()<UITextFieldDelegate, UITextViewDelegate> {
    UITextField *cardName;
    UITextView *memo;
    UIButton *saveButton;
    UIView *colorIcon;
}

@end

@implementation EditViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    self.navigationItem.title = @"認証情報入力";
    self.view.backgroundColor = COLOR_VIEW_OTHER_BACKGROUND;
    
    UIView *cardNameView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 40)];
    cardNameView.backgroundColor = [UIColor clearColor];
    UILabel *cardNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 10, 100, 30)];
    cardNameLabel.backgroundColor = [UIColor clearColor];
    cardNameLabel.font = [UIFont fontWithName:@"HiraKakuProN-W6" size:14];
    cardNameLabel.textColor = [UIColor colorWithRed:0.314 green:0.314 blue:0.314 alpha:1];
    cardNameLabel.text = @"カード名";
    [cardNameView addSubview:cardNameLabel];
    
    UIView *cardNameView2 = [[UIView alloc] initWithFrame:CGRectMake(0, 40, screenWidth, 40)];
    cardNameView2.backgroundColor = [UIColor whiteColor];
    cardName = [[UITextField alloc] initWithFrame:CGRectMake(20, 0, screenWidth-40, 40)];
    cardName.returnKeyType = UIReturnKeyDone;
    cardName.borderStyle = UITextBorderStyleNone;
    cardName.clearButtonMode = UITextFieldViewModeWhileEditing;
    cardName.font = [UIFont fontWithName:@"HiraKakuProN-W3" size:14];
    cardName.textColor = [UIColor colorWithRed:0.314 green:0.314 blue:0.314 alpha:1];
    cardName.backgroundColor = [UIColor whiteColor];
    cardName.text = _userCardObject.card_name;
    cardName.delegate = self;
    [cardNameView2 addSubview:cardName];
    
    UIView *memoView = [[UIView alloc] initWithFrame:CGRectMake(0, 80, screenWidth, 40)];
    memoView.backgroundColor = [UIColor clearColor];
    UILabel *memoLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 10, 100, 30)];
    memoLabel.backgroundColor = [UIColor clearColor];
    memoLabel.font = [UIFont fontWithName:@"HiraKakuProN-W6" size:14];
    memoLabel.textColor = [UIColor colorWithRed:0.314 green:0.314 blue:0.314 alpha:1];
    memoLabel.text = @"メモ";
    [memoView addSubview:memoLabel];
    
    UIView *memoView2 = [[UIView alloc] initWithFrame:CGRectMake(0, 120, screenWidth, 120)];
    memoView2.backgroundColor = [UIColor whiteColor];
    memo = [[UITextView alloc] initWithFrame:CGRectMake(20, 0, screenWidth-40, 120)];
    memo.returnKeyType = UIReturnKeyDefault;
    memo.font = [UIFont fontWithName:@"HiraKakuProN-W3" size:14];
    memo.textColor = [UIColor colorWithRed:0.314 green:0.314 blue:0.314 alpha:1];
    memo.backgroundColor = [UIColor whiteColor];
    memo.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    memo.text = _userCardObject.memo;
    memo.delegate = self;
    [memoView2 addSubview:memo];
    
    UIView *colorView = [[UIView alloc] initWithFrame:CGRectMake(0, 260, screenWidth, 40)];
    colorView.backgroundColor = [UIColor whiteColor];
    UILabel *colorLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 5, 100, 30)];
    colorLabel.backgroundColor = [UIColor whiteColor];
    colorLabel.font = [UIFont fontWithName:@"HiraKakuProN-W3" size:14];
    colorLabel.textColor = [UIColor colorWithRed:0.314 green:0.314 blue:0.314 alpha:1];
    colorLabel.text = @"カラー";
    colorIcon = [[UIView alloc] initWithFrame:CGRectMake(screenWidth-70, 10, 20, 20)];
    colorIcon.backgroundColor = [ShareMethods colorFromHexRGB:_userCardObject.color];
    UIImageView *view2 = [[UIImageView alloc] initWithFrame:CGRectMake(screenWidth-70+37, 12, 10, 16)];
    view2.image = [UIImage imageNamed:@"preview"];
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 40)];
    button.backgroundColor = [UIColor clearColor];
    [button addTarget:self action:@selector(color) forControlEvents:UIControlEventTouchUpInside];
    
    [colorView addSubview:colorLabel];
    [colorView addSubview:colorIcon];
    [colorView addSubview:view2];
    [colorView addSubview:colorLabel];
    [colorView addSubview:button];
    
    saveButton = [UIButton buttonWithType:UIButtonTypeCustom];
    saveButton.frame = CGRectMake(screenWidth/2-65, 340, 130, 40);
    [saveButton setImage:[UIImage imageTopicNamed:@"btn_save"] forState:UIControlStateNormal];
    [saveButton addTarget:self action:@selector(save) forControlEvents:UIControlEventTouchUpInside];
    //saveButton.enabled = NO;
    
    [self.view addSubview:cardNameView];
    [self.view addSubview:cardNameView2];
    [self.view addSubview:memoView];
    [self.view addSubview:memoView2];
    [self.view addSubview:colorView];
    [self.view addSubview:saveButton];
    
    [[CardManager sharedManager] setColor:_userCardObject.color];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    colorIcon.backgroundColor = [ShareMethods colorFromHexRGB:[CardManager sharedManager].color];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/**
 * キーボードでReturnキーが押されたとき
 * @param textField イベントが発生したテキストフィールド
 */
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    // キーボードを隠す
    [self.view endEditing:YES];
    //saveButton.enabled = YES;
    return YES;
}

// キーボード以外タップした場合
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [cardName resignFirstResponder];
    [memo resignFirstResponder];
    //saveButton.enabled = YES;
}

-(void)color {
    //saveButton.enabled = YES;
    ColorViewController *controller = [[ColorViewController alloc] init];
    [self.navigationController pushViewController:controller animated:YES];
}

-(void)save {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"保存してよろしいですか？"
                                                        message:nil
                                                       delegate:self
                                              cancelButtonTitle:@"いいえ"
                                              otherButtonTitles:@"はい", nil];
    [alertView show];
}

-(void)alertView:(UIAlertView*)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch (buttonIndex) {
        case 0:
            // cancelボタンが押された時の処理
            break;
        case 1:
            // 削除したいファイルのパスを作成
        {
            _userCardObject.color = [CardManager sharedManager].color;
            
            [Entry updateUserCardByCard_code:_userCardObject.card_code color:_userCardObject.color name:cardName.text memo:memo.text];
            [kAppDelegate.appTabBarVC.homeVC reloadData];
            
            [self.navigationController popViewControllerAnimated:YES];
        }
        break;
    }
}

@end

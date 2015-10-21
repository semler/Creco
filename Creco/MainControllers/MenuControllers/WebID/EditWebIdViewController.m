//
//  EditWebIdViewController.m
//  Creco
//
//  Created by 于　超 on 2015/06/23.
//  Copyright (c) 2015年 Windward. All rights reserved.
//

#import "EditWebIdViewController.h"
#import <CommonCrypto/CommonCryptor.h>
#import "GTMBase64.h"

#define screenWidth            [UIScreen mainScreen].bounds.size.width
#define screenHeight           [UIScreen mainScreen].bounds.size.height

@interface EditWebIdViewController () <UITextFieldDelegate>{
    UITextField *serviceName;
    UISwitch *cardSwitch;
    UITextField *cardId;
    UITextField *password;
    
    NSString *randomStr;
}

@property (nonatomic) long tag;
@property (nonatomic) long center;
@property (nonatomic) BOOL backFlg;
@property (nonatomic) NSString *service_name;

@end

@implementation EditWebIdViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _center = self.view.center.y+7;
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    self.navigationItem.title = @"WEBアカウント入力";
    self.view.backgroundColor = COLOR_VIEW_OTHER_BACKGROUND;
    
    UIView *serviceNameView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 40)];
    serviceNameView.backgroundColor = [UIColor clearColor];
    UILabel *serviceNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 10, 200, 30)];
    serviceNameLabel.backgroundColor = [UIColor clearColor];
    serviceNameLabel.font = [UIFont fontWithName:@"HiraKakuProN-W6" size:14];
    serviceNameLabel.textColor = [UIColor colorWithRed:0.314 green:0.314 blue:0.314 alpha:1];
    serviceNameLabel.text = @"WEBサービス名";
    [serviceNameView addSubview:serviceNameLabel];
    
    UIView *serviceNameView2 = [[UIView alloc] initWithFrame:CGRectMake(0, 40, screenWidth, 40)];
    serviceNameView2.backgroundColor = [UIColor whiteColor];
    serviceName = [[UITextField alloc] initWithFrame:CGRectMake(25, 0, screenWidth-40, 40)];
    serviceName.returnKeyType = UIReturnKeyDone;
    serviceName.borderStyle = UITextBorderStyleNone;
    serviceName.clearButtonMode = UITextFieldViewModeWhileEditing;
    serviceName.font = [UIFont fontWithName:@"HiraKakuProN-W3" size:14];
    serviceName.textColor = [UIColor colorWithRed:0.314 green:0.314 blue:0.314 alpha:1];
    serviceName.backgroundColor = [UIColor whiteColor];
    
    _service_name = _webObject.service_name;
    if (_service_name == nil || [@"" isEqualToString:_service_name]) {
        _service_name = [CardMaster getServiceNameByServiceCode:_webObject.service_code];
    }
    serviceName.text = _service_name;
    serviceName.tag = 1;
    serviceName.delegate = self;
    [serviceNameView2 addSubview:serviceName];
    
    UIView *cardView = [[UIView alloc] initWithFrame:CGRectMake(0, 120, screenWidth, 40)];
    cardView.backgroundColor = [UIColor whiteColor];
    UILabel *cardLabel = [[UILabel alloc] initWithFrame:CGRectMake(25, 0, 200, 40)];
    cardLabel.backgroundColor = [UIColor clearColor];
    cardLabel.font = [UIFont fontWithName:@"HiraKakuProN-W3" size:14];
    cardLabel.textColor = [UIColor colorWithRed:0.314 green:0.314 blue:0.314 alpha:1];
    cardLabel.text = @"カード情報取得";
    cardSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(screenWidth-71, 5, 51, 31)];
    [cardSwitch addTarget:self action:@selector(changeSwitch:) forControlEvents:UIControlEventTouchUpInside];
    if ((int)[[NSUserDefaults standardUserDefaults] integerForKey:kStartCount] == 1) {
        cardSwitch.on = YES;
    } else {
        if (_webObject.detail_get_flg) {
            cardSwitch.on = YES;
        } else {
            cardSwitch.on = NO;
        }
    }

    [cardView addSubview:cardLabel];
    [cardView addSubview:cardSwitch];

    
    UIView *IdView = [[UIView alloc] initWithFrame:CGRectMake(0, 160, screenWidth, 40)];
    IdView.backgroundColor = [UIColor clearColor];
    UILabel *IdLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 10, 200, 30)];
    IdLabel.backgroundColor = [UIColor clearColor];
    IdLabel.font = [UIFont fontWithName:@"HiraKakuProN-W6" size:14];
    IdLabel.textColor = [UIColor colorWithRed:0.314 green:0.314 blue:0.314 alpha:1];
    IdLabel.text = @"ID";
    [IdView addSubview:IdLabel];
    
    UIView *IdView2 = [[UIView alloc] initWithFrame:CGRectMake(0, 200, screenWidth, 40)];
    IdView2.backgroundColor = [UIColor whiteColor];
    cardId = [[UITextField alloc] initWithFrame:CGRectMake(25, 0, screenWidth-40, 40)];
    cardId.returnKeyType = UIReturnKeyDone;
    cardId.borderStyle = UITextBorderStyleNone;
    cardId.clearButtonMode = UITextFieldViewModeWhileEditing;
    cardId.font = [UIFont fontWithName:@"HiraKakuProN-W3" size:14];
    cardId.textColor = [UIColor colorWithRed:0.314 green:0.314 blue:0.314 alpha:1];
    cardId.backgroundColor = [UIColor whiteColor];
    cardId.text = _webObject.web_id;
    cardId.tag = 2;
    cardId.delegate = self;
    [IdView2 addSubview:cardId];
    
    UIView *passwordView = [[UIView alloc] initWithFrame:CGRectMake(0, 240, screenWidth, 40)];
    passwordView.backgroundColor = [UIColor clearColor];
    UILabel *passwordLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 10, 200, 30)];
    passwordLabel.backgroundColor = [UIColor clearColor];
    passwordLabel.font = [UIFont fontWithName:@"HiraKakuProN-W6" size:14];
    passwordLabel.textColor = [UIColor colorWithRed:0.314 green:0.314 blue:0.314 alpha:1];
    passwordLabel.text = @"パスワード";
    [passwordView addSubview:passwordLabel];
    
    UIView *passwordView2 = [[UIView alloc] initWithFrame:CGRectMake(0, 280, screenWidth, 40)];
    passwordView2.backgroundColor = [UIColor whiteColor];
    password = [[UITextField alloc] initWithFrame:CGRectMake(25, 0, screenWidth-40, 40)];
    password.returnKeyType = UIReturnKeyDone;
    password.borderStyle = UITextBorderStyleNone;
    password.clearButtonMode = UITextFieldViewModeWhileEditing;
//    password.font = [UIFont fontWithName:@"HiraKakuProN-W3" size:14];
    password.textColor = [UIColor colorWithRed:0.314 green:0.314 blue:0.314 alpha:1];
    password.backgroundColor = [UIColor whiteColor];
    password.text = @"•••••";
    password.tag = 3;
    password.secureTextEntry = YES;
    password.delegate = self;
    [passwordView2 addSubview:password];
    
    UIButton *saveButton = [UIButton buttonWithType:UIButtonTypeCustom];
    saveButton.frame = CGRectMake((screenWidth-280)/2, 340, 130, 40);
    [saveButton setImage:[UIImage imageTopicNamed:@"btn_save"] forState:UIControlStateNormal];
    [saveButton addTarget:self action:@selector(save) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
    deleteButton.frame = CGRectMake(screenWidth/2+10, 340, 130, 40);
    [deleteButton setImage:[UIImage imageTopicNamed:@"btn_delete"] forState:UIControlStateNormal];
    [deleteButton addTarget:self action:@selector(delete) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:serviceNameView];
    [self.view addSubview:serviceNameView2];
    [self.view addSubview:IdView];
    [self.view addSubview:IdView2];
    [self.view addSubview:passwordView];
    [self.view addSubview:passwordView2];
    [self.view addSubview:cardView];
    [self.view addSubview:saveButton];
    [self.view addSubview:deleteButton];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
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
    
    return YES;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    NSLog(@"%d", (int)self.view.center.y);
    _tag = textField.tag;
    return YES;
}

// キーボード以外タップした場合
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [serviceName resignFirstResponder];
    [cardId resignFirstResponder];
    [password resignFirstResponder];
}

- (IBAction)changeSwitch:(id)sender {
    if(cardSwitch.on) {
        // onの時の処理
    } else {
        // offの時の処理
    }
}

-(void)save {
    if (cardId.text.length == 0) {
        [ShareMethods showAlertBy:[NSString stringWithFormat:@"%@ IDを入力してください", _service_name]];
        return;
    }
    
    if (password.text.length == 0) {
        [ShareMethods showAlertBy:[NSString stringWithFormat:@"%@ パスワードを入力してください", _service_name]];
        return;
    }
    
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    NSString *pwEncryptStr = [self AES128Encrypt:password.text];
    
    [[AppConfig shareConfig] showLoadingView];
    [RequestManager requestPath:kWEBIDUpdate
                     parameters:@{@"service_code":_webObject.service_code,
                                  @"web_id_code":_webObject.web_id_code,
                                  @"new_web_id":cardId.text,
                                  @"initialization_vector":randomStr,//Must after Encryption-Data set
                                  @"password":pwEncryptStr}
                        success:^(AFHTTPRequestOperation *operation, id result) {
                            [[AppConfig shareConfig] hiddenLoadingView];
                            if (result) {
                                if ([result[@"status"] integerValue] == 1)
                                {
                                    [WebId replaceUserWebIntoDBWithService_code:_webObject.service_code
                                                                   service_name:serviceName.text
                                                                    web_id_code:_webObject.web_id_code
                                                                      card_code:_webObject.card_code
                                                                         web_id:cardId.text
                                                          initialization_vector:randomStr
                                                                       password:pwEncryptStr
                                                                 detail_get_flg:cardSwitch.on];
                                    
                                    [[NSNotificationCenter defaultCenter] postNotificationName:kWebIdIsRegistSuccessed object:nil];
                                    
                                    [ShareMethods showAlertBy:@"変更完了しました!"];
                                    [self.navigationController popViewControllerAnimated:YES];
                                    [[UIApplication sharedApplication] endIgnoringInteractionEvents];
                                } else {
                                    [ShareMethods showAlertBy:@"変更失敗しました!"];
                                    [[UIApplication sharedApplication] endIgnoringInteractionEvents];
                                }
                            } else {
                                [[UIApplication sharedApplication] endIgnoringInteractionEvents];
                            }
                        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                            [[AppConfig shareConfig] hiddenLoadingView];
                            [[UIApplication sharedApplication] endIgnoringInteractionEvents];
                        }];
}

-(void)delete {
    [[AppConfig shareConfig] showLoadingView];
    [RequestManager requestPath:kWEBIDDelete
                     parameters:@{@"service_code":_webObject.service_code,
                                  @"web_id_code":_webObject.web_id_code}
                        success:^(AFHTTPRequestOperation *operation, id result) {
                            [[AppConfig shareConfig] hiddenLoadingView];
                            if (result) {
                                if ([result[@"status"] integerValue] == 1)
                                {
                                    NSMutableArray *cardCodeList = [Entry getUserCardsByService_code:_webObject.service_code];
                                
                                    for (UserCardObject *obj in cardCodeList) {
                                        [Details deleteDetailCostInDBByCard_code:obj.card_code];
                                        [Pdf deletePdfByCard_code:obj.card_code];
                                    }
                                    
                                    [WebId deleteUserWebInDBByService_code:_webObject.service_code];
                                    //sort
                                    UserCardObject *deleteObj = [Entry getUserCardObjectByService_code:_webObject.service_code andCard_code:_webObject.card_code];
                                    [Entry deleteUserCardInDBByService_code:_webObject.service_code];
                                    
                                    //sort
                                    NSMutableArray *cardsList = [Entry getAllUserCards];
                                    for (UserCardObject *obj in cardsList) {
                                        if (obj.card_seq > deleteObj.card_seq) {
                                            [Entry updateUserCardSeqByCard_code:obj.card_code Service_code:obj.service_code seq:obj.card_seq-1];
                                        }
                                    }
                                    
                                    [kAppDelegate.appTabBarVC.homeVC reloadData];
                                    [kAppDelegate.appTabBarVC.recordVC reloadData];
                                    
                                    [ShareMethods showAlertBy:@"削除完了しました!"];
                                    [self.navigationController popViewControllerAnimated:YES];
                                }else
                                    [ShareMethods showAlertBy:@"削除失敗しました!"];
                            }
                        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                            [[AppConfig shareConfig] hiddenLoadingView];
                        }];
}

- (void)keyboardWillShow:(NSNotification *)notification {
    if (screenHeight != 568) {
        return;
    }
    
    if (_tag != 3) {
        return;
    }
    
    NSTimeInterval animationDuration = [[[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    UIViewAnimationCurve animationCurve = [[[notification userInfo] objectForKey:UIKeyboardAnimationCurveUserInfoKey] intValue];
    // UIViewAnimationCurve　を UIViewAnimationOptionに変換
    UIViewAnimationOptions animationOptions = animationCurve << 16;
    
    // 移動
    [UIView animateWithDuration:animationDuration
                          delay:0.0
                        options:animationOptions
                     animations:^{
                         self.view.center = CGPointMake(self.view.center.x, _center-65);
                     }
                     completion:^(BOOL finished) {}];
    _backFlg = YES;
}

- (void)keyboardWillHide:(NSNotification *)notification {
    if (screenHeight != 568) {
        return;
    }
    
    if (!_backFlg) {
        return;
    }
    
    NSTimeInterval animationDuration = [[[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    UIViewAnimationCurve animationCurve = [[[notification userInfo] objectForKey:UIKeyboardAnimationCurveUserInfoKey] intValue];
    // UIViewAnimationCurve　を UIViewAnimationOptionに変換
    UIViewAnimationOptions animationOptions = animationCurve << 16;
    
    // 元の位置に戻す
    [UIView animateWithDuration:animationDuration
                          delay:0.0
                        options:animationOptions
                     animations:^{
                         self.view.center = CGPointMake(self.view.center.x, _center);
                     }
                     completion:^(BOOL finished) {}];
    
    _backFlg = NO;
}

#pragma mark - Encrypt and Decode -

- (NSString *)getRandomGIv
{
    char data[16];
    for (int x=0;x<16;data[x++] = (char)('A' + (arc4random_uniform(26))));
    return randomStr = [[NSString alloc] initWithBytes:data length:16 encoding:NSUTF8StringEncoding];
}

- (NSString *)AES128Encrypt:(NSString *)plainText
{
    char keyPtr[kCCKeySizeAES128+1];
    memset(keyPtr, 0, sizeof(keyPtr));
    [kPasswordSecretKey getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];
    
    char ivPtr[kCCBlockSizeAES128+1];
    memset(ivPtr, 0, sizeof(ivPtr));
    [[self getRandomGIv] getCString:ivPtr maxLength:sizeof(ivPtr) encoding:NSUTF8StringEncoding];
    
    NSData* data = [plainText dataUsingEncoding:NSUTF8StringEncoding];
    NSUInteger dataLength = [data length];
    
    int diff = kCCKeySizeAES128 - (dataLength % kCCKeySizeAES128);
    int newSize = 0;
    
    if(diff > 0)
    {
        newSize = (int)dataLength + diff;
    }
    
    char dataPtr[newSize];
    memcpy(dataPtr, [data bytes], [data length]);
    for(int i = 0; i < diff; i++)
    {
        dataPtr[i + dataLength] = 0x00;
    }
    
    size_t bufferSize = newSize + kCCBlockSizeAES128;
    void *buffer = malloc(bufferSize);
    memset(buffer, 0, bufferSize);
    
    size_t numBytesCrypted = 0;
    
    CCCryptorStatus cryptStatus = CCCrypt(kCCEncrypt,
                                          kCCAlgorithmAES128,
                                          0x0000,               //No padding
                                          keyPtr,
                                          kCCKeySizeAES128,
                                          ivPtr,
                                          dataPtr,
                                          sizeof(dataPtr),
                                          buffer,
                                          bufferSize,
                                          &numBytesCrypted);
    
    if (cryptStatus == kCCSuccess) {
        NSData *resultData = [NSData dataWithBytesNoCopy:buffer length:numBytesCrypted];
        return [GTMBase64 stringByEncodingData:resultData];
    }
    free(buffer);
    return nil;
}



@end

//
//  CardVerifyViewController.m
//  Creco
//
//  Created by Windward on 15/5/25.
//  Copyright (c) 2015年 Windward. All rights reserved.
//

#import "CardVerifyViewController.h"
#import "WebViewController.h"
#import <CommonCrypto/CommonCryptor.h>
#import "GTMBase64.h"
#import "PopView.h"

@interface CardVerifyViewController () <UITextFieldDelegate>
{
    CGFloat selfOriginY;
    CGFloat moveDistance;
    
    UIButton *idButton;
    UIButton *webButton;
    
    UITextField *webIdTextField;
    UITextField *passwordTextField;
    
    UIButton *cardConfirmBtn;
    
    NSString *randomStr;
    NSString *pwEncryptStr;
}
@end

@implementation CardVerifyViewController

- (void)topicChanged
{
    [super topicChanged];
    
    [idButton removeFromSuperview];
    [webButton removeFromSuperview];
    [self addWordButtons];
    
    [cardConfirmBtn setImage:[UIImage imageTopicNamed:@"card_confirm"] forState:UIControlStateNormal];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navigationItem.title = @"認証情報入力";
    self.view.backgroundColor = COLOR_VIEW_OTHER_BACKGROUND;
    
    [self addWordButtons];
    
    UILabel *cardLabel = [[UILabel alloc] initWithFrame:CGRectMake(25.f, 97.f, kAllViewWidth-25.f*2, 15.f)];
    cardLabel.text = self.serverCardObj.card_master_name;
    cardLabel.textColor = [ShareMethods colorFromHexRGB:@"555555"];
    cardLabel.font = [UIFont boldSystemFontOfSize:15];
    [self.view addSubview:cardLabel];
    
    UILabel *expainLabel = [[UILabel alloc] initWithFrame:CGRectMake(25.f, cardLabel.bottom, kAllViewWidth-25.f*2, 40.f)];
    expainLabel.text = @"※正常に登録できない場合、金融機関サイトでのご確認を\nお願いいたします";
    expainLabel.textColor = [ShareMethods colorFromHexRGB:@"555555"];
    expainLabel.font = [UIFont systemFontOfSize:10];
    expainLabel.numberOfLines = 0;
    [self.view addSubview:expainLabel];
    
    CGFloat theY = expainLabel.bottom+13.f;
    for (int j = 0; j < 2; j ++)
    {
        UILabel *showLabel = [[UILabel alloc] initWithFrame:CGRectMake(25.f, theY, kAllViewWidth-25.f*2, 36.f)];
        showLabel.font = [UIFont systemFontOfSize:14];
        showLabel.textColor = [ShareMethods colorFromHexRGB:@"555555"];
        showLabel.numberOfLines = 2;
        [self.view addSubview:showLabel];
        
        theY = showLabel.bottom+1;
        
        UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0, theY, kAllViewWidth, 40.f)];
        bgView.backgroundColor = [UIColor whiteColor];
        bgView.layer.borderColor = COLOR_LINE.CGColor;
        bgView.layer.borderWidth = 0.5f;
        [self.view addSubview:bgView];
        
        UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(25.f, theY+1, kAllViewWidth-25.f*2, 38.f)];
        textField.backgroundColor = [UIColor clearColor];
        textField.font = [UIFont systemFontOfSize:14];
        textField.keyboardType = UIKeyboardTypeASCIICapable;
        textField.delegate = self;
        textField.tag = j;
        [self.view addSubview:textField];
        
        theY = textField.bottom+14.f;
        
        switch (j) {
            case 0:
                showLabel.text = [NSString stringWithFormat:@"%@ \nID（必須）", self.serverCardObj.service_name];
                webIdTextField = textField;
                break;
            case 1:
                showLabel.text = [NSString stringWithFormat:@"%@ \nパスワード（必須）", self.serverCardObj.service_name];
                passwordTextField = textField;
                passwordTextField.secureTextEntry = YES;
                break;
            default:
                break;
        }
    }
    
    UIImage *cardConfirmImg = [UIImage imageTopicNamed:@"card_confirm"];
    
    cardConfirmBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    cardConfirmBtn.frame = CGRectMake((kAllViewWidth-cardConfirmImg.size.width)/2, theY+(Is_iPhone4Or4s?0.f:8.f), cardConfirmImg.size.width, cardConfirmImg.size.height);
    [cardConfirmBtn setImage:cardConfirmImg forState:UIControlStateNormal];
    [cardConfirmBtn addTarget:self action:@selector(cardConfirm) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:cardConfirmBtn];
    
    if (Is_iPhone4Or4s)
        moveDistance = 120.f;
    else if (Is_iPhone5Or5s)
        moveDistance = 80.f;
    else
        moveDistance = 0.f;
}

- (void)addWordButtons
{
    for (int i = 0; i < 2; i ++)
    {
        UIButton *wordButton = [UIButton buttonWithType:UIButtonTypeCustom];
        wordButton.tag = i;
        wordButton.frame = CGRectMake(25.f, 20.f+29.f*i, kAllViewWidth-25.f*2, 18.f);
        wordButton.titleLabel.font = [UIFont systemFontOfSize:14];
        wordButton.titleLabel.textAlignment = NSTextAlignmentLeft;
        [wordButton setTitleColor:[ShareMethods colorFromHexRGB:[[NSUserDefaults standardUserDefaults] valueForKey:kAppTopicColor]] forState:UIControlStateNormal];
        wordButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        [wordButton addTarget:self action:@selector(goToWebView:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:wordButton];
        
        switch (i) {
            case 0:
                [wordButton setTitle:@"ID・パスワードをお持ちでない方はこちら" forState:UIControlStateNormal];
                idButton = wordButton;
                break;
            case 1:
                [wordButton setTitle:@"WEBサービスがわからない方はこちら" forState:UIControlStateNormal];
                webButton = wordButton;
                break;
            default:
                break;
        }
        
        NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:wordButton.titleLabel.text];
        NSRange strRange = {0,[str length]};
        [str addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleSingle] range:strRange];
        [wordButton setAttributedTitle:str forState:UIControlStateNormal];
    }
}

- (void)goToWebView:(UIButton *)wordBtn
{
    NSString *requestUrl = nil;
    switch (wordBtn.tag) {
        case 0:
            requestUrl = [NSString stringWithFormat:@"%@/%@", kCardVerifyNoIDURL, self.serverCardObj.service_code];
            break;
        case 1:
            requestUrl = kCardVerifyNoWebServiceURL;
            break;
        default:
            break;
    }
    
    WebViewController *webVC = [[WebViewController alloc] init];
    webVC.requestUrl = requestUrl;
    webVC.navigationItem.title = @"WEB VIEW";
    [(UINavigationController *)kAppDelegate.window.rootViewController pushViewController:webVC animated:YES];
}

- (void)cardConfirm
{
    if (webIdTextField.text.length == 0) {
        [ShareMethods showAlertBy:[NSString stringWithFormat:@"%@ IDを入力してください", self.serverCardObj.service_name]];
        return;
    }
    
    if (passwordTextField.text.length == 0) {
        [ShareMethods showAlertBy:[NSString stringWithFormat:@"%@ パスワードを入力してください", self.serverCardObj.service_name]];
        return;
    }
    
    self.view.frame = CGRectMake(self.view.left, selfOriginY, self.view.width, self.view.height);
    [self.view endEditing:YES];
    
    pwEncryptStr = [self AES128Encrypt:passwordTextField.text];
    
    idButton.userInteractionEnabled = NO;
    webButton.userInteractionEnabled = NO;
    cardConfirmBtn.userInteractionEnabled = NO;
    self.navigationItem.leftBarButtonItem.enabled = NO;
    kAppDelegate.appTabBarVC.tabBar.userInteractionEnabled = NO;
    [[AppConfig shareConfig] showLoadingView];
    [RequestManager requestPath:kWEBIDRegist
                     parameters:@{@"service_code":self.serverCardObj.service_code,
                                  @"web_id":webIdTextField.text,
                                  @"card_master_code":self.serverCardObj.card_master_code,
                                  @"initialization_vector":randomStr,//Must after Encryption-Data set
                                  @"password":pwEncryptStr}
                        success:^(AFHTTPRequestOperation *operation, id result) {
                            [[AppConfig shareConfig] hiddenLoadingView];
                            idButton.userInteractionEnabled = YES;
                            webButton.userInteractionEnabled = YES;
                            cardConfirmBtn.userInteractionEnabled = YES;
                            self.navigationItem.leftBarButtonItem.enabled = YES;
                            kAppDelegate.appTabBarVC.tabBar.userInteractionEnabled = YES;
                            if (result) {
                                if ([result[@"status"] integerValue] == 1)
                                {
                                    [self webidRegisterSuccessedWith:result[@"web_id_code"]];
                                }else if ([result[@"status"] integerValue] == 2)
                                {
                                    PopView *popView = [[PopView alloc] initWithPopViewType:PopViewTypeAddCertification withString:result[@"web_view_url"] andIntoSuperView:self.view];
                                    [popView showPopView];
                                    popView.certificationBlock = ^(NSDictionary *certDic)
                                    {
                                        if (((NSString *)certDic[@"web_id_code"]).length > 0)
                                            [self webidRegisterSuccessedWith:certDic[@"web_id_code"]];
                                        else
                                            [self cardConfirm];
                                    };
                                }else
                                    [ShareMethods showAlertBy:@"Server Error!"];
                            }
                        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                            idButton.userInteractionEnabled = YES;
                            webButton.userInteractionEnabled = YES;
                            cardConfirmBtn.userInteractionEnabled = YES;
                            self.navigationItem.leftBarButtonItem.enabled = YES;
                            kAppDelegate.appTabBarVC.tabBar.userInteractionEnabled = YES;
                            [[AppConfig shareConfig] hiddenLoadingView];
                        }];
}

- (void)webidRegisterSuccessedWith:(NSString *)web_id_code
{
    [WebId replaceUserWebIntoDBWithService_code:self.serverCardObj.service_code
                                   service_name:self.serverCardObj.service_name
                                    web_id_code:web_id_code
                                      card_code:nil
                                         web_id:webIdTextField.text
                          initialization_vector:randomStr
                                       password:pwEncryptStr
                                 detail_get_flg:YES];
    
    idButton.userInteractionEnabled = NO;
    webButton.userInteractionEnabled = NO;
    cardConfirmBtn.userInteractionEnabled = NO;
    self.navigationItem.leftBarButtonItem.enabled = NO;
    kAppDelegate.appTabBarVC.tabBar.userInteractionEnabled = NO;
    [[AppConfig shareConfig] showLoadingView];
    [RequestManager requestPath:kStartUp parameters:nil success:^(AFHTTPRequestOperation *operation, id result) {
        [[AppConfig shareConfig] hiddenLoadingView];
        idButton.userInteractionEnabled = YES;
        webButton.userInteractionEnabled = YES;
        cardConfirmBtn.userInteractionEnabled = YES;
        self.navigationItem.leftBarButtonItem.enabled = YES;
        
        if (kAppDelegate.appTabBarVC.selectedIndex == 0) {
            [self.navigationController popToRootViewControllerAnimated:YES];
        }else
        {
            [self.navigationController popToRootViewControllerAnimated:NO];
            kAppDelegate.appTabBarVC.selectedIndex = 0;
        }
        kAppDelegate.appTabBarVC.tabBar.userInteractionEnabled = YES;
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kWebIdIsRegistSuccessed object:nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadCalendar" object:nil];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [[AppConfig shareConfig] hiddenLoadingView];
        
        idButton.userInteractionEnabled = YES;
        webButton.userInteractionEnabled = YES;
        cardConfirmBtn.userInteractionEnabled = YES;
        self.navigationItem.leftBarButtonItem.enabled = YES;
        kAppDelegate.appTabBarVC.tabBar.userInteractionEnabled = YES;
    }];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    selfOriginY = self.view.top;//Must be set here!
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:YES];
    [[AppConfig shareConfig] hiddenLoadingView];
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

- (NSString *)AES128Decrypt:(NSString *)encryptText
{
    char keyPtr[kCCKeySizeAES128 + 1];
    memset(keyPtr, 0, sizeof(keyPtr));
    [kPasswordSecretKey getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];
    
    char ivPtr[kCCBlockSizeAES128 + 1];
    memset(ivPtr, 0, sizeof(ivPtr));
    [[self getRandomGIv] getCString:ivPtr maxLength:sizeof(ivPtr) encoding:NSUTF8StringEncoding];
    
    NSData *data = [GTMBase64 decodeData:[encryptText dataUsingEncoding:NSUTF8StringEncoding]];
    NSUInteger dataLength = [data length];
    size_t bufferSize = dataLength + kCCBlockSizeAES128;
    void *buffer = malloc(bufferSize);
    
    size_t numBytesCrypted = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCDecrypt,
                                          kCCAlgorithmAES128,
                                          0x0000,
                                          keyPtr,
                                          kCCBlockSizeAES128,
                                          ivPtr,
                                          [data bytes],
                                          dataLength,
                                          buffer,
                                          bufferSize,
                                          &numBytesCrypted);
    if (cryptStatus == kCCSuccess) {
        NSData *resultData = [NSData dataWithBytesNoCopy:buffer length:numBytesCrypted];
        return [[NSString alloc] initWithData:resultData encoding:NSUTF8StringEncoding];
    }
    free(buffer);
    return nil;
}

#pragma mark - UITextField Delegate -

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if (Is_iPhone4Or4s || Is_iPhone5Or5s) {
        if (Is_iPhone4Or4s)
            self.view.frame = CGRectMake(self.view.left, selfOriginY-moveDistance, self.view.width, self.view.height);
        else
        {
            if (textField.tag == 1)
                self.view.frame = CGRectMake(self.view.left, selfOriginY-moveDistance, self.view.width, self.view.height);
        }
    }
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (Is_iPhone4Or4s || Is_iPhone5Or5s)
        self.view.frame = CGRectMake(self.view.left, selfOriginY, self.view.width, self.view.height);
    [textField resignFirstResponder];
    return YES;
}

#pragma mark -

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    self.view.frame = CGRectMake(self.view.left, selfOriginY, self.view.width, self.view.height);
    [self.view endEditing:YES];
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

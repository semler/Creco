//
//  GoogleViewController.m
//  Creco
//
//  Created by 于　超 on 2015/06/09.
//  Copyright (c) 2015年 Windward. All rights reserved.
//

#import "GoogleViewController.h"
#import "QBImagePickerController.h"
#import "QBAssetCell.h"
#import "CatLoadingView.h"
#import "CalendarManager.h"
#import "UIAlertView+BlocksKit.h"
#import "Reachability.h"

#define screenWidth            [UIScreen mainScreen].bounds.size.width
#define screenHeight           [UIScreen mainScreen].bounds.size.height

@interface GoogleViewController () <UITextFieldDelegate, NSURLSessionDataDelegate> {
    // 青い枠
    UIImageView *line;
    UIImageView *imageView1;
    UIImageView *imageView2;
    UIImageView *imageView3;
    UIImageView *imageView4;
    UIButton *button1;
    UIButton *button2;
    UIButton *button3;
    UIButton *button4;
}

@property (nonatomic, strong) UIButton *okButton;
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) UITextField *textField;

@end

@implementation GoogleViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [CalendarManager sharedManager].isGoogle = YES;
    
    UIView *headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 64)];
    headView.backgroundColor = [UIColor whiteColor];
    
    UIView *searchView = [[UIView alloc] initWithFrame:CGRectMake(0, 64, screenWidth, 64)];
    
    _textField = [[UITextField alloc] initWithFrame:CGRectMake(20, 10, screenWidth-40, 44)];
    //_cancelButton.hidden = YES;
    // プレースホルダ
    _textField.placeholder = @"検索したい文言を入力";
    _textField.returnKeyType = UIReturnKeySearch;   
    // 枠線のスタイルを設定
    _textField.borderStyle = UITextBorderStyleRoundedRect;
    // クリアボタンモード
    _textField.clearButtonMode = UITextFieldViewModeWhileEditing;
    // ラベルのテキストのフォントを設定
    _textField.font = [UIFont fontWithName:@"HiraKakuPro-W3" size:32];
    _textField.textColor = [UIColor colorWithRed:0.486 green:0.486 blue:0.486 alpha:1];
    // デリゲートを設定
    _textField.delegate = self;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [searchView addSubview:_textField];
    
    [headView addSubview:searchView];
    
    // 確定ボタン
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, screenHeight-49, screenWidth, 49)];
    footerView.backgroundColor = [ShareMethods colorFromHexRGB:[[NSUserDefaults standardUserDefaults] valueForKey:kAppTopicColor]] ;
    
    _okButton = [[UIButton alloc] initWithFrame:CGRectMake(screenWidth-80, 10, 60, 30)];
    [_okButton setTitle:@"決定" forState:UIControlStateNormal];
    [_okButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_okButton setBackgroundColor:[ShareMethods colorFromHexRGB:[[NSUserDefaults standardUserDefaults] valueForKey:kAppTopicColor]]];
    _okButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    [_okButton addTarget:self action:@selector(ok) forControlEvents:UIControlEventTouchUpInside];
    
    [footerView addSubview:_okButton];
    [self.view addSubview:headView];
    [self.view addSubview:footerView];
    [self.view addSubview:searchView];
    
    imageView1 = [[UIImageView alloc] initWithFrame:CGRectMake(1, 128, screenWidth/4-2, screenWidth/4-2)];
    imageView2 = [[UIImageView alloc] initWithFrame:CGRectMake(screenWidth/4+1, 128, screenWidth/4-2, screenWidth/4-2)];
    imageView3 = [[UIImageView alloc] initWithFrame:CGRectMake(screenWidth/4*2+1, 128, screenWidth/4-2, screenWidth/4-2)];
    imageView4 = [[UIImageView alloc] initWithFrame:CGRectMake(screenWidth/4*3+1, 128, screenWidth/4-2, screenWidth/4-2)];
    [imageView1 setContentMode:UIViewContentModeScaleAspectFit];
    [imageView2 setContentMode:UIViewContentModeScaleAspectFit];
    [imageView3 setContentMode:UIViewContentModeScaleAspectFit];
    [imageView4 setContentMode:UIViewContentModeScaleAspectFit];
    [self.view addSubview:imageView1];
    [self.view addSubview:imageView2];
    [self.view addSubview:imageView3];
    [self.view addSubview:imageView4];
    button1 = [[UIButton alloc] initWithFrame:imageView1.frame];
    button1.backgroundColor = [UIColor clearColor];
    [button1 addTarget:self action:@selector(button1Pressed) forControlEvents:UIControlEventTouchUpInside];
    button2 = [[UIButton alloc] initWithFrame:imageView2.frame];
    button2.backgroundColor = [UIColor clearColor];
    [button2 addTarget:self action:@selector(button2Pressed) forControlEvents:UIControlEventTouchUpInside];
    button3 = [[UIButton alloc] initWithFrame:imageView3.frame];
    button3.backgroundColor = [UIColor clearColor];
    [button3 addTarget:self action:@selector(button3Pressed) forControlEvents:UIControlEventTouchUpInside];
    button4 = [[UIButton alloc] initWithFrame:imageView4.frame];
    button4.backgroundColor = [UIColor clearColor];
    [button4 addTarget:self action:@selector(button4Pressed) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button1];
    [self.view addSubview:button2];
    [self.view addSubview:button3];
    [self.view addSubview:button4];
    line = [[UIImageView alloc] init];
    line.frame = CGRectMake(0, 0, 0, 0);
    line.image = [UIImage imageTopicNamed:@"line"];
    [self.view addSubview:line];
    
    if (_imageURLs.count > 0) {
        NSURL *url1 = [NSURL URLWithString:[_imageURLs objectAtIndex:0]];
        [imageView1 sd_setImageWithURL:url1 placeholderImage:[UIImage imageNamed:@"box_searching"] options:SDWebImageDelayPlaceholder completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            if (error != nil) {
                imageView1.image = [UIImage imageNamed:@"box_noimage"];
            }
        }];
    }
    if (_imageURLs.count > 1) {
        NSURL *url2 = [NSURL URLWithString:[_imageURLs objectAtIndex:1]];
        [imageView2 sd_setImageWithURL:url2 placeholderImage:[UIImage imageNamed:@"box_searching"] options:SDWebImageDelayPlaceholder completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            if (error != nil) {
                imageView2.image = [UIImage imageNamed:@"box_noimage"];
            }
        }];
    }
    if (_imageURLs.count > 2) {
        NSURL *url3 = [NSURL URLWithString:[_imageURLs objectAtIndex:2]];
        [imageView3 sd_setImageWithURL:url3 placeholderImage:[UIImage imageNamed:@"box_searching"] options:SDWebImageDelayPlaceholder completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            if (error != nil) {
                imageView3.image = [UIImage imageNamed:@"box_noimage"];
            }
        }];
    }
    if (_imageURLs.count > 3) {
        NSURL *url4 = [NSURL URLWithString:[_imageURLs objectAtIndex:3]];
        [imageView4 sd_setImageWithURL:url4 placeholderImage:[UIImage imageNamed:@"box_searching"] options:SDWebImageDelayPlaceholder completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            if (error != nil) {
                imageView4.image = [UIImage imageNamed:@"box_noimage"];
            }
        }];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // Configure navigation item
    self.navigationItem.title = @"Google検索";
    //self.navigationItem.prompt = self.imagePickerController.prompt;
    [self.navigationController.navigationBar setTintColor:[ShareMethods colorFromHexRGB:[[NSUserDefaults standardUserDefaults] valueForKey:kAppTopicColor]]];
    
    _okButton.hidden = YES;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [CalendarManager sharedManager].isGoogle = NO;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

#pragma mark - Actions

//- (IBAction)cancel:(id)sender
//{
//    if ([self.imagePickerController.delegate respondsToSelector:@selector(qb_imagePickerControllerDidCancel:)]) {
//        [self.imagePickerController.delegate qb_imagePickerControllerDidCancel:self.imagePickerController];
//    }
//}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    //
}

-(void) ok {
    if ([_imagePickerController.delegate respondsToSelector:@selector(qb_imagePickerController:didSelectImage:)]) {
        [_imagePickerController.delegate qb_imagePickerController:_imagePickerController didSelectImage:_image];
    }
}

- (void)keyboardWillShow:(NSNotification *)notification {
    _textField.placeholder = @"検索";
    //_cancelButton.hidden = NO;
}

- (void)keyboardWillHide:(NSNotification *)notification {
    
    _textField.placeholder = @"検索したい文言を入力";
    //_cancelButton.hidden = YES;
}

/**
 * キーボードでReturnキーが押されたとき
 * @param textField イベントが発生したテキストフィールド
 */
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    // キーボードを隠す
    [self.view endEditing:YES];

    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    
    NetworkStatus status = [reachability currentReachabilityStatus];
    
    if( status == NotReachable ) {
        [UIAlertView bk_showAlertViewWithTitle:@"接続失敗しました。\n通信環境の良い状態で再度接続してください。"
                                       message:nil
                             cancelButtonTitle:nil
                             otherButtonTitles:@[@"OK"]
                                       handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
                                           [AppConfig shareConfig].isShowAPIAlert = NO;
                                       }];        
    } else {
         [self search:_textField.text];
    }
    
    return YES;
}

- (void)search:(NSString *)keyword {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    NSString *urlBaseString = @"http://ajax.googleapis.com/ajax/services/search/images?v=1.0&hl=ja&q=%@";
    NSString *urlString = [NSString stringWithFormat:urlBaseString, keyword];
    NSURL *url = [NSURL URLWithString:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:nil  ];
    
    imageView1.image = [UIImage imageNamed:@"box_searching"];
    imageView2.image = [UIImage imageNamed:@"box_searching"];
    imageView3.image = [UIImage imageNamed:@"box_searching"];
    imageView4.image = [UIImage imageNamed:@"box_searching"];
    NSURLSessionDataTask *jsonData = [session dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (!error) {
            NSHTTPURLResponse *httpResp = (NSHTTPURLResponse *) response;
            if (httpResp.statusCode == 200) {
                NSLog(@"success!");
                NSError *jsonError;
                
                NSDictionary *rawJSON = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&jsonError];
               
                [_imageURLs removeAllObjects];
                if (!jsonError) {
                    NSDictionary *responseData = rawJSON[@"responseData"];
                    if ([responseData isKindOfClass:[NSDictionary class]]) {
                        NSArray *results = responseData[@"results"];
                        for (NSDictionary *result in results) {
                            NSString *imageURL = result[@"url"];
                            [_imageURLs addObject:imageURL];
                        }
                    
                        if (_imageURLs.count > 0) {
                            NSURL *url1 = [NSURL URLWithString:[_imageURLs objectAtIndex:0]];
                            [imageView1 sd_setImageWithURL:url1 placeholderImage:[UIImage imageNamed:@"box_searching"] options:SDWebImageDelayPlaceholder completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                if (error != nil) {
                                    imageView1.image = [UIImage imageNamed:@"box_noimage"];
                                }
                            }];
                        }
                        if (_imageURLs.count > 1) {
                            NSURL *url2 = [NSURL URLWithString:[_imageURLs objectAtIndex:1]];
                            [imageView2 sd_setImageWithURL:url2 placeholderImage:[UIImage imageNamed:@"box_searching"] options:SDWebImageDelayPlaceholder completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                if (error != nil) {
                                    imageView2.image = [UIImage imageNamed:@"box_noimage"];
                                }
                            }];
                        }
                        if (_imageURLs.count > 2) {
                            NSURL *url3 = [NSURL URLWithString:[_imageURLs objectAtIndex:2]];
                            [imageView3 sd_setImageWithURL:url3 placeholderImage:[UIImage imageNamed:@"box_searching"] options:SDWebImageDelayPlaceholder completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                if (error != nil) {
                                    imageView3.image = [UIImage imageNamed:@"box_noimage"];
                                }
                            }];
                        }
                        if (_imageURLs.count > 3) {
                            NSURL *url4 = [NSURL URLWithString:[_imageURLs objectAtIndex:3]];
                            [imageView4 sd_setImageWithURL:url4 placeholderImage:[UIImage imageNamed:@"box_searching"] options:SDWebImageDelayPlaceholder completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                if (error != nil) {
                                    imageView4.image = [UIImage imageNamed:@"box_noimage"];
                                }
                            }];
                        }
                        
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
                        });
                    }
                }
            }
        } else {
            //
        }
    }];
    [jsonData resume];
}

// キーボード以外タップした場合
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [_textField resignFirstResponder];
}

-(void)button1Pressed {
    line.frame = button1.frame;
    _okButton.hidden = NO;
    _image = imageView1.image;
}

-(void)button2Pressed {
    line.frame = button2.frame;
    _okButton.hidden = NO;
    _image = imageView2.image;
}

-(void)button3Pressed {
    line.frame = button3.frame;
    _okButton.hidden = NO;
    _image = imageView3.image;
}

-(void)button4Pressed {
    line.frame = button4.frame;
    _okButton.hidden = NO;
    _image = imageView4.image;
}

@end

//
//  CoverViewController.m
//  Creco
//
//  Created by 于　超 on 2015/06/03.
//  Copyright (c) 2015年 Windward. All rights reserved.
//

#import "CoverViewController.h"
#import "PhotoViewController.h"
#import "QBImagePicker.h"
#import "CalendarManager.h"
#import "CalendarData.h"
#import "BigButton.h"

#define screenWidth            [UIScreen mainScreen].bounds.size.width
#define screenHeight           [UIScreen mainScreen].bounds.size.height

@interface CoverViewController ()<UITextViewDelegate, QBImagePickerControllerDelegate, NSURLSessionDataDelegate> {
    PhotoViewController *photoViewController;
    QBImagePickerController *picker;
    UIScrollView *scrollView;
    UITextView *memoTextView;
    UIView *view;
    UIImageView *imageView;
    UIImageView *imageView1;
    UIImageView *imageView2;
    UIImageView *imageView3;
    UIImageView *lineView1;
    UIImageView *lineView2;
    UIImageView *lineView3;
    UIButton *firstbutton;
    UIButton *secondButton;
    UIButton *thirdButton;
    UIButton *saveButton;
}

@property (nonatomic) int height;
@property (nonatomic) NSString *text;

@end

@implementation CoverViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor clearColor];
    
    UIImageView *bg = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 280, 440)];
    bg.image = [UIImage imageTopicNamed:@"block"];
    [self.view addSubview:bg];
    
    BigButton *closeButton = [[BigButton alloc] initWithFrame:CGRectMake(10, 9, 12, 12)];
    [closeButton setImage:[UIImage imageNamed:@"btn_cross"] forState:UIControlStateNormal];
    [closeButton addTarget:self action:@selector(closeButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:closeButton];
    UILabel *dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, 5, 200, 20)];
    dateLabel.textAlignment = NSTextAlignmentCenter;
    dateLabel.font = [UIFont fontWithName:@"HiraKakuProN-W6" size:12];
    NSString *year = [_detailCostObject.date substringWithRange:NSMakeRange(0,4)];
    NSString *month = [_detailCostObject.date substringWithRange:NSMakeRange(5,2)];
    NSString *day = [_detailCostObject.date substringWithRange:NSMakeRange(8,2)];
    dateLabel.text = [NSString stringWithFormat:@"%@/%@/%@", year, month, day];
    dateLabel.textColor = [UIColor whiteColor];
    [self.view addSubview:dateLabel];
    BigButton *writeButton = [[BigButton alloc] initWithFrame:CGRectMake(254, 7, 16, 16)];
    [writeButton setImage:[UIImage imageNamed:@"btn_write"] forState:UIControlStateNormal];
    [writeButton addTarget:self action:@selector(writeButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:writeButton];
    
    scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 30, 280, 405)];
    scrollView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:scrollView];
    
    UIImageView *cardImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 16, 17, 13)];
    cardImageView.image = [UIImage imageTopicNamed:@"icon_card"];
    [scrollView addSubview:cardImageView];
    UILabel *cardLabel = [[UILabel alloc] initWithFrame:CGRectMake(37, 15, 233, 15)];
    cardLabel.font = [UIFont fontWithName:@"HiraKakuProN-W3" size:12];
    cardLabel.textColor = [UIColor colorWithRed:0.314 green:0.314 blue:0.314 alpha:1];
    NSString *cardName;
    NSMutableArray *cardsArray = [Entry getAllUserCards];
    if (cardsArray.count > 1) {
        cardName = [Entry getCardNameByCardCode:_detailCostObject.card_code];
    } else {
        cardName = [SampleCard getCardMasterNameBy:_detailCostObject.card_code];
    }
    cardLabel.text = cardName;
    [scrollView addSubview:cardLabel];
    
    UIImageView *placeImageView = [[UIImageView alloc] initWithFrame:CGRectMake(12, 45, 13, 15)];
    placeImageView.image = [UIImage imageTopicNamed:@"icon_place"];
    [scrollView addSubview:placeImageView];
    UILabel *placeLabel = [[UILabel alloc] initWithFrame:CGRectMake(37, 45, 233, 15)];
    placeLabel.font = [UIFont fontWithName:@"HiraKakuProN-W3" size:12];
    placeLabel.textColor = [UIColor colorWithRed:0.314 green:0.314 blue:0.314 alpha:1];
    placeLabel.text = _detailCostObject.name;
    [scrollView addSubview:placeLabel];
    
    UIImageView *moneyImageView = [[UIImageView alloc] initWithFrame:CGRectMake(11, 75, 15, 15)];
    moneyImageView.image = [UIImage imageTopicNamed:@"icon_money"];
    [scrollView addSubview:moneyImageView];
    UILabel *moneyLabel = [[UILabel alloc] initWithFrame:CGRectMake(37, 75, 233, 15)];
    moneyLabel.font = [UIFont fontWithName:@"HiraKakuProN-W3" size:12];
    moneyLabel.textColor = [UIColor colorWithRed:0.314 green:0.314 blue:0.314 alpha:1];
    // 数値を3桁ごとカンマ区切り形式で文字列に変換する
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
    [formatter setGroupingSeparator:@","];
    [formatter setGroupingSize:3];
    NSString *result = [formatter stringFromNumber:[NSNumber numberWithInt:[_detailCostObject.price intValue]]];
    moneyLabel.text = result;
    [scrollView addSubview:moneyLabel];
    
    UIImageView *memoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(12, 105, 13, 15)];
    memoImageView.image = [UIImage imageTopicNamed:@"icon_memo"];
    [scrollView addSubview:memoImageView];
    // textviewサイズ計算
    memoTextView = [[UITextView alloc] initWithFrame:CGRectMake(37, 105, 233, 15)];
    NSDictionary *attributes = @{ NSForegroundColorAttributeName : [UIColor colorWithRed:0.314 green:0.314 blue:0.314 alpha:1], NSFontAttributeName : [UIFont systemFontOfSize:12.0f] };
    memoTextView.textContainer.lineFragmentPadding = 0;
    memoTextView.textContainerInset = UIEdgeInsetsZero;
    memoTextView.backgroundColor = [UIColor whiteColor];
    memoTextView.font = [UIFont systemFontOfSize:12.0f];
    memoTextView.textColor = [UIColor colorWithRed:0.314 green:0.314 blue:0.314 alpha:1];
    NSAttributedString *string = [[NSAttributedString alloc] initWithString:_detailCostObject.note attributes:attributes];
    memoTextView.attributedText = string;
    CGRect frame = [string boundingRectWithSize:CGSizeMake(233, 100000) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading context:nil];
    _height = frame.size.height+3;
    if (_height < 15) {
        _height = 15;
    }
    memoTextView.frame = CGRectMake(37, 105, 233, _height);
    memoTextView.scrollEnabled = NO;
    memoTextView.returnKeyType = UIReturnKeyDefault;
    memoTextView.editable = NO;
    memoTextView.delegate = self;
    [scrollView addSubview:memoTextView];
    
    view = [[UIView alloc] initWithFrame:CGRectMake(10, 120+_height, 260, 275)];
    [scrollView addSubview:view];
    
    imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 260, 175)];
    imageView.layer.cornerRadius = 5.0f;
    imageView.layer.masksToBounds = YES;
    [view addSubview:imageView];
    
    imageView1 = [[UIImageView alloc] initWithFrame:CGRectMake(0, 185, 80, 80)];
    imageView1.layer.cornerRadius = 5.0f;
    imageView1.layer.masksToBounds = YES;
    [view addSubview:imageView1];
    imageView2 = [[UIImageView alloc] initWithFrame:CGRectMake(90, 185, 80, 80)];
    imageView2.layer.cornerRadius = 5.0f;
    imageView2.layer.masksToBounds = YES;
    [view addSubview:imageView2];
    imageView3 = [[UIImageView alloc] initWithFrame:CGRectMake(180, 185, 80, 80)];
    imageView3.layer.cornerRadius = 5.0f;
    imageView3.layer.masksToBounds = YES;
    [view addSubview:imageView3];
    
    lineView1 = [[UIImageView alloc] initWithFrame:imageView1.frame];
    lineView1.image = [UIImage imageNamed:@"line_yellow"];
    lineView1.layer.cornerRadius = 5.0f;
    lineView1.layer.masksToBounds = YES;
    lineView1.hidden = YES;
    [view addSubview:lineView1];
    lineView2 = [[UIImageView alloc] initWithFrame:imageView2.frame];
    lineView2.image = [UIImage imageNamed:@"line_yellow"];
    lineView2.layer.cornerRadius = 5.0f;
    lineView2.layer.masksToBounds = YES;
    lineView2.hidden = YES;
    [view addSubview:lineView2];
    lineView3 = [[UIImageView alloc] initWithFrame:imageView3.frame];
    lineView3.image = [UIImage imageNamed:@"line_yellow"];
    lineView3.layer.cornerRadius = 5.0f;
    lineView3.layer.masksToBounds = YES;
    lineView3.hidden = YES;
    [view addSubview:lineView3];
    
    firstbutton = [[UIButton alloc] initWithFrame:imageView1.frame];
    [firstbutton setBackgroundColor: [UIColor clearColor]];
    [firstbutton addTarget:self action:@selector(firstButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:firstbutton];
    secondButton = [[UIButton alloc] initWithFrame:imageView2.frame];
    [secondButton setBackgroundColor: [UIColor clearColor]];
    [secondButton addTarget:self action:@selector(secondButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:secondButton];
    thirdButton = [[UIButton alloc] initWithFrame:imageView3.frame];
    [thirdButton setBackgroundColor: [UIColor clearColor]];
    [thirdButton addTarget:self action:@selector(thirdButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:thirdButton];
    
    scrollView.contentSize = CGSizeMake(280, 390+_height);
    
    // CalendarManager
    CalendarData *data = [[CalendarData alloc] init];
    data.bestShot = _detailCostObject.bestshot;
    data.code = _detailCostObject.code;
    // 画像パース設定
    [data setPath:_detailCostObject.date];
    [[CalendarManager sharedManager].dataList replaceObjectAtIndex:_index withObject:data];
}

-(void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    CalendarData *data = [[CalendarManager sharedManager].dataList objectAtIndex:_index];
    
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    if (data.bestShot == 1) {
        // picture1
        UIImage *image = [UIImage imageWithContentsOfFile:data.imagePath1];
        if (image != nil) {
            imageView.image = image;
            lineView1.hidden = NO;
            lineView2.hidden = YES;
            lineView3.hidden = YES;
        } else {
            imageView.image = [UIImage imageNamed:@"box_noimage"];
            lineView1.hidden = YES;
            lineView2.hidden = YES;
            lineView3.hidden = YES;
        }
    } else if (data.bestShot == 2) {
        // picture2
        UIImage *image = [UIImage imageWithContentsOfFile:data.imagePath2];
        if (image != nil) {
            imageView.image = image;
            lineView1.hidden = YES;
            lineView2.hidden = NO;
            lineView3.hidden = YES;
        } else {
            imageView.image = [UIImage imageNamed:@"box_noimage"];
            lineView1.hidden = YES;
            lineView2.hidden = YES;
            lineView3.hidden = YES;
        }
    } else if (data.bestShot == 3) {
        // picture3
        UIImage *image = [UIImage imageWithContentsOfFile:data.imagePath3];
        if (image != nil) {
            imageView.image = image;
            lineView1.hidden = YES;
            lineView2.hidden = YES;
            lineView3.hidden = NO;
        } else {
            imageView.image = [UIImage imageNamed:@"box_noimage"];
            lineView1.hidden = YES;
            lineView2.hidden = YES;
            lineView3.hidden = YES;
        }
    } else {
        data.bestShot = 1;
        UIImage *image = [UIImage imageWithContentsOfFile:data.imagePath1];
        if (image != nil) {
            imageView.image = image;
            lineView1.hidden = NO;
            lineView2.hidden = YES;
            lineView3.hidden = YES;
        } else {
             imageView.image = [UIImage imageNamed:@"box_noimage"];
            lineView1.hidden = YES;
            lineView2.hidden = YES;
            lineView3.hidden = YES;
        }
    }
    
    [imageView1 setContentMode:UIViewContentModeScaleAspectFit];
    [imageView2 setContentMode:UIViewContentModeScaleAspectFit];
    [imageView3 setContentMode:UIViewContentModeScaleAspectFit];
    
    UIImage *image1 = [UIImage imageWithContentsOfFile:data.imagePath1];
    UIImage *image2 = [UIImage imageWithContentsOfFile:data.imagePath2];
    UIImage *image3 = [UIImage imageWithContentsOfFile:data.imagePath3];
    if (image1 != nil) {
        imageView1.image = image1;
    } else {
        imageView1.image = [UIImage imageNamed:@"btn_plus.png"];
    }
    if (image2 != nil) {
        imageView2.image = image2;
    } else {
        imageView2.image = [UIImage imageNamed:@"btn_plus.png"];
    }
    if (image3 != nil) {
        imageView3.image = image3;
    } else {
        imageView3.image = [UIImage imageNamed:@"btn_plus.png"];
    }
    [[CalendarManager sharedManager].dataList replaceObjectAtIndex:_index withObject:data];
    
    // QBImagePickerController
    picker = [QBImagePickerController new];
    picker.delegate = self;
    picker.filterType = QBImagePickerControllerFilterTypePhotos;
    picker.allowsMultipleSelection = NO;
    picker.showsNumberOfSelectedAssets = YES;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadImage) name:@"reloadImage" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    CalendarData *data = [[CalendarManager sharedManager].dataList objectAtIndex:_index];
    [[CalendarManager sharedManager].dataList replaceObjectAtIndex:_index withObject:data];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)keyboardWillShow:(NSNotification *)notification {
    // スクロール禁止
    [CalendarManager sharedManager].isKeybordOn = YES;
    NSNotification *notification2 =[NSNotification notificationWithName:@"scroll" object:nil userInfo:nil];
    [[NSNotificationCenter defaultCenter] postNotification:notification2];
}

- (void)keyboardWillHide:(NSNotification *)notification {
    [CalendarManager sharedManager].isKeybordOn = NO;
    NSLog(@"%d", _index);
    NSLog(@"%d", [CalendarManager sharedManager].currentIndex);
    if (_index != [CalendarManager sharedManager].currentIndex) {
        return;
    } else {
        NSLog(@"XXXXXXXX:%d", _index);
    }
    if ([CalendarManager sharedManager].isGoogle) {
        return;
    }
    
    if (![CalendarManager sharedManager].isSaveButtonOn) {
        // 保存ボタン
        saveButton = [[UIButton alloc] initWithFrame:CGRectMake(screenWidth/2-60, screenHeight-65, 120, 40)];
        [saveButton setImage:[UIImage imageNamed:@"btn_save"] forState:UIControlStateNormal];
        [saveButton addTarget:self action:@selector(save) forControlEvents:UIControlEventTouchUpInside];
        AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
        [appDelegate.window addSubview:saveButton];
        saveButton.hidden = NO;
    }
    
    CalendarData *data = [[CalendarManager sharedManager].dataList objectAtIndex:_index];
    [CalendarManager sharedManager].isSaveButtonOn = YES;
    [[CalendarManager sharedManager].dataList replaceObjectAtIndex:_index withObject:data];
    // スクロール禁止
    NSNotification *notification2 =[NSNotification notificationWithName:@"scroll" object:nil userInfo:nil];
    [[NSNotificationCenter defaultCenter] postNotification:notification2];
}

// キーボード以外タップした場合
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    memoTextView.editable = NO;
    memoTextView.backgroundColor = [UIColor whiteColor];
    [memoTextView resignFirstResponder];
}

/**
 * キーボードでReturnキーが押されたとき
 * @param textField イベントが発生したテキストフィールド
 */
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    // キーボードを隠す
    [self.view endEditing:YES];
    memoTextView.editable = NO;
    memoTextView.backgroundColor = [UIColor whiteColor];
    [memoTextView resignFirstResponder];
    return YES;
}

- (void)closeButtonPressed {
    [saveButton removeFromSuperview];
    CalendarData *data = [[CalendarManager sharedManager].dataList objectAtIndex:_index];
    [CalendarManager sharedManager].isSaveButtonOn = NO;
    [[CalendarManager sharedManager].dataList replaceObjectAtIndex:_index withObject:data];
    NSNotification *notification =[NSNotification notificationWithName:@"scroll" object:nil userInfo:nil];
    [[NSNotificationCenter defaultCenter] postNotification:notification];

    if (self.delegate && [self.delegate respondsToSelector:@selector(removeCoverFlow)]) {
        [self.delegate removeCoverFlow];
    }
}

- (void)writeButtonPressed {
    memoTextView.editable = YES;
    memoTextView.backgroundColor = [UIColor colorWithRed:0.863 green:0.863 blue:0.863 alpha:0.9];
    [memoTextView becomeFirstResponder];
}

- (void)firstButtonPressed {
    photoViewController = [[PhotoViewController alloc] init];
    photoViewController.index = _index;
    photoViewController.detailCostObject = _detailCostObject;
    CalendarData *data = [[CalendarManager sharedManager].dataList objectAtIndex:_index];
    data.selectedButton = 1;
    photoViewController.view.frame = CGRectMake(0, 0, screenWidth, screenHeight);
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    
    UIImage *image1 = [UIImage imageWithContentsOfFile:data.imagePath1];
    if (image1 != nil) {
        // 編集
        data.addFlg = NO;
        [appDelegate.window addSubview:photoViewController.view];
    } else {
        // 追加
        data.addFlg = YES;
        [appDelegate.window addSubview:photoViewController.view];
    }
    [[CalendarManager sharedManager].dataList replaceObjectAtIndex:_index withObject:data];
    
    // google検索用
    [CalendarManager sharedManager].keyword = _detailCostObject.name;
}

- (void)secondButtonPressed {
    photoViewController = [[PhotoViewController alloc] init];
    photoViewController.index = _index;
    photoViewController.detailCostObject = _detailCostObject;
    CalendarData *data = [[CalendarManager sharedManager].dataList objectAtIndex:_index];
    data.selectedButton = 2;
    photoViewController.view.frame = CGRectMake(0, 0, screenWidth, screenHeight);
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    
    UIImage *image2 = [UIImage imageWithContentsOfFile:data.imagePath2];
    if (image2 != nil) {
        // 編集
        data.addFlg = NO;
        [appDelegate.window addSubview:photoViewController.view];
    } else {
        // 追加
        data.addFlg = YES;
        [appDelegate.window addSubview:photoViewController.view];
    }
    [[CalendarManager sharedManager].dataList replaceObjectAtIndex:_index withObject:data];
    
    // google検索用
    [CalendarManager sharedManager].keyword = _detailCostObject.name;
}

- (void)thirdButtonPressed {
    photoViewController = [[PhotoViewController alloc] init];
    photoViewController.index = _index;
    photoViewController.detailCostObject = _detailCostObject;
    CalendarData *data = [[CalendarManager sharedManager].dataList objectAtIndex:_index];
    data.selectedButton = 3;
    photoViewController.view.frame = CGRectMake(0, 0, screenWidth, screenHeight);
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    
    UIImage *image3 = [UIImage imageWithContentsOfFile:data.imagePath3];
    if (image3 != nil) {
        // 編集
        data.addFlg = NO;
        [appDelegate.window addSubview:photoViewController.view];
    } else {
        // 追加
        data.addFlg = YES;
        [appDelegate.window addSubview:photoViewController.view];
    }
    [[CalendarManager sharedManager].dataList replaceObjectAtIndex:_index withObject:data];
    
    // google検索用
    [CalendarManager sharedManager].keyword = _detailCostObject.name;
}

#pragma mark - QBImagePickerControllerDelegate

- (void)qb_imagePickerController:(QBImagePickerController *)imagePickerController didSelectImage:(UIImage *)image
{
    imageView.image = image;
    [thirdButton setBackgroundImage:image forState:UIControlStateNormal];
    [picker.view removeFromSuperview];
}

-(void)save {
    CalendarData *data = [[CalendarManager sharedManager].dataList objectAtIndex:_index];
    [Details updateDetailCostsByDate:_detailCostObject.date code:_detailCostObject.code memo:memoTextView.text bestShot:data.bestShot];
    [saveButton removeFromSuperview];
    [CalendarManager sharedManager].isSaveButtonOn = NO;
    [[CalendarManager sharedManager].dataList replaceObjectAtIndex:_index withObject:data];
    NSNotification *notification =[NSNotification notificationWithName:@"scroll" object:nil userInfo:nil];
    [[NSNotificationCenter defaultCenter] postNotification:notification];
}

// 編集画面保存ボタン押した場合
-(void)reloadImage {
    if (_index != [CalendarManager sharedManager].currentIndex) {
        return;
    }
    CalendarData *data = [[CalendarManager sharedManager].dataList objectAtIndex:[CalendarManager sharedManager].currentIndex];
    
    UIImage *image1 = [UIImage imageWithContentsOfFile:data.imagePath1];
    UIImage *image2 = [UIImage imageWithContentsOfFile:data.imagePath2];
    UIImage *image3 = [UIImage imageWithContentsOfFile:data.imagePath3];
    
    if (image1 != nil) {
        imageView1.image = image1;
    } else {
        imageView1.image = [UIImage imageNamed:@"btn_plus.png"];
    }
    if (image2 != nil) {
        imageView2.image = image2;
    } else {
        imageView2.image = [UIImage imageNamed:@"btn_plus.png"];
    }
    if (image3 != nil) {
        imageView3.image = image3;
    } else {
        imageView3.image = [UIImage imageNamed:@"btn_plus.png"];
    }
    
    if (data.bestShot == 1) {
        if (image1 != nil) {
            imageView.image = image1;
            lineView1.hidden = NO;
            lineView2.hidden = YES;
            lineView3.hidden = YES;
        } else {
            imageView.image = [UIImage imageNamed:@"box_noimage"];
            lineView1.hidden = YES;
            lineView2.hidden = YES;
            lineView3.hidden = YES;
        }
    }
    if (data.bestShot == 2) {
        if (image2 != nil) {
            imageView.image = image2;
            lineView1.hidden = YES;
            lineView2.hidden = NO;
            lineView3.hidden = YES;
        } else {
            imageView.image = image1;
            lineView1.hidden = NO;
            lineView2.hidden = YES;
            lineView3.hidden = YES;
        }
    }
    if (data.bestShot == 3) {
        if (image3 != nil) {
            imageView.image = image3;
            lineView1.hidden = YES;
            lineView2.hidden = YES;
            lineView3.hidden = NO;
        } else {
            imageView.image = image1;
            lineView1.hidden = NO;
            lineView2.hidden = YES;
            lineView3.hidden = YES;
        }
    }
    
    [[CalendarManager sharedManager].dataList replaceObjectAtIndex:_index withObject:data];
}

- (void)search:(NSString *)keyword {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    NSString *urlBaseString = @"http://ajax.googleapis.com/ajax/services/search/images?v=1.0&hl=ja&q=%@";
    NSString *urlString = [NSString stringWithFormat:urlBaseString, keyword];
    NSURL *url = [NSURL URLWithString:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:nil  ];
    
    NSURLSessionDataTask *jsonData = [session dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (!error) {
            NSHTTPURLResponse *httpResp = (NSHTTPURLResponse *) response;
            if (httpResp.statusCode == 200) {
                NSLog(@"success!");
                NSError *jsonError;
                
                NSDictionary *rawJSON = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&jsonError];
                
//                NSMutableArray *imageURLsFound = [[NSMutableArray alloc]init];
                
                if (!jsonError) {
                    NSDictionary *responseData = rawJSON[@"responseData"];
                    if ([responseData isKindOfClass:[NSDictionary class]]) {
                        NSArray *results = responseData[@"results"];
                        for (NSDictionary *result in results) {
                            NSString *imageStr = result[@"url"];
                            NSURL *url = [[NSURL alloc] initWithString:imageStr];
                            NSData *dt = [NSData dataWithContentsOfURL:url];
                            UIImage *image = [[UIImage alloc] initWithData:dt];
                            if (image != nil) {
                                imageView.image = image;
                                imageView1.image = image;
                            } else {
                                imageView.image = [UIImage imageNamed:@"box_noimage"];
                                imageView1.image = image;
                            }
                            
                            break;
                        }
                        
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
                        });
                    }
                }
            }
        }
    }];
    [jsonData resume];
}

- (void)textViewDidChange:(UITextView *)textView {
    if ([textView.text isEqualToString:_text]) {
        return;
    } else {
        _text = textView.text;
    }
    
    NSDictionary *attributes = @{ NSForegroundColorAttributeName : [UIColor colorWithRed:0.314 green:0.314 blue:0.314 alpha:1], NSFontAttributeName : [UIFont systemFontOfSize:12.0f] };
    NSAttributedString *string = [[NSAttributedString alloc] initWithString:textView.text attributes:attributes];
//    memoTextView.attributedText = string;
    CGRect frame = [string boundingRectWithSize:CGSizeMake(233, 100000) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading context:nil];
    _height = frame.size.height+3;
    if (_height < 15) {
        _height = 15;
    }
    memoTextView.frame = CGRectMake(37, 105, 233, _height);
    view.frame = CGRectMake(10, 120+_height, 260, 275);
    
    scrollView.contentSize = CGSizeMake(280, 390+_height);
}

@end

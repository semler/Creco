//
//  PhotoViewController.m
//  Creco
//
//  Created by 于　超 on 2015/06/04.
//  Copyright (c) 2015年 Windward. All rights reserved.
//

#import "PhotoViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "QBImagePicker.h"
#import "CalendarManager.h"
#import "CalendarData.h"

#define screenWidth            [UIScreen mainScreen].bounds.size.width
#define screenHeight           [UIScreen mainScreen].bounds.size.height

@interface PhotoViewController ()<QBImagePickerControllerDelegate, UIGestureRecognizerDelegate> {
    QBImagePickerController *picker;
    CalendarData *calendarData;
//    CGRect oldFrame;    //保存图片原来的大小
//    CGRect largeFrame;  //确定图片放大最大的程度
}

@property (weak, nonatomic) IBOutlet UIImageView *phote;
@property (weak, nonatomic) IBOutlet UIButton *bestShotButton;
@property (weak, nonatomic) IBOutlet UIButton *saveButton;
@property (nonatomic) int bestShot;

- (IBAction)deleteButtonPressed:(id)sender;
- (IBAction)closeButtonPressed:(id)sender;
- (IBAction)bestShotButtonPressed:(id)sender;
- (IBAction)changeButtonPressed:(id)sender;
- (IBAction)saveButtonPressed:(id)sender;

@end

@implementation PhotoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    CalendarData *data = [[CalendarManager sharedManager].dataList objectAtIndex:_index];
    if (data.bestShot == data.selectedButton) {
        [_bestShotButton setBackgroundImage:[UIImage imageNamed:@"btn_bestshot_on.png"] forState:UIControlStateNormal];
    } else {
        [_bestShotButton setBackgroundImage:[UIImage imageNamed:@"btn_bestshot_off.png"] forState:UIControlStateNormal];
    }
    
    [_saveButton setBackgroundImage:[UIImage imageNamed:@"btn_save2_off.png"] forState:UIControlStateNormal];
    
    // QBImagePickerController
    picker = [QBImagePickerController new];
    picker.delegate = self;
    picker.filterType = QBImagePickerControllerFilterTypePhotos;
    picker.allowsMultipleSelection = NO;
    picker.showsNumberOfSelectedAssets = YES;
    
    _phote.contentMode = UIViewContentModeScaleAspectFit;
    _phote.frame = CGRectMake(0, 120, screenWidth, screenHeight-240);
    _phote.image = [UIImage imageWithContentsOfFile:[data.pathArray objectAtIndex:data.selectedButton-1]];
//    oldFrame = _phote.frame;
    
    // 画像
    [self addGestureRecognizerToView:_phote];
    [_phote setUserInteractionEnabled:YES];
    [_phote setMultipleTouchEnabled:YES];
    
    _bestShot = 0;
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    _saveButton.enabled = NO;
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    CalendarData *data = [[CalendarManager sharedManager].dataList objectAtIndex:_index];
    if (data.addFlg) {
        AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
        [appDelegate.window addSubview:picker.view];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)deleteButtonPressed:(id)sender {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"画像を削除してよろしいですか？"
                                                        message:nil
                                                       delegate:self
                                              cancelButtonTitle:@"いいえ"
                                              otherButtonTitles:@"はい", nil];
    [alertView show];
}

- (IBAction)closeButtonPressed:(id)sender {
    [self.view removeFromSuperview];
}

- (IBAction)saveButtonPressed:(id)sender {
    
    CalendarData *data = [[CalendarManager sharedManager].dataList objectAtIndex:_index];
    // 写真の保存
    // JPEGのデータとしてNSDataを作成します
    // ここのUIImageJPEGRepresentationがミソです
    NSData *dataImage = UIImageJPEGRepresentation(_phote.image, 0.8f);
    // 保存するディレクトリを指定します
    // ここではデータを保存する為に一般的に使われるDocumentsディレクトリ
    NSString *path = [data.pathArray objectAtIndex:data.selectedButton-1];
    // NSDataのwriteToFileメソッドを使ってファイルに書き込みます
    // atomically=YESの場合、同名のファイルがあったら、まずは別名で作成して、その後、ファイルの上書きを行います
    if ([dataImage writeToFile:path atomically:YES]) {
        NSLog(@"save OK");
    } else {
        NSLog(@"save NG");
    }
    
    if (_bestShot != 0) {
        data.bestShot = _bestShot;
    }
    if (data.bestShot != 0) {
        [Details updateDetailCostsByDate:_detailCostObject.date code:_detailCostObject.code memo:_detailCostObject.note bestShot:data.bestShot];
    }
    NSNotification *notification2 =[NSNotification notificationWithName:@"reloadCalendar" object:nil userInfo:nil];
    [[NSNotificationCenter defaultCenter] postNotification:notification2];
    [[CalendarManager sharedManager].dataList replaceObjectAtIndex:_index withObject:data];
    
    [CalendarManager sharedManager].currentIndex = _index;
    NSNotification *notification =[NSNotification notificationWithName:@"reloadImage" object:nil userInfo:nil];
    [[NSNotificationCenter defaultCenter] postNotification:notification];
    [self.view removeFromSuperview];
}

- (IBAction)changeButtonPressed:(id)sender {
//    _saveButton.enabled = YES;
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    [appDelegate.window addSubview:picker.view];
}

- (IBAction)bestShotButtonPressed:(id)sender {
    CalendarData *data = [[CalendarManager sharedManager].dataList objectAtIndex:_index];
    if (data.bestShot != data.selectedButton) {
        [_bestShotButton setBackgroundImage:[UIImage imageNamed:@"btn_bestshot_on.png"] forState:UIControlStateNormal];
        _bestShot = data.selectedButton;
        _saveButton.enabled = YES;
    } else {
        //
    }
    [[CalendarManager sharedManager].dataList replaceObjectAtIndex:_index withObject:data];
}

#pragma mark - QBImagePickerControllerDelegate

- (void)qb_imagePickerController:(QBImagePickerController *)imagePickerController didSelectImage:(UIImage *)image
{
    _phote.image = image;
    _saveButton.enabled = YES;
    [picker.view removeFromSuperview];
}

- (void)qb_imagePickerControllerDidCancel:(QBImagePickerController *)imagePickerController
{
    [picker.view removeFromSuperview];
    CalendarData *data = [[CalendarManager sharedManager].dataList objectAtIndex:_index];
    if (data.addFlg) {
        [self.view removeFromSuperview];
    }
}

-(void)alertView:(UIAlertView*)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    CalendarData *data = [[CalendarManager sharedManager].dataList objectAtIndex:_index];
    switch (buttonIndex) {
        case 0:
            // cancelボタンが押された時の処理
            break;
        case 1:
            // 削除したいファイルのパスを作成
            {
                NSString *filePath = [data.pathArray objectAtIndex:data.selectedButton-1];
                NSError *error;
                // ファイルを削除
                NSFileManager *fileManager = [NSFileManager defaultManager];
                BOOL result = [fileManager removeItemAtPath:filePath error:&error];
                if (result) {
                    NSLog(@"delete：OK");
                } else {
                    NSLog(@"delete：NG");
                }
                
                // 写真詰める
                [self resetImage];
                
                [CalendarManager sharedManager].currentIndex = _index;
                NSNotification *notification =[NSNotification notificationWithName:@"reloadImage" object:nil userInfo:nil];
                [[NSNotificationCenter defaultCenter] postNotification:notification];
                [self.view removeFromSuperview];
            }
            break;
    }
}

-(void) resetImage {
    CalendarData *data = [[CalendarManager sharedManager].dataList objectAtIndex:_index];
    
    UIImage *image1 = [UIImage imageWithContentsOfFile:data.imagePath1];
    UIImage *image2 = [UIImage imageWithContentsOfFile:data.imagePath2];
    UIImage *image3 = [UIImage imageWithContentsOfFile:data.imagePath3];
    
    NSError *error;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    data.bestShot = 1;
    if (image1 == nil) {
        if (image2 != nil) {
            //2-1
            [fileManager moveItemAtPath:data.imagePath2 toPath:data.imagePath1 error:&error];
            if (image3 != nil) {
                //3-2
                [fileManager moveItemAtPath:data.imagePath3 toPath:data.imagePath2 error:&error];
                if (data.bestShot == 3) {
                    data.bestShot = 2;
                }
            }
        } else {
            if (image3 != nil) {
                //3-1
                [fileManager moveItemAtPath:data.imagePath3 toPath:data.imagePath1 error:&error];
            }
        }
    } else {
        if (image2 == nil) {
            if (image3 != nil) {
                //3-2
                [fileManager moveItemAtPath:data.imagePath3 toPath:data.imagePath2 error:&error];
                if (data.bestShot == 3) {
                    data.bestShot = 2;
                }
            }
        }
    }
    
    image1 = [UIImage imageWithContentsOfFile:data.imagePath1];
    image2 = [UIImage imageWithContentsOfFile:data.imagePath2];
    image3 = [UIImage imageWithContentsOfFile:data.imagePath3];
    
    [[CalendarManager sharedManager].dataList replaceObjectAtIndex:_index withObject:data];
}

// 添加所有的手势
- (void) addGestureRecognizerToView:(UIView *)view
{
    // 缩放手势
    UIPinchGestureRecognizer *pinchGestureRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchView:)];
    [view addGestureRecognizer:pinchGestureRecognizer];
    
    // 移动手势
    UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panView:)];
    [view addGestureRecognizer:panGestureRecognizer];
}

// 处理缩放手势
- (void) pinchView:(UIPinchGestureRecognizer *)pinchGestureRecognizer
{
    UIView *view = pinchGestureRecognizer.view;
    if (pinchGestureRecognizer.state == UIGestureRecognizerStateBegan || pinchGestureRecognizer.state == UIGestureRecognizerStateChanged) {
        view.transform = CGAffineTransformScale(view.transform, pinchGestureRecognizer.scale, pinchGestureRecognizer.scale);
//        if (_phote.frame.size.width < oldFrame.size.width/3) {
//            _phote.frame = oldFrame;
//            //让图片无法缩得比原图小
//        }
//        if (_phote.frame.size.width > 3*oldFrame.size.width) {
//            _phote.frame = largeFrame;
//        }
        pinchGestureRecognizer.scale = 1;
    }
}

// 处理拖拉手势
- (void) panView:(UIPanGestureRecognizer *)panGestureRecognizer
{
    UIView *view = panGestureRecognizer.view;
    if (panGestureRecognizer.state == UIGestureRecognizerStateBegan || panGestureRecognizer.state == UIGestureRecognizerStateChanged) {
        CGPoint translation = [panGestureRecognizer translationInView:view.superview];
        [view setCenter:(CGPoint){view.center.x + translation.x, view.center.y + translation.y}];
        [panGestureRecognizer setTranslation:CGPointZero inView:view.superview];
    }
}

@end

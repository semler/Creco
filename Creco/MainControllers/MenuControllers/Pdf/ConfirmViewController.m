//
//  ConfirmViewController.m
//  Creco
//
//  Created by 于　超 on 2015/06/22.
//  Copyright (c) 2015年 Windward. All rights reserved.
//

#import "ConfirmViewController.h"
#import "SLCoverFlowView.h"
#import "PdfViewController.h"
#import "CardManager.h"

#define screenWidth            [UIScreen mainScreen].bounds.size.width
#define screenHeight           [UIScreen mainScreen].bounds.size.height

@interface ConfirmViewController () <SLCoverFlowViewDelegate, SLCoverFlowViewDataSource> {
    SLCoverFlowView *cardFlowView;
    NSMutableArray *cardsArray;
    NSMutableArray *pdfList;
    NSInteger nowCardIndex;
    UIWebView *webView;
}

@end

@implementation ConfirmViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    
    pdfList = [Pdf getPdfsByDate:_month];
    
    NSString *result = [_month stringByReplacingOccurrencesOfString:@"-0" withString:@"-"];
    NSString *result2 = [result stringByReplacingOccurrencesOfString:@"-" withString:@"年"];
    NSString *dateStr = [NSString stringWithFormat:@"%@%@", result2, @"月"];
    self.navigationItem.title = dateStr;
    self.view.backgroundColor = COLOR_VIEW_OTHER_BACKGROUND;
    
    cardsArray = [Entry getAllUserCards];
    if (cardsArray.count == 1) cardsArray = [SampleCard getAllSampleCards];
    for(DetailCostObject *obj in cardsArray) {
        if ([obj.card_code isEqualToString:kAllCardCode]) {
            [cardsArray removeObject:obj];
            break;
        }
    }
    
    UIImage *cardImage = [UIImage imageNamed:@"default_card"];
    CGFloat scaleSize = 104.f/cardImage.size.height;
    cardFlowView = [[SLCoverFlowView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 320)];
    cardFlowView.backgroundColor = [UIColor clearColor];
    cardFlowView.delegate = self;
    cardFlowView.dataSource = self;
    cardFlowView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    cardFlowView.coverSize = CGSizeMake(cardImage.size.width*scaleSize, cardImage.size.height*scaleSize);
    cardFlowView.coverSpace = 64.0;
    cardFlowView.coverAngle = 0.0;
    cardFlowView.coverScale = 1/scaleSize;
    [cardFlowView reloadData];
    
    webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 320*scaleSize, screenWidth, screenHeight-320*scaleSize-109)];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0, 320*scaleSize, screenWidth, screenHeight-320*scaleSize-109);
    [button addTarget:self action:@selector(pdf) forControlEvents:UIControlEventTouchUpInside];
    [button setBackgroundColor:[UIColor clearColor]];
    
    // pdf保存
    for (PdfObject *obj in pdfList) {
        NSData *data = [[NSData alloc] initWithBase64EncodedString:obj.pdf options:NSDataBase64DecodingIgnoreUnknownCharacters];
        NSString *path = [NSString stringWithFormat:@"%@/%@%@%@", [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"], obj.date, obj.card_code, @".pdf"];
        [data writeToFile:path atomically:YES];
    }
   
    [self.view addSubview:cardFlowView];
    [self.view addSubview:webView];
    [self.view addSubview:button];
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"home_bg"]];
    
    [self reloadScrollDataByIndex:0];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - SLCoverFlowViewDataSource -

- (NSInteger)numberOfCovers:(SLCoverFlowView *)coverFlowView {
    return cardsArray.count;
}

- (SLCoverView *)coverFlowView:(SLCoverFlowView *)coverFlowView coverViewAtIndex:(NSInteger)index {
    UserCardObject *userCardObject = userCardObject = cardsArray[index];
    
    SLCoverView *coverView = [[SLCoverView alloc] initWithFrame:CGRectMake(0.0, 0.0, 0.0, 0.0) andUserCardObject:userCardObject];
    [CardManager sharedManager].color = userCardObject.color;
    coverView.imageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"card%d_small", [CardManager sharedManager].index+1]];
    
    return coverView;
}

#pragma mark - SLCoverFlowViewDelegate -

- (void)coverFlowViewMovedEndAtIndex:(NSInteger)index
{
   
}

- (void)coverFlowViewNowMovingIndex:(NSInteger)movingIndex
{
    if (nowCardIndex == movingIndex)
        return;
    
    nowCardIndex = movingIndex;
    [self reloadScrollDataByIndex:movingIndex];
}

- (void)reloadScrollDataByIndex:(NSInteger)index
{
    // pdf表示
    UserCardObject *obj = [cardsArray objectAtIndex:index];
    NSString *path = [NSString stringWithFormat:@"%@/%@%@%@", [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"], _month, obj.card_code, @".pdf"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:path]) {
        NSURL *url = [NSURL fileURLWithPath:path];
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        [webView loadRequest:request];
    } else {
        [webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"about:blank"]]];
    }
}

-(void)pdf {
    PdfViewController *controller = [[PdfViewController alloc] init];
    UserCardObject *obj = [cardsArray objectAtIndex:nowCardIndex];
    NSString *path = [NSString stringWithFormat:@"%@/%@%@%@", [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"], _month, obj.card_code, @".pdf"];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    // ファイルが存在するか?
    if ([fileManager fileExistsAtPath:path]) {
        controller.path = path;
        [self presentViewController:controller animated:NO completion:nil];
    }
}




@end

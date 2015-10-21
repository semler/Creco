//
//  PdfViewController.m
//  Creco
//
//  Created by 于　超 on 2015/06/22.
//  Copyright (c) 2015年 Windward. All rights reserved.
//

#import "PdfViewController.h"
#import "BigButton.h"

#define screenWidth            [UIScreen mainScreen].bounds.size.width
#define screenHeight           [UIScreen mainScreen].bounds.size.height

@interface PdfViewController () {
    UIWebView *webView;
}

@end

@implementation PdfViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIButton *button = [BigButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(screenWidth-10-30, 10, 30, 30);
    [button setTitle:@"×" forState:UIControlStateNormal];
    [button.titleLabel setFont:[UIFont systemFontOfSize:30]];
    button.contentMode = UIViewContentModeCenter;
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(close) forControlEvents:UIControlEventTouchUpInside];
    
    webView = [[UIWebView alloc] initWithFrame:CGRectMake(10, 40, screenWidth-20, screenHeight-40)];
    webView.backgroundColor = [UIColor blackColor];
    NSURL *url = [NSURL fileURLWithPath:_path];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [webView loadRequest:request];
    webView.scalesPageToFit = YES;
    
    self.view.backgroundColor = [UIColor blackColor];
    [self.view addSubview:button];
    [self.view addSubview:webView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) close {
    [self dismissViewControllerAnimated:NO completion:nil];
}

@end

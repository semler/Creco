//
//  WebViewController.m
//  Creco
//
//  Created by Windward on 15/6/16.
//  Copyright (c) 2015年 Windward. All rights reserved.
//

#import "WebViewController.h"
#import "UIAlertView+BlocksKit.h"

@interface WebViewController () <UIWebViewDelegate>
{
    UIButton *webBackBtn;
    UIButton *webFrontBtn;
    
    UITextView *contentTextView;
}
@end

@implementation WebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    
    UIWebView *webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, kAllViewWidth, kAllViewHeight)];
    webView.delegate = self;
    webView.scrollView.showsVerticalScrollIndicator = NO;
    webView.backgroundColor = [UIColor clearColor];
    webView.opaque = NO;
    webView.tag = kDefaultViewTag;
    [self.view addSubview:webView];
    
    // remove shadow view when drag web view
    for (UIView *subView in [webView subviews]) {
        if ([subView isKindOfClass:[UIScrollView class]]) {
            for (UIView *shadowView in [subView subviews]) {
                if ([shadowView isKindOfClass:[UIImageView class]]) {
                    shadowView.hidden = YES;
                }
            }
        }
    }
    
    UIView *tabbarView = [[UIView alloc] initWithFrame:CGRectMake(0, kAllViewHeight, kAllViewWidth, kTabbarHeight)];
    tabbarView.backgroundColor = [ShareMethods colorFromHexRGB:[[NSUserDefaults standardUserDefaults] valueForKey:kAppTopicColor]];
    [self.view addSubview:tabbarView];
    
    UIImage *refreshImg = [UIImage imageNamed:@"web_refresh"];
    UIButton *refreshBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    refreshBtn.frame = CGRectMake((tabbarView.width-refreshImg.size.width)/2, (tabbarView.height-refreshImg.size.height)/2, refreshImg.size.width, refreshImg.size.height);
    [refreshBtn setImage:refreshImg forState:UIControlStateNormal];
    if (self.isUseStatute)
        [refreshBtn addTarget:self action:@selector(refreshUseStatuteData) forControlEvents:UIControlEventTouchUpInside];
    else
        [refreshBtn addTarget:self action:@selector(reload) forControlEvents:UIControlEventTouchUpInside];
    [tabbarView addSubview:refreshBtn];
    
    CGFloat middlePadding = 66.f;
    
    UIImage *webBackImg = [UIImage imageNamed:@"web_back"];
    webBackBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    webBackBtn.frame = CGRectMake(refreshBtn.left-middlePadding-webBackImg.size.width, (tabbarView.height-webBackImg.size.height)/2, webBackImg.size.width, webBackImg.size.height);
    [webBackBtn setImage:webBackImg forState:UIControlStateNormal];
    [webBackBtn addTarget:webView action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
    [tabbarView addSubview:webBackBtn];
    
    UIImage *webFrontImg = [UIImage imageNamed:@"web_front"];
    webFrontBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    webFrontBtn.frame = CGRectMake(refreshBtn.right+middlePadding, (tabbarView.height-webFrontImg.size.height)/2, webFrontImg.size.width, webFrontImg.size.height);
    [webFrontBtn setImage:webFrontImg forState:UIControlStateNormal];
    [webFrontBtn addTarget:webView action:@selector(goForward) forControlEvents:UIControlEventTouchUpInside];
    [tabbarView addSubview:webFrontBtn];
    
    if (self.isUseStatute)
    {
        webBackBtn.hidden = YES;
        webFrontBtn.hidden = YES;
        webView.hidden = YES;
        
        contentTextView = [[UITextView alloc] initWithFrame:webView.frame];
        contentTextView.editable = NO;
        contentTextView.font = [UIFont systemFontOfSize:15];
        [self.view addSubview:contentTextView];
        
        [self refreshUseStatuteData];
    }else
    {
        webBackBtn.enabled = NO;
        webFrontBtn.enabled = NO;
        [webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.requestUrl]
                                              cachePolicy:NSURLRequestUseProtocolCachePolicy
                                          timeoutInterval:60.f]];
    }
}

- (void)clickLeftButton
{
    [super clickLeftButton];
    [[AppConfig shareConfig] hiddenLoadingView];
}

- (void)refreshUseStatuteData
{
    [[AppConfig shareConfig] showLoadingView];
    [RequestManager requestPath:kGetAgreement parameters:nil success:^(AFHTTPRequestOperation *operation, id result) {
        [[AppConfig shareConfig] hiddenLoadingView];
        
        if (result)
            contentTextView.text = result[@"agreement"];
        else
            contentTextView.text = [NSString stringWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"UseStatute" ofType:@"txt"]
                                                             encoding:NSUTF8StringEncoding
                                                                error:nil];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [[AppConfig shareConfig] hiddenLoadingView];
        
        contentTextView.text = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"UseStatute" ofType:@"txt"]
                                                         encoding:NSUTF8StringEncoding
                                                            error:nil];
    }];
}

- (void)reload
{
    UIWebView *webView = (UIWebView *)[self.view viewWithTag:kDefaultViewTag];
    [webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.requestUrl]
                                          cachePolicy:NSURLRequestUseProtocolCachePolicy
                                      timeoutInterval:60.f]];
}

#pragma mark - UIWebview delegate -

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [[AppConfig shareConfig] showLoadingView];
}

- (void)webViewDidFinishLoad:(UIWebView *)web
{
    [[AppConfig shareConfig] hiddenLoadingView];
    
    webBackBtn.enabled = web.canGoBack;
    webFrontBtn.enabled = web.canGoForward;
}

- (void)webView:(UIWebView*)webView didFailLoadWithError:(NSError *)error
{
    [[AppConfig shareConfig] hiddenLoadingView];
    [webView loadHTMLString:@"通信状態の良い環境で御覧ください" baseURL:nil];
    
    [UIAlertView bk_showAlertViewWithTitle:@"接続失敗しました。\n通信環境の良い状態で再度接続してください。"
                                   message:nil
                         cancelButtonTitle:nil
                         otherButtonTitles:@[@"OK"]
                                   handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
                                       [AppConfig shareConfig].isShowAPIAlert = NO;
                                   }];
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

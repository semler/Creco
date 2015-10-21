//
//  PopView.m
//  Creco
//
//  Created by TangYanQiong on 15/7/10.
//  Copyright (c) 2015年 Windward. All rights reserved.
//

#import "PopView.h"

@interface PopView () <UITextViewDelegate, UIWebViewDelegate>
{
    UIView *bgView;
    UIImageView *boxImageView;
    
    UIButton *checkBoxBtn;
    UIButton *yesButton;
}
@end
@implementation PopView

static CGFloat kTransitionDuration = 0.3;

- (CGAffineTransform)transformForOrientation {
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    if (orientation == UIInterfaceOrientationLandscapeLeft) {
        return CGAffineTransformMakeRotation(M_PI*1.5);
    } else if (orientation == UIInterfaceOrientationLandscapeRight) {
        return CGAffineTransformMakeRotation(M_PI/2);
    } else if (orientation == UIInterfaceOrientationPortraitUpsideDown) {
        return CGAffineTransformMakeRotation(-M_PI);
    } else {
        return CGAffineTransformIdentity;
    }
}

- (id)initWithPopViewType:(PopViewType)popViewType
               withString:(NSString *)string
         andIntoSuperView:(UIView *)superView
{
    if (self = [super init])
    {
        self.frame = CGRectMake(0, 0, superView.width, superView.height);
        [superView addSubview:self];
        
        bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.width, self.height)];
        bgView.backgroundColor = [[UIColor grayColor] colorWithAlphaComponent:0.5f];
        [self addSubview:bgView];
        
        UIImage *popBoxImg = [UIImage imageNamed:@"pop_box"];
        boxImageView = [[UIImageView alloc] initWithFrame:CGRectMake((self.width-popBoxImg.size.width)/2, (self.height-popBoxImg.size.height)/2, popBoxImg.size.width, popBoxImg.size.height)];
        boxImageView.layer.cornerRadius = 6.f;
        boxImageView.clipsToBounds = YES;
        boxImageView.backgroundColor = [UIColor whiteColor];
        boxImageView.userInteractionEnabled = YES;
        [self addSubview:boxImageView];
        
        if (popViewType == PopViewTypeInitApp) {
            self.frame = CGRectMake(0, 0, kAppDelegate.window.width, kAppDelegate.window.height);
            [kAppDelegate.window addSubview:self];
            
            boxImageView.frame = CGRectMake((self.width-popBoxImg.size.width+10.f)/2, (self.height-120.f)/2, popBoxImg.size.width-10.f, 120.f);
            
            UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, boxImageView.width, 50.f)];
            titleLabel.text = @"データは元に戻せません。\nそれでもよろしいでしょうか？";
            titleLabel.textAlignment = NSTextAlignmentCenter;
            titleLabel.font = [UIFont boldSystemFontOfSize:16];
            titleLabel.numberOfLines = 2;
            [boxImageView addSubview:titleLabel];
            
            UIImage *checkImg = [UIImage imageNamed:@"check_box"];
            checkBoxBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            checkBoxBtn.frame = CGRectMake(0, titleLabel.bottom+5.f, checkImg.size.width+180.f, checkImg.size.height);
            [checkBoxBtn setImage:checkImg forState:UIControlStateNormal];
            [checkBoxBtn setImage:[UIImage imageNamed:@"check_box_selected"] forState:UIControlStateSelected];
            checkBoxBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
            [checkBoxBtn setTitle:@" 問題ありません" forState:UIControlStateNormal];
            [checkBoxBtn setTitleColor:[ShareMethods colorFromHexRGB:DEFAULT_APP_STSYLE_COLOR] forState:UIControlStateNormal];
            [checkBoxBtn addTarget:self action:@selector(agreeOrNot) forControlEvents:UIControlEventTouchUpInside];
            checkBoxBtn.titleLabel.font = [UIFont systemFontOfSize:16];
            [boxImageView addSubview:checkBoxBtn];
            
            DrawLine(boxImageView, 0, checkBoxBtn.bottom+10.f, boxImageView.width, 0.5f, COLOR_LINE);
            DrawLine(boxImageView, boxImageView.width/2, checkBoxBtn.bottom+10.f, 0.5f, 40.f, COLOR_LINE);
            
            for (int i = 0; i < 2; i ++)
            {
                UIButton *alertButton = [UIButton buttonWithType:UIButtonTypeCustom];
                alertButton.frame = CGRectMake(i*(boxImageView.width/2), checkBoxBtn.bottom+10.5f, boxImageView.width/2, 40.f);
                [alertButton setTitleColor:kRGBColor(0.f, 91.f, 225.f, 1.f) forState:UIControlStateNormal];
                [alertButton setTitleColor:[UIColor grayColor] forState:UIControlStateDisabled];
                [alertButton setBackgroundImage:[ShareMethods createImageWithColor:kRGBColor(208.f, 208.f, 208.f, 0.6f) size:CGSizeMake(boxImageView.width/2, 40.f)] forState:UIControlStateHighlighted];
                [alertButton addTarget:self action:@selector(initAppActionBtn:) forControlEvents:UIControlEventTouchUpInside];
                alertButton.tag = i;
                [boxImageView addSubview:alertButton];
                
                switch (i) {
                    case 0:
                        [alertButton setTitle:@"いいえ" forState:UIControlStateNormal];
                        break;
                    case 1:
                        [alertButton setTitle:@"はい" forState:UIControlStateNormal];
                        yesButton = alertButton;
                        yesButton.enabled = NO;
                        break;
                    default:
                        break;
                }
            }
        }else
        {
            UIView *topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, boxImageView.width, 30.f)];
            topView.backgroundColor = [ShareMethods colorFromHexRGB:[[NSUserDefaults standardUserDefaults] valueForKey:kAppTopicColor]];
            [boxImageView addSubview:topView];
            
            UIImage *closeImg = [UIImage imageNamed:@"close"];
            UIButton *closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            closeBtn.frame = CGRectMake(5, 0, closeImg.size.width*1.2f, closeImg.size.height*1.5f);
            [closeBtn setImage:closeImg forState:UIControlStateNormal];
            [closeBtn addTarget:self action:@selector(closeView) forControlEvents:UIControlEventTouchUpInside];
            [boxImageView addSubview:closeBtn];
            
            if (popViewType == PopViewTypeUseStatute) {
                UITextView *contentTextView = [[UITextView alloc] initWithFrame:CGRectMake(10.f, 30.f, boxImageView.width-20.f, boxImageView.height-32.f)];
                contentTextView.delegate = self;
                contentTextView.backgroundColor = [UIColor clearColor];
                contentTextView.text = string;
                [boxImageView addSubview:contentTextView];
            }else if (popViewType == PopViewTypeAddCertification)
            {
                UIWebView *webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 30.f, boxImageView.width, boxImageView.height-32.f)];
                webView.delegate = self;
                webView.scrollView.showsVerticalScrollIndicator = NO;
                webView.backgroundColor = [UIColor clearColor];
                webView.opaque = NO;
                [boxImageView addSubview:webView];
                
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
                
                [webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:string]
                                                      cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                  timeoutInterval:60.f]];
            }
        }
    }
    return self;
}

- (void)agreeOrNot
{
    checkBoxBtn.selected = !checkBoxBtn.selected;
    yesButton.enabled = checkBoxBtn.selected;
}

- (void)initAppActionBtn:(UIButton *)actionBtn
{
    if (actionBtn == yesButton) {
        if (self.initAppBlock)
            self.initAppBlock(YES);
    }
    
    [self closeView];
}

- (void)showPopView
{
    self.alpha = 1;
    
    boxImageView.transform = CGAffineTransformScale([self transformForOrientation], 0.001, 0.001);
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:kTransitionDuration/1.5];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(bounce1AnimationStopped)];
    boxImageView.transform = CGAffineTransformScale([self transformForOrientation], 1.1, 1.1);
    [UIView commitAnimations];
}

- (void)bounce1AnimationStopped {
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:kTransitionDuration/2];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(bounce2AnimationStopped)];
    boxImageView.transform = CGAffineTransformScale([self transformForOrientation], 0.9, 0.9);
    [UIView commitAnimations];
}

- (void)bounce2AnimationStopped {
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:kTransitionDuration/2];
    boxImageView.transform = [self transformForOrientation];
    [UIView commitAnimations];
}

- (void)closeView
{
    [self endEditing:YES];
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:kTransitionDuration];
    [UIView setAnimationDelegate:self];
    self.alpha = 0;
    [UIView commitAnimations];
    
    [[AppConfig shareConfig] hiddenLoadingView];
}

#pragma mark - UITextView Delegate -

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    [textView resignFirstResponder];
    return YES;
}

#pragma mark - UIWebview delegate -

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSString *urlstr = request.URL.absoluteString;
    NSRange range = [urlstr rangeOfString:@"creco://"];
    if (range.length != 0) {
        NSString *actionStr = [urlstr substringFromIndex:(range.location+range.length)];
        if ([actionStr rangeOfString:@"closeWebView"].location != NSNotFound) {
            if ([actionStr rangeOfString:@"closeWebView?ret=1&msg="].location != NSNotFound)
            {
                if (self.certificationBlock)
                {
                    NSString *web_id_code = [actionStr stringByReplacingOccurrencesOfString:@"closeWebView?ret=1&msg=&web_id_code=" withString:@""];
                    self.certificationBlock(@{@"web_id_code":web_id_code});
                }
            }else if ([actionStr rangeOfString:@"closeWebView?ret=9&msg="].location != NSNotFound)
            {
                NSString *cutActionStr = [actionStr stringByReplacingOccurrencesOfString:@"closeWebView?ret=9&msg=" withString:@""];
                if (cutActionStr.length > 0)
                    [ShareMethods showAlertBy:cutActionStr];
            }
            
            [self closeView];
        }
    }
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [[AppConfig shareConfig] showLoadingView];
}

- (void)webViewDidFinishLoad:(UIWebView *)web
{
    [[AppConfig shareConfig] hiddenLoadingView];
}

- (void)webView:(UIWebView*)webView didFailLoadWithError:(NSError *)error
{
    [[AppConfig shareConfig] hiddenLoadingView];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end

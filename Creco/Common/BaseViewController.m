//
//  BaseViewController.m
//  Creco
//
//  Created by Windward on 14/9/15.
//  Copyright (c) 2014年 Windward. All rights reserved.
//

#import "BaseViewController.h"

@interface BaseViewController ()
{
    UIView *statusView;
}
@end

@implementation BaseViewController
@synthesize isInMyView;

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.extendedLayoutIncludesOpaqueBars = NO;
    self.modalPresentationCapturesStatusBarAppearance = NO;
    
    self.view.backgroundColor = COLOR_VIEW_BACKGROUND;
    [self setCustomLeftButtonBy:[UIImage imageTopicNamed:@"back"]];//Set Default Left Button
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(topicChanged)
                                                 name:kTopicIsChanged object:nil];
}

- (void)topicChanged
{
    if (statusView)
        statusView.backgroundColor = [ShareMethods colorFromHexRGB:[[NSUserDefaults standardUserDefaults] valueForKey:kAppTopicColor]];
    if (self.navigationItem.leftBarButtonItem)
        [self setCustomLeftButtonBy:[UIImage imageTopicNamed:@"back"]];
}

- (void)onlyNeedStatusView
{
    statusView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kAllViewWidth, 20.f)];
    statusView.backgroundColor = [ShareMethods colorFromHexRGB:[[NSUserDefaults standardUserDefaults] valueForKey:kAppTopicColor]];
    [self.view addSubview:statusView];
}

- (void)setCustomLeftButtonBy:(UIImage *)leftImage
{
    if (!leftImage)
    {
        self.navigationItem.leftBarButtonItem = nil;
        return;
    }
    
    UIButton *leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
    leftButton.frame = CGRectMake(0, 0, leftImage.size.width*1.5f, leftImage.size.height*2.f);
    [leftButton setImage:leftImage forState:UIControlStateNormal];
    [leftButton addTarget:self action:@selector(clickLeftButton) forControlEvents:UIControlEventTouchUpInside];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
}

- (void)clickLeftButton
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)setCustomRightButtonBy:(UIImage *)rightImage
{
    if (!rightImage)
    {
        self.navigationItem.rightBarButtonItem = nil;
        return;
    }
    
    UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    rightButton.frame = CGRectMake(0, 0, rightImage.size.width, rightImage.size.height);
    [rightButton setImage:rightImage forState:UIControlStateNormal];
    [rightButton addTarget:self action:@selector(clickRightButton) forControlEvents:UIControlEventTouchUpInside];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightButton];
}

- (void)clickRightButton
{
    TDLog(@"Click right button, do nothing, please rewrite it!");
}

- (void)addSubview:(UIView *)view
{
    CGRect viewFrame = view.frame;
    viewFrame.origin.y += 20.f;
    view.frame = viewFrame;
    [self.view addSubview:view];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    self.isInMyView = YES;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:YES];
    self.isInMyView = NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kTopicIsChanged object:nil];
}
/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
 {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
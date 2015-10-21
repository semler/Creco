//
//  CalendarViewController.m
//  Creco
//
//  Created by Windward on 15/5/17.
//  Copyright (c) 2015年 Windward. All rights reserved.
//

#import "CalendarViewController.h"
#import "CalendarView.h"
#import "SLCoverFlowView.h"
#import "AppDelegate.h"
#import "CoverViewController.h"
#import "CatLoadingView.h"
#import "ODRefreshControl.h"
#import "CalendarManager.h"
#import "CalendarData.h"
#import "UIAlertView+BlocksKit.h"

#define screenWidth            [UIScreen mainScreen].bounds.size.width
#define screenHeight           [UIScreen mainScreen].bounds.size.height

@interface CalendarViewController ()<CalendarDelegate, SLCoverFlowViewDelegate, SLCoverFlowViewDataSource, CoverViewDelegate> {
    ODRefreshControl *refreshControl;
    CatLoadingView *catLoadingView;
    CalendarView *calendarView;
    UIScrollView *scrollView;
    UIView *clearView;
    SLCoverFlowView *cardFlowView;
    NSMutableArray *coverViewArray;
    NSMutableArray *detailDayArray;
}

@end

@implementation CalendarViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self onlyNeedStatusView];
    [self setCustomLeftButtonBy:nil];
    
    scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 20, screenWidth, screenHeight-69)];
    [self.view addSubview:scrollView];
    
    refreshControl = [[ODRefreshControl alloc] initInScrollView:scrollView];
    [refreshControl addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
    [scrollView addSubview:refreshControl];
    
    calendarView = [[CalendarView alloc]initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight)];
    calendarView.delegate = self;
    calendarView.calendarDate = [NSDate date];
    
    [scrollView addSubview:calendarView];
    scrollView.contentSize = calendarView.frame.size;
    
    // カード使用履歴
    clearView = [[UIView alloc] initWithFrame:CGRectMake(0, 20, screenWidth, screenHeight-20)];
    clearView.backgroundColor = [UIColor blackColor];
    clearView.alpha = 0.5;
    
    detailDayArray = [NSMutableArray array];
    coverViewArray = [NSMutableArray array];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(scroll) name:@"scroll" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadCalendar) name:@"reloadCalendar" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removeCalendar) name:@"removeCalendar" object:nil];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
 
    calendarView.titleText.textColor = [ShareMethods colorFromHexRGB:[[NSUserDefaults standardUserDefaults] valueForKey:kAppTopicColor]];
    [calendarView.buttonPrev setImage:[UIImage imageTopicNamed:@"btn_back_cal"] forState:UIControlStateNormal];
    [calendarView.buttonNext setImage:[UIImage imageTopicNamed:@"btn_next_cal"] forState:UIControlStateNormal];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - CalendarDelegate protocol conformance
-(void)setHeightNeeded:(NSInteger)heightNeeded {
    calendarView.frame = CGRectMake(0, 0, calendarView.frame.size.width, heightNeeded);
    scrollView.contentSize = calendarView.frame.size;
}

-(void)dayChangedToDate:(NSDate *)selectedDate {
    NSMutableArray *cardsArray = [Entry getAllUserCards];
    for(UserCardObject *obj in cardsArray) {
        if ([obj.card_code isEqualToString:kAllCardCode]) {
            [cardsArray removeObject:obj];
            break;
        }
    }
    if (cardsArray.count > 0) {
        detailDayArray = [Details getAllDetailCostsOrderBy];
    } else {
        detailDayArray = [SampleCard getAllSampleCostsOrderBy];
    }
    for(DetailCostObject *obj in detailDayArray) {
        if ([obj.card_code isEqualToString:kAllCardCode]) {
            [detailDayArray removeObject:obj];
            break;
        }
    }
    
    cardFlowView = [[SLCoverFlowView alloc] initWithFrame:CGRectMake(0, -14, screenWidth, screenHeight)];
    cardFlowView.backgroundColor = [UIColor clearColor];
    cardFlowView.delegate = self;
    cardFlowView.dataSource = self;
    cardFlowView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
//    cardFlowView.coverSize = CGSizeMake(screenWidth*7/8, screenHeight*55/71);
    cardFlowView.coverSize = CGSizeMake(280, 440);
    cardFlowView.coverSpace = 10.0;
    cardFlowView.coverAngle = 0.0;
    cardFlowView.coverScale = 1;
    
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"isCalendar"];
    [cardFlowView reloadData];
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"isCalendar"];
    
    [coverViewArray removeAllObjects];
    for (int i = 0; i < detailDayArray.count; i ++) {
        CoverViewController *controller = [[CoverViewController alloc] init];
        controller.detailCostObject = [detailDayArray objectAtIndex:i];
        controller.index = i;
        [[CalendarManager sharedManager].dataList addObject:[[CalendarData alloc] init]];
        controller.delegate = self;
        [coverViewArray addObject:controller];
    }
    
    int index = 0;;
    for (int i = 0; i < detailDayArray.count; i ++) {
        index = i;
        DetailCostObject *obj = [detailDayArray objectAtIndex:i];
        
        NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSDate *date = [formatter dateFromString:obj.date];
        
        NSComparisonResult result = [date compare:selectedDate];
        if (result == NSOrderedSame) {
            break;
        } else if (result == NSOrderedDescending) {
            break;
        }
    }
    [cardFlowView move:index];
    [CalendarManager sharedManager].currentIndex = (int)index;
    
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    if (detailDayArray.count != 0 && [CalendarManager sharedManager].isCoverViewOn == NO) {
        [CalendarManager sharedManager].isCoverViewOn = YES;
        [appDelegate.window addSubview:clearView];
        [appDelegate.window addSubview:cardFlowView];
    }
}

#pragma mark - SLCoverFlowViewDataSource -
- (NSInteger)numberOfCovers:(SLCoverFlowView *)coverFlowView {
    return detailDayArray.count;
}

- (UIView *)coverFlowView:(SLCoverFlowView *)coverFlowView coverViewAtIndex:(NSInteger)index {
    CoverViewController *controller = [coverViewArray objectAtIndex:index];
    return controller.view;
}


#pragma mark - SLCoverFlowViewDelegate -
- (void)coverFlowViewMovedEndAtIndex:(NSInteger)index {
    [CalendarManager sharedManager].currentIndex = (int)index;
}

#pragma mark - SLCoverFlowViewDelegate -
- (void)removeCoverFlow {
    [CalendarManager sharedManager].isCoverViewOn = NO;
    [clearView removeFromSuperview];
    [cardFlowView removeFromSuperview];
}

- (void)refresh
{
    if (!catLoadingView) {
        catLoadingView = [CatLoadingView addIntoTheView:self.view ByWordStr:@"更新中..." andWithPoint:CGPointMake(0, 0)];
        catLoadingView.frame = CGRectMake(catLoadingView.left, 20, catLoadingView.width, catLoadingView.height);
        catLoadingView.backgroundColor = [UIColor colorWithRed:0.863 green:0.863 blue:0.863 alpha:0.9];
    }
    [catLoadingView stop];
    [catLoadingView start];
    
    NSMutableDictionary *inputsDic = [NSMutableDictionary dictionary];
    NSArray *userWebsArray = [WebId getAllUserWebs];
    for (int i = 0; i < userWebsArray.count; i ++)
    {
        UserWebObject *userWebObj = userWebsArray[i];
        [inputsDic setValue:userWebObj.service_code forKey:[NSString stringWithFormat:@"inputs[%d][service_code]", i]];
        [inputsDic setValue:userWebObj.password forKey:[NSString stringWithFormat:@"inputs[%d][password]", i]];
        [inputsDic setValue:userWebObj.initialization_vector forKey:[NSString stringWithFormat:@"inputs[%d][initialization_vector]", i]];
        [inputsDic setValue:userWebObj.web_id forKey:[NSString stringWithFormat:@"inputs[%d][web_id]", i]];
    }
    
    if (inputsDic.count > 0)
    {
        [RequestManager requestPath:kAggregationRegist parameters:inputsDic success:^(AFHTTPRequestOperation *operation, id result) {
            [catLoadingView stop];
            [refreshControl endRefreshing];
            if (result) {
                if ([result[@"status"] integerValue] == 1)
                {
                    NSDictionary *aggregationPostDic;
                    [ShareMethods showAlertBy:@"明細作成の予約完了しました"];
                    
                    NSMutableDictionary *postDic = [NSMutableDictionary dictionary];
                    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                    if ([[NSUserDefaults standardUserDefaults] objectForKey:kDetailApiLastUpdateDate]) {
                        NSString *base_date = [formatter stringFromDate:[[NSUserDefaults standardUserDefaults] objectForKey:kDetailApiLastUpdateDate]];
                        [postDic setValue:base_date forKey:@"base_date"];
                    }
                    
                    aggregationPostDic = postDic;
                    [self performSelector:@selector(requestDetailsData) withObject:nil afterDelay:30.f];
                }else {
                }
            } else {
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [UIAlertView bk_showAlertViewWithTitle:@"接続失敗しました。\n通信環境の良い状態で再度接続してください。"
                                           message:nil
                                 cancelButtonTitle:nil
                                 otherButtonTitles:@[@"OK"]
                                           handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
                                               [AppConfig shareConfig].isShowAPIAlert = NO;
                                               [catLoadingView stop];
                                               [refreshControl endRefreshing];
                                           }];
        }];
    } else {
        [catLoadingView stop];
        [refreshControl endRefreshing];
    }
}

- (void)requestDetailsData
{
    //aggregationPostDic to post Data
    [RequestManager requestPath:kGetDetail parameters:nil success:^(AFHTTPRequestOperation *operation, id result) {
//        if (result[@"results"]) {
//            [UIAlertView bk_showAlertViewWithTitle:@"新たに取得できる明細はありませんでした"
//                                           message:nil
//                                 cancelButtonTitle:@"OK"
//                                 otherButtonTitles:nil
//                                           handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
//                                           }];
//        }
        
        [self reloadCalendar];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
    }];
}

- (void) scroll {
    if ([CalendarManager sharedManager].isSaveButtonOn || [CalendarManager sharedManager].isKeybordOn) {
        [cardFlowView scroll:NO];
    } else {
        [cardFlowView scroll:YES];
    }
}

-(void)reloadCalendar {
    [calendarView removeFromSuperview];
    calendarView = nil;
    calendarView = [[CalendarView alloc]initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight)];
    calendarView.delegate = self;
    calendarView.calendarDate = [CalendarManager sharedManager].calendarDate;
    [scrollView addSubview:calendarView];
    scrollView.contentSize = calendarView.frame.size;
}

- (void)removeCalendar {
    [CalendarManager sharedManager].isCoverViewOn = NO;
    [clearView removeFromSuperview];
    [cardFlowView removeFromSuperview];
}

@end

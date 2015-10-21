//
//  HomeViewController.m
//  Creco
//
//  Created by Windward on 15/5/17.
//  Copyright (c) 2015年 Windward. All rights reserved.
//

#import "HomeViewController.h"
#import "SLCoverFlowView.h"
#import "CatSayView.h"
#import "CatLoadingView.h"
#import "AddCardViewController.h"
#import "UserCardObject.h"
#import "DetailCostObject.h"
#import "UserWebObject.h"
#import "CalendarView.h"
#import "CoverViewController.h"
#import "CalendarData.h"
#import "CalendarManager.h"
#import "CardManager.h"
#import "PopView.h"
#import "UIAlertView+BlocksKit.h"

#define screenWidth            [UIScreen mainScreen].bounds.size.width
#define screenHeight           [UIScreen mainScreen].bounds.size.height

@interface HomeViewController () <SLCoverFlowViewDelegate, SLCoverFlowViewDataSource, UITableViewDataSource, UITableViewDelegate, CoverViewDelegate>
{
    NSDictionary *catDataDic;
    
    UIButton *refreshBtn;
    
    UILabel *cardNameLabel;
    
    SLCoverFlowView *cardFlowView;
    NSMutableArray *cardsArray;
    
    CatSayView *catSayView;
    CatLoadingView *catLoadingView;
    
    UITableView *costTable;
    UIImageView *headerImageView;
    UILabel *headerWordLabel;
    UILabel *monthCostLabel;
    UILabel *noCostLabel;
    
    CGFloat cellHeight;
    
    NSInteger nowCardIndex;
    
    NSDictionary *aggregationPostDic;

    UserCardObject *nowSelectedUserCardObj;
    
    // Calendar
    UIView *clearView;
    SLCoverFlowView *calendarFlowView;
    NSMutableArray *coverViewArray;
    NSMutableArray *detailDayArray;
}
@property (nonatomic, strong) NSMutableArray *allCostDetailsArray;
@property (nonatomic, strong) NSMutableArray *nowCostDetailsArray;
@property (nonatomic) BOOL isCalendarOn;
@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self onlyNeedStatusView];
    [self setCustomLeftButtonBy:nil];
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"home_bg"]];
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"CatDataList" ofType:@"plist"];
    catDataDic = [NSDictionary dictionaryWithContentsOfFile:path];
    
    cardsArray = [Entry getAllUserCards];
    if (cardsArray.count == 1) cardsArray = [SampleCard getAllSampleCards];
    
    UIImage *cardImage = [UIImage imageNamed:@"default_card"];
    CGFloat scaleSize = 104.f/cardImage.size.height;
    
    cardFlowView = [[SLCoverFlowView alloc] initWithFrame:CGRectMake(0, 0, kAllViewWidth, 320)];
    cardFlowView.backgroundColor = [UIColor clearColor];
    cardFlowView.delegate = self;
    cardFlowView.dataSource = self;
    cardFlowView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    cardFlowView.coverSize = CGSizeMake(cardImage.size.width*scaleSize, cardImage.size.height*scaleSize);
    cardFlowView.coverSpace = 64.0;
    cardFlowView.coverAngle = 0.0;
    cardFlowView.coverScale = 1/scaleSize;
    [self addSubview:cardFlowView];
    [cardFlowView reloadData];
    
    cardNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, cardFlowView.top+30.f, kAllViewWidth, 18)];
    cardNameLabel.textAlignment = NSTextAlignmentCenter;
    cardNameLabel.textColor = [ShareMethods colorFromHexRGB:@"787878"];
    cardNameLabel.font = [UIFont boldSystemFontOfSize:16];
    [self.view addSubview:cardNameLabel];
    
    UIImage *refreshImg = [UIImage imageNamed:@"reload_icon"];
    refreshBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    refreshBtn.frame = CGRectMake(kAllViewWidth-refreshImg.size.width*2.5, 0.f, refreshImg.size.width*2.5, refreshImg.size.height*2.5);
    [refreshBtn setImage:refreshImg forState:UIControlStateNormal];
    [refreshBtn addTarget:self action:@selector(refreshData) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:refreshBtn];
    
    catSayView = [[CatSayView alloc] initWithFrame:CGRectMake(15.f, 265.f, kAllViewWidth-30.f, 54.f)];
    [self.view addSubview:catSayView];
    [self catShowAndSay];
    
    //
    UIImage *headerImage = [UIImage imageNamed:@"move_bar"];
    headerImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, catSayView.bottom-8.f, kAllViewWidth, headerImage.size.height)];
    headerImageView.image = headerImage;
    headerImageView.userInteractionEnabled = YES;
    [self.view addSubview:headerImageView];
    
    CGFloat leftPaddingX = 30.f;
    if (Is_iPhone6)
        leftPaddingX = 35.f;
    else if (Is_iPhone6_Plus)
        leftPaddingX = 40.f;
    headerWordLabel = [[UILabel alloc] initWithFrame:CGRectMake(leftPaddingX, 6.f, 80.f, headerImageView.height-6.f)];
    headerWordLabel.text = @"今月の履歴";
    headerWordLabel.font = [UIFont boldSystemFontOfSize:13];
    headerWordLabel.textColor = [ShareMethods colorFromHexRGB:@"ffffff"];
    [headerImageView addSubview:headerWordLabel];
    
    monthCostLabel = [[UILabel alloc] initWithFrame:CGRectMake(headerWordLabel.right, headerWordLabel.top, headerImageView.width-headerWordLabel.right-15.f, headerWordLabel.height)];
    monthCostLabel.textAlignment = NSTextAlignmentRight;
    monthCostLabel.textColor = headerWordLabel.textColor;
    monthCostLabel.font = headerWordLabel.font;
    monthCostLabel.text = @"合計  ¥0";
    [headerImageView addSubview:monthCostLabel];
    //
    
    UISwipeGestureRecognizer *upOrDownRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeFrom:)];
    [upOrDownRecognizer setDirection:UISwipeGestureRecognizerDirectionUp];
    [headerImageView addGestureRecognizer:upOrDownRecognizer];
    
    costTable = [[UITableView alloc] initWithFrame:CGRectMake(0, headerImageView.bottom, kAllViewWidth, kAllViewHeight+44.f-headerImageView.bottom+20.f-2.f) style:UITableViewStylePlain];
    costTable.delegate = self;
    costTable.dataSource = self;
    costTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:costTable];
    
    noCostLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, costTable.width, costTable.height)];
    noCostLabel.text = @"現在、表示できる明細はありません";
    noCostLabel.textAlignment = NSTextAlignmentCenter;
    noCostLabel.textColor = [ShareMethods colorFromHexRGB:@"787878"];
    noCostLabel.font = [UIFont systemFontOfSize:15];
    noCostLabel.hidden = YES;
    [costTable addSubview:noCostLabel];
    
    // Calendar
    clearView = [[UIView alloc] initWithFrame:CGRectMake(0, 20, screenWidth, screenHeight-20)];
    clearView.backgroundColor = [UIColor blackColor];
    clearView.alpha = 0.5;
    _isCalendarOn = NO;
    
    detailDayArray = [NSMutableArray array];
    coverViewArray = [NSMutableArray array];
    
    cellHeight = 35.f;
    
    self.allCostDetailsArray = [Details getAllDetailCosts];
    if (self.allCostDetailsArray.count == 0 && [Entry getAllUserCards].count == 1)
        self.allCostDetailsArray = [SampleCard getAllSampleCosts];
    
    [self reloadScrollDataByIndex:0];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(selectedCardAndLoadData)
                                                 name:kWebIdIsRegistSuccessed
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removeCalendar) name:@"removeCalendar" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(scroll) name:@"scroll" object:nil];
}

- (void)selectedCardAndLoadData
{
    [self reloadData];
    
    [cardFlowView setCenterViewByIndex:cardsArray.count-1];
    [self reloadScrollDataByIndex:cardsArray.count-1];
    [self refreshData];
}

- (void)reloadData
{
    cardsArray = [Entry getAllUserCards];
    
    if (cardsArray.count > 1)
    {
        [cardFlowView reloadData];
        self.allCostDetailsArray = [Details getAllDetailCosts];
    }else
    {
        cardsArray = [SampleCard getAllSampleCards];
        [cardFlowView reloadData];
        
        self.allCostDetailsArray = [SampleCard getAllSampleCosts];
    }
    
    [self reloadScrollDataByIndex:0];
}

- (void)initData
{
    [RequestManager requestPath:kStartUp parameters:nil success:^(AFHTTPRequestOperation *operation, id result) {
        cardsArray = [Entry getAllUserCards];
        
        if (cardsArray.count > 1)
        {
            [cardFlowView reloadData];
            [kAppDelegate.appTabBarVC.recordVC reloadData];
            
            [self reloadScrollDataByIndex:0];
            if ([[NSUserDefaults standardUserDefaults] boolForKey:kAutoUpdate])
            {
                if ([AppConfig shareConfig].deviceToken.length > 0)
                    [self aggregationToGetDetailData];
                else
                    [self requestDetailsData];
            }
        }else
        {
            cardsArray = [SampleCard getAllSampleCards];
            [cardFlowView reloadData];
            
            self.allCostDetailsArray = [SampleCard getAllSampleCosts];
            [self reloadScrollDataByIndex:0];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
    }];
}

- (void)aggregationToGetDetailData
{
    NSMutableDictionary *inputsDic = [NSMutableDictionary dictionary];
    if (!nowSelectedUserCardObj || [nowSelectedUserCardObj.card_code isEqualToString:kAllCardCode])
    {
        NSArray *userWebsArray = [WebId getAllUserWebs];
        for (int i = 0; i < userWebsArray.count; i ++)
        {
            UserWebObject *userWebObj = userWebsArray[i];
            [inputsDic setValue:userWebObj.service_code forKey:[NSString stringWithFormat:@"inputs[%d][service_code]", i]];
            [inputsDic setValue:userWebObj.password forKey:[NSString stringWithFormat:@"inputs[%d][password]", i]];
            [inputsDic setValue:userWebObj.initialization_vector forKey:[NSString stringWithFormat:@"inputs[%d][initialization_vector]", i]];
            [inputsDic setValue:userWebObj.web_id forKey:[NSString stringWithFormat:@"inputs[%d][web_id]", i]];
        }
    }else
    {
        UserWebObject *userWebObj = [WebId getUserWebObjectByService_code:nowSelectedUserCardObj.service_code];
        if (userWebObj) {
            [inputsDic setValue:userWebObj.service_code forKey:[NSString stringWithFormat:@"inputs[%d][service_code]", 0]];
            [inputsDic setValue:userWebObj.password forKey:[NSString stringWithFormat:@"inputs[%d][password]", 0]];
            [inputsDic setValue:userWebObj.initialization_vector forKey:[NSString stringWithFormat:@"inputs[%d][initialization_vector]", 0]];
            [inputsDic setValue:userWebObj.web_id forKey:[NSString stringWithFormat:@"inputs[%d][web_id]", 0]];
        }
    }
    
    if (inputsDic.count > 0)
    {
        [RequestManager requestPath:kAggregationRegist parameters:inputsDic success:^(AFHTTPRequestOperation *operation, id result) {
            [self catLoadingStop];
            if (result) {
                if ([result[@"status"] integerValue] == 1)
                {
                    [ShareMethods showAlertBy:@"明細作成の予約完了しました"];
                    
                    NSDictionary *updateWordDic = catDataDic[@"Update"];
                    if ([catSayView.sayWord isEqualToString:updateWordDic.allValues[0]])
                        [self catShowAndSay];
                    
                    NSMutableDictionary *postDic = [NSMutableDictionary dictionary];
                    if (!nowSelectedUserCardObj || [nowSelectedUserCardObj.card_code isEqualToString:kAllCardCode]) {
                        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                        [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                        if ([[NSUserDefaults standardUserDefaults] objectForKey:kDetailApiLastUpdateDate]) {
                            NSString *base_date = [formatter stringFromDate:[[NSUserDefaults standardUserDefaults] objectForKey:kDetailApiLastUpdateDate]];
                            [postDic setValue:base_date forKey:@"base_date"];
                        }
                    }else
                    {
                        UserWebObject *userWebObj = [WebId getUserWebObjectByService_code:nowSelectedUserCardObj.service_code];
                        [postDic setValue:userWebObj.web_id_code forKey:@"web_id_code"];
                        [postDic setValue:userWebObj.card_code forKey:@"card_code"];
                    }
                    
                    aggregationPostDic = postDic;
                    
                    [self performSelector:@selector(requestDetailsData) withObject:nil afterDelay:30.f];
                }else
                {
                    if ([result[@"status"] integerValue] == 2) {
                        PopView *popView = [[PopView alloc] initWithPopViewType:PopViewTypeAddCertification withString:result[@"web_view_url"] andIntoSuperView:self.view];
                        [popView showPopView];
                        popView.certificationBlock = ^(NSDictionary *certDic)
                        {
                            if (certDic.count > 0)
                                [self aggregationToGetDetailData];
                        };
                    }
                }
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [self catLoadingStop];
            
            [AppConfig shareConfig].isShowAPIAlert = YES;
            [UIAlertView bk_showAlertViewWithTitle:@"接続失敗しました。\n通信環境の良い状態で再度接続してください。"
                                           message:nil
                                 cancelButtonTitle:nil
                                 otherButtonTitles:@[@"OK"]
                                           handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
                                               [AppConfig shareConfig].isShowAPIAlert = NO;
                                           }];
        }];
    }else
    {
        [self catLoadingStop];
    }
}

- (void)requestDetailsData
{
    [RequestManager requestPath:kGetDetail parameters:aggregationPostDic success:^(AFHTTPRequestOperation *operation, id result) {
        
        [kAppDelegate.defaultImageView removeFromSuperview];
        /*
        if (result[@"results"] && !refreshBtn.enabled) {
            [UIAlertView bk_showAlertViewWithTitle:@"新たに取得できる明細はありませんでした"
                                           message:nil
                                 cancelButtonTitle:@"OK"
                                 otherButtonTitles:nil
                                           handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
                                           }];
        }
        */
        
        [self catLoadingStop];
        
        self.allCostDetailsArray = [Details getAllDetailCosts];
        if (self.allCostDetailsArray.count == 0 && [Entry getAllUserCards].count == 1)
            self.allCostDetailsArray = [SampleCard getAllSampleCosts];
        
        [self reloadScrollDataByIndex:nowCardIndex];
        
        [kAppDelegate.appTabBarVC.recordVC reloadData];//Reload RecordViewController Data
        NSNotification *notification =[NSNotification notificationWithName:@"reloadCalendar" object:nil userInfo:nil];
        [[NSNotificationCenter defaultCenter] postNotification:notification];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [kAppDelegate.defaultImageView removeFromSuperview];
        [self catLoadingStop];
    }];
}

- (void)setAllCostDetailsArray:(NSMutableArray *)allCostDetailsArray
{
    NSArray *orderAllDetailsArray = [allCostDetailsArray sortedArrayUsingComparator:^NSComparisonResult(DetailCostObject *detailCostObj1, DetailCostObject *detailCostObj2)
                                     {
                                         NSString *detailCostDate1 = [detailCostObj1.date componentsSeparatedByString:@" "][0];
                                         NSString *detailCostDate2 = [detailCostObj2.date componentsSeparatedByString:@" "][0];
                                         
                                         NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                                         [formatter setDateFormat:@"yyyy-MM-dd"];
                                         
                                         NSDate *costObj1Date = [formatter dateFromString:detailCostDate1];
                                         NSDate *costObj2Date = [formatter dateFromString:detailCostDate2];
                                         
                                         if ([costObj1Date isEqualToDate:costObj2Date]) {
                                             UserCardObject *userCardObj1 = [Entry getUserCardObjectByService_code:nil andCard_code:detailCostObj1.card_code];
                                             UserCardObject *userCardObj2 = [Entry getUserCardObjectByService_code:nil andCard_code:detailCostObj2.card_code];
                                             
                                             if (userCardObj1.card_seq < userCardObj2.card_seq)
                                                 return NSOrderedAscending;
                                             else if (userCardObj1.card_seq > userCardObj2.card_seq)
                                                 return NSOrderedDescending;
                                             else
                                                 return NSOrderedSame;
                                         }else
                                             return NSOrderedSame;
                                     }];
    _allCostDetailsArray = [NSMutableArray arrayWithArray:orderAllDetailsArray];
}

- (void)setNowCostDetailsArray:(NSMutableArray *)nowCostDetailsArray
{
    if (nowCostDetailsArray.count > 0) {
        NSDate *nowDate = [NSDate date];
        NSCalendar *calendar = [NSCalendar currentCalendar];
        NSDateComponents *nowComponents = [calendar components:(NSCalendarUnitYear | NSCalendarUnitMonth) fromDate:nowDate];
        NSInteger nowYear = nowComponents.year;
        NSInteger nowMonth = nowComponents.month;
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        
        NSMutableArray *tempCostDetailsArray = [NSMutableArray arrayWithArray:nowCostDetailsArray];
        for (DetailCostObject *detailCostObj in tempCostDetailsArray)
        {
            NSDate *costDate = [formatter dateFromString:detailCostObj.date];
            NSCalendar *calendar = [NSCalendar currentCalendar];
            NSDateComponents *dayComponents = [calendar components:(NSCalendarUnitYear | NSCalendarUnitMonth) fromDate:costDate];
            
            if (dayComponents.year != nowYear || dayComponents.month != nowMonth)
                [nowCostDetailsArray removeObject:detailCostObj];
        }
    }
    
    _nowCostDetailsArray = nowCostDetailsArray;
}

- (void)catShowAndSay
{
    BOOL needShowPDF = NO;
    if ([[NSUserDefaults standardUserDefaults] boolForKey:kPDFNoitification]) {
        NSDate *getPDFDate = [[NSUserDefaults standardUserDefaults] objectForKey:kPDFApiLastUpdateDate];
        NSDate *reviewPDFDate = [[NSUserDefaults standardUserDefaults] objectForKey:kReviewPDFLastDate];
        if (getPDFDate && reviewPDFDate)
            needShowPDF = [getPDFDate laterDate:reviewPDFDate] == getPDFDate ? YES : NO;
    }
    
    BOOL needShowMessage = NO;
    NSDate *getMessageDate = [[NSUserDefaults standardUserDefaults] objectForKey:kMessageApiLastUpdateDate];
    NSDate *reviewMessageDate = [[NSUserDefaults standardUserDefaults] objectForKey:kReviewMessageLastDate];
    if (getMessageDate && reviewMessageDate)
        needShowMessage = [getMessageDate laterDate:reviewMessageDate] == getMessageDate ? YES : NO;
    
    BOOL needShowMoney = NO;
    if ([[NSUserDefaults standardUserDefaults] boolForKey:kCostMoneyNotitication])
    {
        NSDate *nowDate = [NSDate date];
        NSCalendar *calendar = [NSCalendar currentCalendar];
        NSDateComponents *nowComponents = [calendar components:(NSCalendarUnitYear | NSCalendarUnitMonth) fromDate:nowDate];
        NSInteger nowYear = nowComponents.year;
        NSInteger nowMonth = nowComponents.month;
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        
        NSInteger totalPrice = 0;
        for (DetailCostObject *detailCostObj in self.allCostDetailsArray)
        {
            NSDate *costDate = [formatter dateFromString:detailCostObj.date];
            NSCalendar *calendar = [NSCalendar currentCalendar];
            NSDateComponents *dayComponents = [calendar components:(NSCalendarUnitYear | NSCalendarUnitMonth) fromDate:costDate];
            
            if (dayComponents.year == nowYear && dayComponents.month == nowMonth)
                totalPrice += [detailCostObj.price integerValue];
        }
        
        NSInteger limitMoneyPrice = [[[[NSUserDefaults standardUserDefaults] valueForKey:kNotifyCostMoneyLimit] stringByReplacingOccurrencesOfString:@"," withString:@""] integerValue];
        if (totalPrice > limitMoneyPrice)
            needShowMoney = YES;
    }
    
    BOOL needShowUpdate = NO;
    NSDate *getAggregationDate = [[NSUserDefaults standardUserDefaults] objectForKey:kAggregationApiLastUpdateDate];
    if (getAggregationDate) {
        NSCalendar *calendar = [NSCalendar currentCalendar];
        NSDateComponents *componentsToAdd = [[NSDateComponents alloc] init];
        [componentsToAdd setDay:7];
        NSDate *dateAfter7Day = [calendar dateByAddingComponents:componentsToAdd toDate:getAggregationDate options:0];
        NSDate *nowDate = [NSDate date];
        needShowUpdate = [nowDate laterDate:dateAfter7Day] == nowDate ? YES : NO;
    }
    
    NSString *showKeyStr = @"";
    NSMutableArray *showWordArray = [NSMutableArray array];
    
    if (needShowPDF || needShowMessage || needShowMoney || needShowUpdate)
    {
        [showWordArray addObject:@"PDF"];
        [showWordArray addObject:@"Message"];
        [showWordArray addObject:@"Money"];
        [showWordArray addObject:@"Money"];
        [showWordArray addObject:@"Money"];
        [showWordArray addObject:@"Update"];
        [showWordArray addObject:@"Update"];
        [showWordArray addObject:@"Update"];
        
        showKeyStr = showWordArray[arc4random()%showWordArray.count];
        
        if ([showKeyStr isEqualToString:@"PDF"] && !needShowPDF)
            showKeyStr = @"";
        if ([showKeyStr isEqualToString:@"Message"] && !needShowMessage)
            showKeyStr = @"";
        if ([showKeyStr isEqualToString:@"Money"] && !needShowMoney)
            showKeyStr = @"";
        if ([showKeyStr isEqualToString:@"Update"] && !needShowUpdate)
            showKeyStr = @"";
    }else
    {
        [showWordArray addObject:@"Other"];
        [showWordArray addObject:@""];
        [showWordArray addObject:@""];
        [showWordArray addObject:@""];
        [showWordArray addObject:@""];
        
        showKeyStr = showWordArray[arc4random()%showWordArray.count];
    }
    
    if (showKeyStr.length > 0) {
        id wordObject = catDataDic[showKeyStr];
        if ([wordObject isKindOfClass:[NSDictionary class]]) {
            NSDictionary *wordDic = (NSDictionary *)wordObject;
            if (![showKeyStr isEqualToString:@"Money"])
                [catSayView say:wordDic.allValues[0] withImage:[UIImage imageTopicNamed:wordDic.allKeys[0]]];
            else
            {
                CGFloat limitMoneyPrice = [[[[NSUserDefaults standardUserDefaults] valueForKey:kNotifyCostMoneyLimit] stringByReplacingOccurrencesOfString:@"," withString:@""] floatValue];
                
                NSString *moneyShowStr = @"";
                if (limitMoneyPrice < 10000)
                    moneyShowStr = [NSString stringWithFormat:@"%@円", [[NSUserDefaults standardUserDefaults] valueForKey:kNotifyCostMoneyLimit]];
                else
                {
                    CGFloat wanFloat = limitMoneyPrice/10000;
                    CGFloat changedWanFloat = ceilf(wanFloat*10)/10;
                    moneyShowStr = [NSString stringWithFormat:@"%@万", [self decimalwithFormat:@"0.0" floatV:changedWanFloat]];
                }
                
                NSString *showWrodStr = [NSString stringWithFormat:wordDic.allValues[0], moneyShowStr];
                [catSayView say:showWrodStr withImage:[UIImage imageTopicNamed:wordDic.allKeys[0]]];
            }
        }else if ([wordObject isKindOfClass:[NSArray class]])
        {
            NSDictionary *wordDic = wordObject[arc4random()%((NSArray *)wordObject).count];
            [catSayView say:wordDic.allValues[0] withImage:[UIImage imageTopicNamed:wordDic.allKeys[0]]];
        }
    }else
        [catSayView say:nil];
}

- (NSString *)decimalwithFormat:(NSString *)format floatV:(float)floatV
{
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setPositiveFormat:format];
    return  [numberFormatter stringFromNumber:[NSNumber numberWithFloat:floatV]];
}

- (void)topicChanged
{
    [super topicChanged];
    [self catShowAndSay];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    if (!self.navigationController.navigationBarHidden)
        [self.navigationController setNavigationBarHidden:YES animated:YES];
}

#pragma mark - GET DETAIL  -

- (void)refreshData
{
    if (!catLoadingView)
        catLoadingView = [CatLoadingView addIntoTheView:self.view ByWordStr:@"更新中..." andWithPoint:CGPointMake(0, 0)];
    catLoadingView.frame = CGRectMake(catLoadingView.left, catSayView.bottom-catLoadingView.height-2, catLoadingView.width, catLoadingView.height);
    
    [self catLoadingStart];
    [self aggregationToGetDetailData];
}

- (void)catLoadingStart
{
    [catLoadingView start];
    catSayView.hidden = YES;
    
    refreshBtn.enabled = NO;
}

- (void)catLoadingStop
{
    [catLoadingView stop];
    catSayView.hidden = NO;
    
    refreshBtn.enabled = YES;
}

#pragma mark -

- (void)handleSwipeFrom:(UISwipeGestureRecognizer *)upOrDownRecognizer
{
    UISwipeGestureRecognizerDirection nowDirecation = UISwipeGestureRecognizerDirectionDown;
    switch (upOrDownRecognizer.direction) {
        case UISwipeGestureRecognizerDirectionUp:
            nowDirecation = UISwipeGestureRecognizerDirectionDown;
            break;
        case UISwipeGestureRecognizerDirectionDown:
            nowDirecation = UISwipeGestureRecognizerDirectionUp;
            break;
        default:
            break;
    }
    
    [UIView animateWithDuration:0.25f animations:^{
        catSayView.frame = CGRectMake(catSayView.left, catSayView.top+(nowDirecation == UISwipeGestureRecognizerDirectionDown ? -130.f : 130.f), catSayView.width, catSayView.height);
        catLoadingView.frame = CGRectMake(catLoadingView.left, catSayView.bottom-catLoadingView.height-2, catLoadingView.width, catLoadingView.height);
        headerImageView.frame = CGRectMake(0, catSayView.bottom-8.f, headerImageView.width, headerImageView.height);
        costTable.frame = CGRectMake(0, headerImageView.bottom, costTable.width, kAllViewHeight+44.f-headerImageView.bottom+20.f-2.f);
        cellHeight = nowDirecation == UISwipeGestureRecognizerDirectionDown ? 40.f : 35.f;
        [costTable reloadData];
    } completion:^(BOOL finished) {
        [upOrDownRecognizer setDirection:nowDirecation];
    }];
}

- (void)clickToAddCardVC
{
    AddCardViewController *addCardVC = [[AddCardViewController alloc] init];
    [self.navigationController pushViewController:addCardVC animated:YES];
}

#pragma mark - SLCoverFlowViewDataSource -

- (NSInteger)numberOfCovers:(SLCoverFlowView *)coverFlowView {
    if (coverFlowView.tag == 2) {
        return detailDayArray.count;
    } else {
        return cardsArray.count+1;
    }
}

- (UIView *)coverFlowView:(SLCoverFlowView *)coverFlowView coverViewAtIndex:(NSInteger)index
{
    if (coverFlowView.tag == 2) {
        CoverViewController *controller = [coverViewArray objectAtIndex:index];
        return controller.view;
    } else {
        int allCardSeq = [Entry getUserCardObjectByService_code:kAllCardCode andCard_code:kAllCardCode].card_seq;
        UserCardObject *userCardObject = nil;
        if (allCardSeq != index && index != cardsArray.count)
            userCardObject = cardsArray[index];
        
        SLCoverView *coverView = [[SLCoverView alloc] initWithFrame:CGRectMake(0.0, 0.0, 0.0, 0.0) andUserCardObject:userCardObject];
        if (index == allCardSeq) {
            NSMutableArray *tempCardsArray = [NSMutableArray arrayWithArray:cardsArray];
            for (int i = 0; i < tempCardsArray.count; i ++)
            {
                UserCardObject *userCardObj = tempCardsArray[i];
                if ([userCardObj.card_code isEqualToString:kAllCardCode]) {
                    [tempCardsArray removeObject:userCardObj];
                    break;
                }
            }
            
            NSMutableArray *imagesArray = [NSMutableArray array];
            for (UserCardObject *userCardObj in tempCardsArray)
            {
                [CardManager sharedManager].color = userCardObj.color;
                NSString *smallImageStr = [NSString stringWithFormat:@"card%d_small", [CardManager sharedManager].index+1];
                [imagesArray addObject:[UIImage imageNamed:smallImageStr]];
            }
            
            coverView.imageView.image = imagesArray.count > 0 ? [ShareMethods getOverlappingImageByArray:imagesArray] : [UIImage imageNamed:@"all_card"];
        }else if (index == cardsArray.count) {
            coverView.imageView.image = [UIImage imageNamed:@"add_card"];
            
            UIButton *addBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            addBtn.frame = CGRectMake(0, 0, coverView.imageView.image.size.width,  coverView.imageView.image.size.height);
            [addBtn addTarget:self action:@selector(clickToAddCardVC) forControlEvents:UIControlEventTouchUpInside];
            [coverView addSubview:addBtn];
        }else
        {
            [CardManager sharedManager].color = userCardObject.color;
            coverView.imageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"card%d_small", [CardManager sharedManager].index+1]];
        }
        
        return coverView;
    }
}

#pragma mark - SLCoverFlowViewDelegate -

- (void)coverFlowViewNowMovingIndex:(NSInteger)movingIndex
{
    if (_isCalendarOn)
        return;
    
    if (nowCardIndex == movingIndex)
        return;
    
    [self reloadScrollDataByIndex:movingIndex];
}

- (void)reloadScrollDataByIndex:(NSInteger)index
{
    nowCardIndex = index;
    
    if (index == cardsArray.count) {
        cardNameLabel.text = @"新規カード追加";
        
        [self catLoadingStop];
        [catSayView say:nil];
        refreshBtn.hidden = YES;
        
        nowSelectedUserCardObj = nil;
        self.nowCostDetailsArray = nil;
        monthCostLabel.hidden = YES;
        headerWordLabel.hidden = YES;
        noCostLabel.hidden = YES;
    }else
    {
        if (refreshBtn.hidden) refreshBtn.hidden = NO;
        if (costTable.hidden) costTable.hidden = NO;
        
        UserCardObject *userCardObj = cardsArray[index];
        nowSelectedUserCardObj = userCardObj;
        cardNameLabel.text = userCardObj.card_name;
        
        if ([userCardObj.card_code isEqualToString:kAllCardCode])
            self.nowCostDetailsArray = self.allCostDetailsArray;
        else
        {
            [self catShowAndSay];
            if ([Entry getAllUserCards].count > 1)
                self.nowCostDetailsArray = [Details getCardDetailCostsBy:userCardObj.card_code];
            else
                self.nowCostDetailsArray = [SampleCard getSampleCardCostsBy:userCardObj.card_code];
        }
        
        monthCostLabel.hidden = NO;
        headerWordLabel.hidden = NO;
        [self calMonthTotalCost];
        
        noCostLabel.hidden = self.nowCostDetailsArray.count > 0 ? YES : NO;
    }
    
    [costTable reloadData];
}

- (void)calMonthTotalCost
{
    NSInteger totalPrice = 0;
    for (DetailCostObject *detailCostObj in self.nowCostDetailsArray)
        totalPrice += [detailCostObj.price integerValue];
    NSString *moneyStr = [ShareMethods moneyStrToDecimal:[NSString stringWithFormat:@"%ld", totalPrice]];
    monthCostLabel.text = [NSString stringWithFormat:@"合計  ¥%@", moneyStr];
}

#pragma mark - UITableView DataSource -

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.nowCostDetailsArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return cellHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellStr = @"CostCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellStr];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellStr];
    }
    
    UILabel *lineLabel = (UILabel *)[cell viewWithTag:kDefaultViewTag];
    if (!lineLabel) {
        lineLabel = [[UILabel alloc] init];
        lineLabel.tag = kDefaultViewTag;
        lineLabel.backgroundColor = COLOR_LINE;
        [cell addSubview:lineLabel];
    }
    lineLabel.frame = CGRectMake(0, cellHeight-0.5f, tableView.width, 0.5f);
    
    DetailCostObject *detailCostObj = self.nowCostDetailsArray[indexPath.row];
    
    UILabel *contentLabel = (UILabel *)[cell.contentView viewWithTag:1];
    if (!contentLabel) {
        contentLabel = [[UILabel alloc] init];
        contentLabel.tag = 1;
        contentLabel.font = [UIFont systemFontOfSize:12];
        contentLabel.textColor = [ShareMethods colorFromHexRGB:@"505050"];
        [cell.contentView addSubview:contentLabel];
    }
    
    CGFloat contentWidth = 220.f;
    if (Is_iPhone6)
        contentWidth = 275.f;
    else if (Is_iPhone6_Plus)
        contentWidth = 300.f;
    contentLabel.frame = CGRectMake(20.f, 0, contentWidth, cellHeight);
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *costDate = [formatter dateFromString:detailCostObj.date];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *dayComponents = [calendar components:(NSCalendarUnitMonth | NSCalendarUnitDay) fromDate:costDate];
    
    NSString *dateStr = [NSString stringWithFormat:@"%02ld/%02ld", dayComponents.month, dayComponents.day];
    if (dateStr.length == 3)
        dateStr = [dateStr stringByAppendingString:@"    "];
    else if (dateStr.length == 4)
        dateStr = [dateStr stringByAppendingString:@"  "];
    
    contentLabel.text = [NSString stringWithFormat:@"%@       %@", dateStr, detailCostObj.name];
    
    UILabel *moneyLabel = (UILabel *)[cell.contentView viewWithTag:2];
    if (!moneyLabel) {
        moneyLabel = [[UILabel alloc] init];
        moneyLabel.tag = 2;
        moneyLabel.font = [UIFont systemFontOfSize:12];
        moneyLabel.textColor = [ShareMethods colorFromHexRGB:@"505050"];
        moneyLabel.textAlignment = NSTextAlignmentRight;
        [cell.contentView addSubview:moneyLabel];
    }
    moneyLabel.frame = CGRectMake(kAllViewWidth-20.f-65, 0, 65, cellHeight);
    NSString *changedMoneyStr = [ShareMethods moneyStrToDecimal:detailCostObj.price];
    moneyLabel.text = [NSString stringWithFormat:@"￥%@", changedMoneyStr];
    
    UILabel *dotLabel = (UILabel *)[cell.contentView viewWithTag:3];
    if (!dotLabel) {
        dotLabel = [[UILabel alloc] init];
        dotLabel.tag = 3;
        dotLabel.backgroundColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.6f];
        dotLabel.layer.cornerRadius = 3.f;
        dotLabel.clipsToBounds = YES;
        [cell.contentView addSubview:dotLabel];
    }
    dotLabel.frame = CGRectMake(moneyLabel.left-6.f, (cellHeight-6.f)/2, 6.f, 6.f);
    dotLabel.hidden = detailCostObj.note.length > 0 ? NO : YES;
    
    return cell;
}

#pragma mark - UITableView Delegate - 

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    _isCalendarOn = YES;
    [tableView deselectRowAtIndexPath:indexPath animated:YES]; // 選択状態の解除
    DetailCostObject *detailCostObject = self.nowCostDetailsArray[indexPath.row];
    NSString *date = detailCostObject.date;
    NSString *selectedMonth = [date substringToIndex:7];
    
    NSMutableArray *array = [Entry getAllUserCards];
    if (array.count > 1) {
        if (![nowSelectedUserCardObj.card_code isEqual:kAllCardCode]) {
            detailDayArray = [Details getCardDetailCostsByASC:detailCostObject.card_code];
        } else {
            detailDayArray = [Details getAllDetailCostsOrderBy];
        }
    } else {
        if (![nowSelectedUserCardObj.card_code isEqual:kAllCardCode]) {
            detailDayArray = [SampleCard getSampleCardCostsByASC:detailCostObject.card_code];
        } else {
            detailDayArray = [SampleCard getAllSampleCostsOrderBy];
        }
    }

    for (int i = 0; i < detailDayArray.count; i ++) {
        DetailCostObject *obj = [detailDayArray objectAtIndex:i];
        NSString *month = [obj.date substringToIndex:7];
        
        if (![selectedMonth isEqualToString:month]) {
            [detailDayArray removeObjectAtIndex:i];
            i --;
        }
    }
    
    calendarFlowView = [[SLCoverFlowView alloc] initWithFrame:CGRectMake(0, -14, screenWidth, screenHeight)];
    calendarFlowView.backgroundColor = [UIColor clearColor];
    calendarFlowView.delegate = self;
    calendarFlowView.dataSource = self;
    calendarFlowView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    calendarFlowView.coverSize = CGSizeMake(280, 440);
    calendarFlowView.coverSpace = 10.0;
    calendarFlowView.coverAngle = 0.0;
    calendarFlowView.coverScale = 1;
    calendarFlowView.tag = 2;
    
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"isCalendar"];
    [calendarFlowView reloadData];
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
    
    [calendarFlowView move:(int)detailDayArray.count-1-(int)indexPath.row];
    [CalendarManager sharedManager].currentIndex = (int)detailDayArray.count-1-(int)indexPath.row;

    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    if (detailDayArray.count != 0 && [CalendarManager sharedManager].isCoverViewOn == NO) {
        [CalendarManager sharedManager].isCoverViewOn = YES;
        [appDelegate.window addSubview:clearView];
        [appDelegate.window addSubview:calendarFlowView];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kWebIdIsRegistSuccessed object:nil];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - SLCoverFlowViewDelegate -
- (void)coverFlowViewMovedEndAtIndex:(NSInteger)index {
    [CalendarManager sharedManager].currentIndex = (int)index;
}

#pragma mark - SLCoverFlowViewDelegate -
- (void)removeCoverFlow {
    _isCalendarOn = NO;
    [CalendarManager sharedManager].isCoverViewOn = NO;
    [clearView removeFromSuperview];
    [calendarFlowView removeFromSuperview];
}

- (void)removeCalendar {
    _isCalendarOn = NO;
    [CalendarManager sharedManager].isCoverViewOn = NO;
    [clearView removeFromSuperview];
    [calendarFlowView removeFromSuperview];
}

- (void) scroll {
    if ([CalendarManager sharedManager].isSaveButtonOn || [CalendarManager sharedManager].isKeybordOn) {
        [calendarFlowView scroll:NO];
    } else {
        [calendarFlowView scroll:YES];
    }
}

@end

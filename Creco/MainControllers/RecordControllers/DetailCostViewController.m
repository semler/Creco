//
//  DetailCostViewController.m
//  Creco
//
//  Created by Windward on 15/6/6.
//  Copyright (c) 2015年 Windward. All rights reserved.
//

#import "DetailCostViewController.h"
#import "RecordCostCell.h"
#import "SLCoverFlowView.h"
#import "CoverViewController.h"
#import "CalendarManager.h"
#import "CalendarData.h"

#define screenWidth            [UIScreen mainScreen].bounds.size.width
#define screenHeight           [UIScreen mainScreen].bounds.size.height

@interface DetailCostViewController () <UITableViewDataSource, UITableViewDelegate, SLCoverFlowViewDelegate, SLCoverFlowViewDataSource, CoverViewDelegate, ClickEveryDetailCostViewDelegate>
{
    UITableView *detailCostTable;
    
    NSMutableArray *orderDetailsArray;
    
    // Calendar
    UIView *clearView;
    SLCoverFlowView *calendarFlowView;
    NSMutableArray *coverViewArray;
    NSMutableArray *detailDayArray;
}
@end

@implementation DetailCostViewController

- (void)topicChanged
{
    [super topicChanged];
    [detailCostTable reloadData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    CGFloat totalCostWidth = 60.f;
    UILabel *totalCostLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.navigationController.navigationBar.width-totalCostWidth-20.f, (self.navigationController.navigationBar.height-10.f)/2+3.f, totalCostWidth, 10.f)];
    totalCostLabel.text = self.showTotalPriceStr;
    totalCostLabel.font = [UIFont systemFontOfSize:9];
    totalCostLabel.textColor = [ShareMethods colorFromHexRGB:@"7e8699"];
    totalCostLabel.textAlignment = NSTextAlignmentRight;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:totalCostLabel];
    
    detailCostTable = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kAllViewWidth, kAllViewHeight) style:UITableViewStylePlain];
    detailCostTable.delegate = self;
    detailCostTable.dataSource = self;
    detailCostTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:detailCostTable];
    
    orderDetailsArray = [NSMutableArray array];
    
    NSInteger sameDay = 0;
    NSMutableArray *sameDayDataArray = [NSMutableArray array];
    for (int i = 0; i < self.nowDetailCostsArray.count; i ++)
    {
        DetailCostObject *detailCostObj = self.nowDetailCostsArray[i];

        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSDate *costDate = [formatter dateFromString:detailCostObj.date];
        NSCalendar *calendar = [NSCalendar currentCalendar];
        NSDateComponents *dateComponents = [calendar components:NSCalendarUnitDay fromDate:costDate];
        
        if (sameDay == dateComponents.day) {
            [sameDayDataArray addObject:detailCostObj];
        }else
        {
            if (sameDayDataArray.count > 0)
            {
                [orderDetailsArray addObject:[self orderDataArrayBy:[NSArray arrayWithArray:sameDayDataArray]]];
                [sameDayDataArray removeAllObjects];
            }
            
            sameDay = dateComponents.day;
            [sameDayDataArray addObject:detailCostObj];
        }
        
        if (i == self.nowDetailCostsArray.count-1) {
            [orderDetailsArray addObject:[self orderDataArrayBy:[NSArray arrayWithArray:sameDayDataArray]]];
            [sameDayDataArray removeAllObjects];
        }
    }
    
    // Calendar
    clearView = [[UIView alloc] initWithFrame:CGRectMake(0, 20, screenWidth, screenHeight-20)];
    clearView.backgroundColor = [UIColor blackColor];
    clearView.alpha = 0.5;
    
    detailDayArray = [NSMutableArray array];
    coverViewArray = [NSMutableArray array];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removeCalendar) name:@"removeCalendar" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(scroll) name:@"scroll" object:nil];
}

- (NSArray *)orderDataArrayBy:(NSArray *)sameDayDataArray
{
    NSArray *orderSameDataArray = [sameDayDataArray sortedArrayUsingComparator:^NSComparisonResult(DetailCostObject *obj1, DetailCostObject *obj2) {
        UserCardObject *userCardObj1 = [Entry getUserCardObjectByService_code:nil andCard_code:obj1.card_code];
        UserCardObject *userCardObj2 = [Entry getUserCardObjectByService_code:nil andCard_code:obj2.card_code];
        if (userCardObj1.card_seq < userCardObj2.card_seq)
            return NSOrderedAscending;
        else if (userCardObj1.card_seq > userCardObj2.card_seq)
            return NSOrderedDescending;
        else
            return NSOrderedSame;
    }];
    return orderSameDataArray;
}

#pragma mark - UITableView DataSource -

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return orderDetailsArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return ((NSArray *)orderDetailsArray[indexPath.row]).count * kEveryRecordCostHeght;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellStr = @"CostCell";
    RecordCostCell *cell = [tableView dequeueReusableCellWithIdentifier:cellStr];
    if (!cell) {
        cell = [[RecordCostCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellStr];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.clickDelegate = self;
    }
    
    [cell reloadDataBy:orderDetailsArray[indexPath.row]];
    return cell;
}

#pragma mark - UITableView Delegate -

//Do Nothing
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //
}

#pragma mark - ClickEveryDetailCostViewDelegate -

- (void)clickTheDetailCostViewWith:(DetailCostObject *)detailCostObj
{
    NSString *date = detailCostObj.date;
    NSString *selectedMonth = [date substringToIndex:7];
    
    NSMutableArray *array = [Entry getAllUserCards];
    
    BOOL monthFlg = NO;
    for (DetailCostObject *obj in _nowDetailCostsArray) {
        if (![obj.card_code isEqualToString: detailCostObj.card_code]) {
            monthFlg = YES;
            break;
        }
    }
    
    if (array.count > 1) {
        if (monthFlg) {
            detailDayArray = [Details getAllDetailCostsOrderBy];
        } else {
            detailDayArray = [Details getCardDetailCostsByASC:detailCostObj.card_code];
        }
    } else {
        if (monthFlg) {
            detailDayArray = [SampleCard getAllSampleCostsOrderBy];
        } else {
            detailDayArray = [SampleCard getSampleCardCostsByASC:detailCostObj.card_code];
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
    
    int index = 0;;
    for (int i = 0; i < detailDayArray.count; i ++) {
        index = i;
        DetailCostObject *obj = [detailDayArray objectAtIndex:i];
        if ([obj.date isEqualToString:detailCostObj.date] && [obj.code isEqualToString:detailCostObj.code]) {
            break;
        }
    }
    [calendarFlowView move:index];
    [CalendarManager sharedManager].currentIndex = (int)index;
    
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - SLCoverFlowViewDataSource -

- (NSInteger)numberOfCovers:(SLCoverFlowView *)coverFlowView {
    return detailDayArray.count;
}

- (UIView *)coverFlowView:(SLCoverFlowView *)coverFlowView coverViewAtIndex:(NSInteger)index
{
    CoverViewController *controller = [coverViewArray objectAtIndex:index];
    return controller.view;
}

- (void)coverFlowViewMovedEndAtIndex:(NSInteger)index {
    [CalendarManager sharedManager].currentIndex = (int)index;
}

#pragma mark - SLCoverFlowViewDelegate -
- (void)removeCoverFlow {
    [CalendarManager sharedManager].isCoverViewOn = NO;
    [clearView removeFromSuperview];
    [calendarFlowView removeFromSuperview];
}

- (void)removeCalendar {
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

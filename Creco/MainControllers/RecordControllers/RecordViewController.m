//
//  RecordViewController.m
//  Creco
//
//  Created by Windward on 15/5/17.
//  Copyright (c) 2015年 Windward. All rights reserved.
//

#import "RecordViewController.h"
#import "DetailCostViewController.h"
#import "Details.h"
#import "Entry.h"
#import "UserCardObject.h"
#import "DetailCostObject.h"

@interface RecordViewController () <UITableViewDataSource, UITableViewDelegate>
{
    UITableView *recordTable;
    
    NSMutableArray *allDataArray;
}
@end

@implementation RecordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setCustomLeftButtonBy:nil];
    self.view.backgroundColor = [UIColor grayColor];
    self.navigationItem.title = @"カード履歴";
    
    recordTable = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kAllViewWidth, kAllViewHeight) style:UITableViewStylePlain];
    recordTable.delegate = self;
    recordTable.dataSource = self;
    recordTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:recordTable];
    
    [self reloadData];
}

- (void)reloadData
{
    allDataArray = [NSMutableArray array];
    NSMutableArray *allDetailCostsArray = [Details getAllDetailCosts];
    if ([Entry getAllUserCards].count == 1) allDetailCostsArray = [SampleCard getAllSampleCosts];
    
    NSInteger sameYear = 0;
    NSInteger sameMonth = 0;
    NSMutableArray *sameYearMonthDataArray = [NSMutableArray array];
    for (int i = 0; i < allDetailCostsArray.count; i ++)
    {
        DetailCostObject *detailCostObj = allDetailCostsArray[i];
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSDate *costDate = [formatter dateFromString:detailCostObj.date];
        NSCalendar *calendar = [NSCalendar currentCalendar];
        NSDateComponents *dateComponents = [calendar components:(NSCalendarUnitYear | NSCalendarUnitMonth) fromDate:costDate];
        
        if (sameYear == dateComponents.year && sameMonth == dateComponents.month) {
            [sameYearMonthDataArray addObject:detailCostObj];
        }else
        {
            if (sameYearMonthDataArray.count > 0)
            {
                [allDataArray addObject:[NSArray arrayWithArray:sameYearMonthDataArray]];
                [sameYearMonthDataArray removeAllObjects];
            }
            
            sameYear = dateComponents.year;
            sameMonth = dateComponents.month;
            [sameYearMonthDataArray addObject:detailCostObj];
        }
        
        if (i == allDetailCostsArray.count-1) {
            [allDataArray addObject:[NSArray arrayWithArray:sameYearMonthDataArray]];
            [sameYearMonthDataArray removeAllObjects];
        }
    }
    
    [recordTable reloadData];
}

- (NSArray *)getCardsDeduplicateAndOrderArrayBy:(NSArray *)initArray
{
    NSArray *cardDetailCostsArray = [NSArray arrayWithArray:initArray];
    
    NSMutableArray *deduplicateArray = [NSMutableArray array];
    for (int i = 0; i < cardDetailCostsArray.count; i ++)
    {
        DetailCostObject *detailCostObj = cardDetailCostsArray[i];
        
        BOOL hasSame = NO;
        for (DetailCostObject *deduplicateCostObj in deduplicateArray)
        {
            if ([detailCostObj.card_code isEqualToString:deduplicateCostObj.card_code]) {
                hasSame = YES;
                break;
            }
        }
        
        if (!hasSame)
            [deduplicateArray addObject:detailCostObj];
    }
    
    NSArray *orderArray = [deduplicateArray sortedArrayUsingComparator:^NSComparisonResult(DetailCostObject *obj1, DetailCostObject *obj2) {
        UserCardObject *userCardObj1 = [Entry getUserCardObjectByService_code:nil andCard_code:obj1.card_code];
        UserCardObject *userCardObj2 = [Entry getUserCardObjectByService_code:nil andCard_code:obj2.card_code];
        if (userCardObj1.card_seq < userCardObj2.card_seq)
            return NSOrderedAscending;
        else if (userCardObj1.card_seq > userCardObj2.card_seq)
            return NSOrderedDescending;
        else
            return NSOrderedSame;
    }];
    
    return orderArray;
}

- (NSString *)getTotalCostPriceStrBy:(NSArray *)detailCostsArray
{
    NSInteger totalPrice = 0;
    for (DetailCostObject *detailCostObj in detailCostsArray)
        totalPrice += [detailCostObj.price integerValue];
    NSString *changedTotalPriceStr = [ShareMethods moneyStrToDecimal:[NSString stringWithFormat:@"%ld", totalPrice]];
    return [NSString stringWithFormat:@"￥%@", changedTotalPriceStr];
}

#pragma mark - UITableView DataSource -

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return allDataArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *deduplicateOrderArray = [self getCardsDeduplicateAndOrderArrayBy:allDataArray[section]];
    return deduplicateOrderArray.count;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    NSArray *monthDataArray = allDataArray[section];
    if (monthDataArray.count > 0)
    {
        DetailCostObject *detailCostObj = monthDataArray[0];
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSDate *costDate = [formatter dateFromString:detailCostObj.date];
        NSCalendar *calendar = [NSCalendar currentCalendar];
        NSDateComponents *dateComponents = [calendar components:(NSCalendarUnitYear | NSCalendarUnitMonth) fromDate:costDate];
        
        UITableViewCell *sectionCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
        sectionCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        sectionCell.backgroundColor = [UIColor lightGrayColor];
        sectionCell.textLabel.textColor = [ShareMethods colorFromHexRGB:@"ffffff"];
        sectionCell.textLabel.text = [NSString stringWithFormat:@"%ld年 %ld月", dateComponents.year, dateComponents.month];
        sectionCell.textLabel.font = [UIFont systemFontOfSize:14];
        
        UIButton *sectionBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        sectionBtn.frame = CGRectMake(0, 0, sectionCell.width, sectionCell.height);
        sectionBtn.tag = section;
        sectionBtn.titleLabel.text = sectionCell.textLabel.text;
        [sectionBtn addTarget:self action:@selector(goToMonthCostVC:) forControlEvents:UIControlEventTouchUpInside];
        [sectionCell addSubview:sectionBtn];
        
        UILabel *moneyLabel = [[UILabel alloc] initWithFrame:CGRectMake(kAllViewWidth-150.f-38.f, 0, 150.f, 44.f)];
        moneyLabel.text = [self getTotalCostPriceStrBy:monthDataArray];
        moneyLabel.textAlignment = NSTextAlignmentRight;
        moneyLabel.textColor = sectionCell.textLabel.textColor;
        moneyLabel.font = sectionCell.textLabel.font;
        moneyLabel.tag = kDefaultViewTag;
        [sectionBtn addSubview:moneyLabel];
        
        return sectionCell;
    }else
        return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 44.f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellStr = @"RecordCostCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellStr];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellStr];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.textLabel.textColor = [ShareMethods colorFromHexRGB:@"7e8699"];
        cell.textLabel.font = [UIFont systemFontOfSize:14];
        
        DrawLine(cell, 0, 44.f-0.5f, tableView.width, 0.5f, COLOR_LINE);
    }
    
    NSArray *deduplicateOrderArray = [self getCardsDeduplicateAndOrderArrayBy:allDataArray[indexPath.section]];
    DetailCostObject *nowDetailCostObj = deduplicateOrderArray[indexPath.row];
    
    UILabel *titleLabel = (UILabel *)[cell.contentView viewWithTag:kDefaultViewTag];
    if (!titleLabel) {
        titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(15.f, 0, kAllViewWidth-80.f-38.f-15.f, 44.f)];
        titleLabel.tag = kDefaultViewTag;
        titleLabel.textColor = cell.textLabel.textColor;
        titleLabel.font = cell.textLabel.font;
        [cell.contentView addSubview:titleLabel];
    }
    UserCardObject *userCardObj = [Entry getUserCardObjectByService_code:nil andCard_code:nowDetailCostObj.card_code];
    if (!userCardObj && [Entry getAllUserCards].count == 1) userCardObj = [SampleCard getUserCardObjectByCard_code:nowDetailCostObj.card_code];
    titleLabel.text = userCardObj.card_name;
    
    UILabel *moneyLabel = (UILabel *)[cell.contentView viewWithTag:kDefaultViewTag+1];
    if (!moneyLabel) {
        moneyLabel = [[UILabel alloc] initWithFrame:CGRectMake(kAllViewWidth-80.f-38.f, 0, 80.f, 44.f)];
        moneyLabel.textAlignment = NSTextAlignmentRight;
        moneyLabel.textColor = cell.textLabel.textColor;
        moneyLabel.font = cell.textLabel.font;
        moneyLabel.tag = kDefaultViewTag+1;
        [cell.contentView addSubview:moneyLabel];
    }
    
    NSArray *sectionDetailsArray = allDataArray[indexPath.section];
    NSMutableArray *cardDetailsArray = [NSMutableArray array];
    for (DetailCostObject *detailCostObj in sectionDetailsArray)
    {
        if ([detailCostObj.card_code isEqualToString:nowDetailCostObj.card_code])
            [cardDetailsArray addObject:detailCostObj];
    }
    
    moneyLabel.text = [self getTotalCostPriceStrBy:cardDetailsArray];
    
    return cell;
}

#pragma mark - UITableView Delegate -

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    NSArray *deduplicateOrderArray = [self getCardsDeduplicateAndOrderArrayBy:allDataArray[indexPath.section]];
    DetailCostObject *nowDetailCostObj = deduplicateOrderArray[indexPath.row];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *costDate = [formatter dateFromString:nowDetailCostObj.date];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *dateComponents = [calendar components:(NSCalendarUnitYear | NSCalendarUnitMonth) fromDate:costDate];
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    UILabel *titleLabel = (UILabel *)[cell.contentView viewWithTag:kDefaultViewTag];
    
    DetailCostViewController *detailCostVC = [[DetailCostViewController alloc] init];
    detailCostVC.navigationItem.title = [NSString stringWithFormat:@"%ld月 %@", dateComponents.month , titleLabel.text];
    detailCostVC.showTotalPriceStr = ((UILabel *)[cell.contentView viewWithTag:kDefaultViewTag+1]).text;
    
    NSArray *sectionDetailsArray = allDataArray[indexPath.section];
    NSMutableArray *fiterDetailsArray = [NSMutableArray array];
    for (DetailCostObject *detailCostObj in sectionDetailsArray)
    {
        if ([detailCostObj.card_code isEqualToString:nowDetailCostObj.card_code])
            [fiterDetailsArray addObject:detailCostObj];
    }
    
    detailCostVC.nowDetailCostsArray = fiterDetailsArray;
    [self.navigationController pushViewController:detailCostVC animated:YES];
}

- (void)goToMonthCostVC:(UIButton *)sectionBtn
{
    DetailCostViewController *detailCostVC = [[DetailCostViewController alloc] init];
    detailCostVC.title = sectionBtn.titleLabel.text;
    detailCostVC.showTotalPriceStr = ((UILabel *)[sectionBtn viewWithTag:kDefaultViewTag]).text;
    detailCostVC.nowDetailCostsArray = allDataArray[sectionBtn.tag];
    [self.navigationController pushViewController:detailCostVC animated:YES];
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

//
//  TopicViewController.m
//  Creco
//
//  Created by Windward on 15/6/26.
//  Copyright (c) 2015年 Windward. All rights reserved.
//

#import "TopicViewController.h"
#import "AddCardViewController.h"

#define kTopicArray          @[@{@"2045a1":@"ネイビー"}, @{@"eb6877":@"ピンク"}, @{@"c29861":@"モカ"}]
#define kTopicCellHeight     45.f

@interface TopicViewController () <UITableViewDataSource, UITableViewDelegate>
{
    UITableViewCell *selectedCell;
}
@end

@implementation TopicViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    self.navigationItem.title = @"きせかえ";
    
    UITableView *topicTable = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kAllViewWidth, kAllViewHeight) style:UITableViewStylePlain];
    topicTable.delegate = self;
    topicTable.dataSource = self;
    topicTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    topicTable.backgroundColor = [UIColor clearColor];
    [self.view addSubview:topicTable];
}

- (void)clickRightButton
{
    AddCardViewController *addCardVC = [[AddCardViewController alloc] init];
    [self.navigationController pushViewController:addCardVC animated:YES];
}

#pragma mark - UITableView DataSource -

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return kTopicArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kTopicCellHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellStr = @"TopicCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellStr];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellStr];
        cell.textLabel.textColor = [ShareMethods colorFromHexRGB:@"505050"];
        cell.textLabel.font = [UIFont systemFontOfSize:14];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        DrawLine(cell, 0, kTopicCellHeight-0.5f, tableView.width, 0.5f, COLOR_LINE);
    }
    
    NSDictionary *topicDic = kTopicArray[indexPath.row];
    if (topicDic)
    {
        UILabel *topicColorLabel = (UILabel *)[cell.contentView viewWithTag:1];
        if (!topicColorLabel) {
            topicColorLabel = [[UILabel alloc] initWithFrame:CGRectMake(20.f, (kTopicCellHeight-16.f)/2, 16.f, 16.f)];
            topicColorLabel.layer.cornerRadius = 8.f;
            topicColorLabel.clipsToBounds = YES;
            [cell.contentView addSubview:topicColorLabel];
        }
        topicColorLabel.backgroundColor = [ShareMethods colorFromHexRGB:topicDic.allKeys[0]];
        
        UILabel *titleLabel = (UILabel *)[cell.contentView viewWithTag:2];
        if (!titleLabel) {
            titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(topicColorLabel.right+26.f, 0.f, 200, kTopicCellHeight)];
            titleLabel.textColor = [ShareMethods colorFromHexRGB:@"505050"];
            titleLabel.font = [UIFont systemFontOfSize:14];
            [cell.contentView addSubview:titleLabel];
        }
        titleLabel.text = topicDic.allValues[0];
        
        if ([topicDic.allKeys[0] isEqualToString:[[NSUserDefaults standardUserDefaults] valueForKey:kAppTopicColor]])
        {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
            selectedCell = cell;
        }else
            cell.accessoryType = UITableViewCellAccessoryNone;
    }

    return cell;
}

#pragma mark - UITableView Delegate -

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    UITableViewCell *nowCell = [tableView cellForRowAtIndexPath:indexPath];
    if ([nowCell isEqual:selectedCell])
        return;
    
    selectedCell.accessoryType = UITableViewCellAccessoryNone;
    nowCell.accessoryType = UITableViewCellAccessoryCheckmark;
    selectedCell = nowCell;
    
    NSDictionary *topicDic = kTopicArray[indexPath.row];
    [[NSUserDefaults standardUserDefaults] setValue:topicDic.allKeys[0] forKey:kAppTopicColor];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [kAppDelegate customizeAppearance];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kTopicIsChanged object:nil];
    
    [self.navigationController popViewControllerAnimated:YES];
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

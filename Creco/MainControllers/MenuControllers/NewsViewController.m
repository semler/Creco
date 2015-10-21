//
//  NewsViewController.m
//  Creco
//
//  Created by Windward on 15/6/15.
//  Copyright (c) 2015年 Windward. All rights reserved.
//

#import "NewsViewController.h"
#import "NewsCell.h"
#import "NewsObject.h"

@interface NewsViewController () <UITableViewDataSource, UITableViewDelegate>
{
    UITableView *newsTable;
    NSMutableArray *newsDataArray;
}
@end

@implementation NewsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    self.navigationItem.title = @"お知らせ";
    self.view.backgroundColor = COLOR_VIEW_OTHER_BACKGROUND;
    
    UIButton *readAllBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    readAllBtn.frame = CGRectMake(0, 0, 60.f, 20.f);
    [readAllBtn setTitle:@"全て既読" forState:UIControlStateNormal];
    [readAllBtn setTitleColor:[ShareMethods colorFromHexRGB:[[NSUserDefaults standardUserDefaults] valueForKey:kAppTopicColor]] forState:UIControlStateNormal];
    readAllBtn.titleLabel.font = [UIFont systemFontOfSize:12];
    readAllBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    [readAllBtn addTarget:self action:@selector(readAllNews) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:readAllBtn];
    
    newsTable = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kAllViewWidth, kAllViewHeight) style:UITableViewStylePlain];
    newsTable.delegate = self;
    newsTable.dataSource = self;
    newsTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    newsTable.backgroundColor = [UIColor clearColor];
    [self.view addSubview:newsTable];
    
    newsDataArray = [InfoRead getAllNewsObjects];
    
    [[AppConfig shareConfig] showLoadingView];
    [RequestManager requestPath:kGetMessageNotification parameters:nil success:^(AFHTTPRequestOperation *operation, id result) {
        [[AppConfig shareConfig] hiddenLoadingView];
        
        if ([result isKindOfClass:[NSArray class]])
            newsDataArray = result;
        else
            newsDataArray = nil;
        [newsTable reloadData];
        
        [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:kReviewMessageLastDate];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [[AppConfig shareConfig] hiddenLoadingView];
    }];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:YES];
    [[AppConfig shareConfig] hiddenLoadingView];
}

- (void)readAllNews
{
    for (NewsObject *newsObj in newsDataArray)
    {
        if (![InfoRead getMessageIsReadOrNotByCode:newsObj.code]) {
            [InfoRead updateInfoReadInDBByCode:newsObj.code andIsRead:1];
        }
    }
    
    [newsTable reloadData];
    kAppDelegate.appTabBarVC.menuTabbarItem.badgeValue = [InfoRead getUnReadMessageCount] > 0 ? @"N" : nil;
}

#pragma mark - UITableView DataSource -

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return newsDataArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NewsObject *newsObj = newsDataArray[indexPath.row];
    if (newsObj.isShowAllWord)
        return kDefaultNewsCellHeight+newsObj.contentHeight+kNewsCellDefaultPaddingY*2;
    return kDefaultNewsCellHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellStr = @"NewsCell";
    NewsCell *cell = [tableView dequeueReusableCellWithIdentifier:cellStr];
    if (!cell) {
        cell = [[NewsCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellStr];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    [cell setNewsDataBy:newsDataArray[indexPath.row]];
    return cell;
}

#pragma mark - UITableView Delegate -

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
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

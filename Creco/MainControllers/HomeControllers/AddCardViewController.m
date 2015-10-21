//
//  AddCardViewController.m
//  Creco
//
//  Created by Windward on 15/5/25.
//  Copyright (c) 2015年 Windward. All rights reserved.
//

#import "AddCardViewController.h"
#import "CardVerifyViewController.h"
#import "ApplyCardViewController.h"
#import "ServerCardObject.h"

@interface AddCardViewController () <UITableViewDataSource, UITableViewDelegate>
{
    NSMutableArray *dataArray;
}
@end

@implementation AddCardViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    self.navigationItem.title = @"カード追加";
    
    UITableView *cardTable = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kAllViewWidth, kAllViewHeight) style:UITableViewStylePlain];
    cardTable.delegate = self;
    cardTable.dataSource = self;
    cardTable.backgroundColor = [UIColor clearColor];
    [self.view addSubview:cardTable];
    
    dataArray = [NSMutableArray arrayWithObject:@"カードをお持ちでない方はこちら"];
    [dataArray addObjectsFromArray:[CardMaster getAllServerCards]];
}

#pragma mark - UITableView DataSource -

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellStr = @"CardCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellStr];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellStr];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        cell.textLabel.font = [UIFont systemFontOfSize:14];
    }
    
    if (indexPath.row == 0)
    {
        cell.backgroundColor = [UIColor lightGrayColor];
        cell.textLabel.textColor = [ShareMethods colorFromHexRGB:@"ffffff"];
        cell.textLabel.text = dataArray[indexPath.row];
    }else
    {
        cell.backgroundColor = [UIColor whiteColor];
        cell.textLabel.textColor = [ShareMethods colorFromHexRGB:@"7e8699"];
        cell.textLabel.text = ((ServerCardObject *)dataArray[indexPath.row]).card_master_name;
    }
    
    return cell;
}

#pragma mark - UITableView Delegate -

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    if (indexPath.row == 0) {
        ApplyCardViewController *applyCardVC = [[ApplyCardViewController alloc] init];
        [self.navigationController pushViewController:applyCardVC animated:YES];
    }else
    {
        CardVerifyViewController *cardVerifyVC = [[CardVerifyViewController alloc] init];
        cardVerifyVC.serverCardObj = dataArray[indexPath.row];
        [self.navigationController pushViewController:cardVerifyVC animated:YES];
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

@end

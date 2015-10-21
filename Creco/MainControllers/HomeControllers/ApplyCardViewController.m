//
//  ApplyCardViewController.m
//  Creco
//
//  Created by Windward on 15/5/25.
//  Copyright (c) 2015年 Windward. All rights reserved.
//

#import "ApplyCardViewController.h"
#import "ServerCardObject.h"
#import "CardMaster.h"
#import "WebViewController.h"

@interface ApplyCardViewController () <UITableViewDataSource, UITableViewDelegate>
{
    NSMutableArray *cardsArray;
}
@end

@implementation ApplyCardViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"カード発行";
    
    UITableView *cardTable = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kAllViewWidth, kAllViewHeight) style:UITableViewStylePlain];
    cardTable.delegate = self;
    cardTable.dataSource = self;
    cardTable.backgroundColor = [UIColor clearColor];
    [self.view addSubview:cardTable];
    
    cardsArray = [CardMaster getAllServerCards];
}

#pragma mark - UITableView DataSource -

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return cardsArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellStr = @"ApplyCardCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellStr];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellStr];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    cell.textLabel.textColor = [ShareMethods colorFromHexRGB:@"7e8699"];
    cell.textLabel.font = [UIFont systemFontOfSize:14];
    cell.textLabel.text = ((ServerCardObject *)cardsArray[indexPath.row]).card_master_name;
    
    UIButton *applyBtn = (UIButton *)[cell.contentView viewWithTag:1988];
    if (!applyBtn) {
        applyBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        applyBtn.tag = 1988;
        UIImage *applyCardImg = [UIImage imageNamed:@"apply_card"];
        applyBtn.frame = CGRectMake(kAllViewWidth-applyCardImg.size.width-10.f, (cell.height-applyCardImg.size.height)/2, applyCardImg.size.width, applyCardImg.size.height);
        [applyBtn setImage:applyCardImg forState:UIControlStateNormal];
        [applyBtn addTarget:self action:@selector(applyCard:) forControlEvents:UIControlEventTouchUpInside];
        [cell.contentView addSubview:applyBtn];
    }
    applyBtn.tag = indexPath.row;
    
    return cell;
}

- (void)applyCard:(UIButton *)applyBtn
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:((ServerCardObject *)cardsArray[applyBtn.tag]).service_url]];
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

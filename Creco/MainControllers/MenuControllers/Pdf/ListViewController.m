//
//  ListViewController.m
//  Creco
//
//  Created by 于　超 on 2015/06/22.
//  Copyright (c) 2015年 Windward. All rights reserved.
//

#import "ListViewController.h"
#import "ConfirmViewController.h"

#define screenWidth            [UIScreen mainScreen].bounds.size.width
#define screenHeight           [UIScreen mainScreen].bounds.size.height

@interface ListViewController () <UITableViewDelegate, UITableViewDataSource> {
    UITableView *pdfTableView;
}

@property (nonatomic, strong) NSMutableArray *monthArray;

@end

@implementation ListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    self.navigationItem.title = @"PDF閲覧";
    self.view.backgroundColor = COLOR_VIEW_OTHER_BACKGROUND;
    
    _monthArray = [NSMutableArray array];
    
    NSMutableDictionary *postDic = [NSMutableDictionary dictionary];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    if ([[NSUserDefaults standardUserDefaults] objectForKey:kDetailApiLastUpdateDate]) {
        NSString *base_date = [formatter stringFromDate:[[NSUserDefaults standardUserDefaults] objectForKey:kDetailApiLastUpdateDate]];
        [postDic setValue:base_date forKey:@"base_date"];
    }
    
    [self performSelector:@selector(getPdfApi:) withObject:postDic afterDelay:0];
    
    int tableHeight = (int)(40*_monthArray.count);
    if (tableHeight > screenHeight-113) {
        tableHeight = screenHeight-113;
    }
    pdfTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, tableHeight)];
    pdfTableView.dataSource = self;
    pdfTableView.delegate = self;
    [self.view addSubview:pdfTableView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// Table Viewのセクション数を指定
- (NSInteger)numberOfSectionsInTableView: (UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _monthArray.count;
}

// セル高さ
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 40;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellStr = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellStr];
    
    NSString *month = [_monthArray objectAtIndex:indexPath.row];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellStr];
        
        UILabel *date = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, 200, 40)];
        date.font = [UIFont fontWithName:@"HiraKakuProN-W3" size:14];
        date.textColor = [UIColor colorWithRed:126/255.0 green:134/255.0 blue:153/255.0 alpha:1.0];
        NSString *result = [month stringByReplacingOccurrencesOfString:@"-0" withString:@"-"];
        NSString *result2 = [result stringByReplacingOccurrencesOfString:@"-" withString:@"年"];
        NSString *dateStr = [NSString stringWithFormat:@"%@%@", result2, @"月"];
        date.text = dateStr;
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(screenWidth-30, 12, 10, 16)];
        imageView.image = [UIImage imageNamed:@"preview"];
        
        [cell.contentView addSubview:date];
        [cell.contentView addSubview:imageView];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES]; // 選択状態の解除
    ConfirmViewController *controller = [[ConfirmViewController alloc] init];
    controller.month = [_monthArray objectAtIndex:indexPath.row];
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)getPdfApi:(NSDictionary *)postDic
{
    [RequestManager requestPath:kGetPDF parameters:nil success:^(AFHTTPRequestOperation *operation, id result) {
        NSMutableArray *pdfList = [Pdf getAllPdf];
        for (PdfObject *obj in pdfList) {
            BOOL addFlg = YES;
            for (NSString *str in _monthArray) {
                if ([obj.date isEqualToString:str]) {
                    addFlg = NO;
                    break;
                }
            }
            if (addFlg) {
                [_monthArray addObject:obj.date];
            }
        }
        
        pdfTableView.frame = CGRectMake(pdfTableView.frame.origin.x, pdfTableView.frame.origin.y, pdfTableView.frame.size.width, _monthArray.count*40);
        [pdfTableView reloadData];
        
        [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:kReviewPDFLastDate];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
    }];
}

@end

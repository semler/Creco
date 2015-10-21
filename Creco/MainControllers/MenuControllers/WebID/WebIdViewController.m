//
//  WebIdViewController.m
//  Creco
//
//  Created by 于　超 on 2015/06/23.
//  Copyright (c) 2015年 Windward. All rights reserved.
//

#import "WebIdViewController.h"
#import "EditWebIdViewController.h"
#import "AddCardViewController.h"

#define screenWidth            [UIScreen mainScreen].bounds.size.width
#define screenHeight           [UIScreen mainScreen].bounds.size.height

@interface WebIdViewController ()<UITableViewDelegate, UITableViewDataSource>{
    UIButton *addCardButton;
    UITableView *cardTableView;
}

@property (strong, nonatomic) NSMutableArray *webServiceList;
@property (nonatomic) float cellHeight;
@property (nonatomic) float tableHeight;

@end

@implementation WebIdViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    self.navigationItem.title = @"WEB ID管理";
    self.view.backgroundColor = COLOR_VIEW_OTHER_BACKGROUND;
    
    addCardButton = [UIButton buttonWithType:UIButtonTypeCustom];
    addCardButton.frame = CGRectMake(0, 0, 27, 21);
    [addCardButton setImage:[UIImage imageTopicNamed:@"btn_cardplus"] forState:UIControlStateNormal];
    [addCardButton addTarget:self action:@selector(addCard) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:addCardButton];
}

-(void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [cardTableView removeFromSuperview];
    
    _webServiceList = [WebId getAllUserWebs];
    for(UserWebObject *obj in _webServiceList) {
        if ([obj.card_code isEqualToString:kAllCardCode]) {
            [_webServiceList removeObject:obj];
            break;
        }
    }
    float tableHeight;
    for (UserWebObject *webObject in _webServiceList) {
        NSMutableArray *cardNameList = [CardMaster getCardMasterNameByServiceCode:webObject.service_code];
        float height = 20*cardNameList.count+40;
        tableHeight += height;
    }
    
    if (tableHeight > screenHeight-113) {
        tableHeight = screenHeight-113;
    }
    
    cardTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, tableHeight)];
    cardTableView.dataSource = self;
    cardTableView.delegate = self;
    
    [self.view addSubview:cardTableView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)addCard {
    AddCardViewController *addCardVC = [[AddCardViewController alloc] init];
    [self.navigationController pushViewController:addCardVC animated:YES];
}

// Table Viewのセクション数を指定
- (NSInteger)numberOfSectionsInTableView: (UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _webServiceList.count;
}

// セル高さ
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    UserWebObject *webObject = [_webServiceList objectAtIndex:indexPath.row];
    NSMutableArray *cardNameList = [CardMaster getCardMasterNameByServiceCode:webObject.service_code];
    float height = 20*cardNameList.count+40;
    
    return height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellStr = @"CardCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellStr];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellStr];
        
        UserWebObject *webObject = [_webServiceList objectAtIndex:indexPath.row];
        
        NSString *serviceName = webObject.service_name;
        if (serviceName == nil || [@"" isEqualToString:serviceName]) {
            serviceName = [CardMaster getServiceNameByServiceCode:webObject.service_code];
        }
        
        UILabel *cardLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 10, 200, 20)];
        cardLabel.font = [UIFont fontWithName:@"HiraKakuProN-W3" size:14];
        cardLabel.textColor = [UIColor colorWithRed:80/255.0 green:80/255.0 blue:80/255.0 alpha:1.0];
        cardLabel.text = serviceName;
        [cell.contentView addSubview:cardLabel];
        
        NSMutableArray *cardNameList = [CardMaster getCardMasterNameByServiceCode:webObject.service_code];
        
        for (int i = 0; i < cardNameList.count; i ++) {
            NSString *cardMasterName = [cardNameList objectAtIndex:i];
            UILabel *subCardLabel = [[UILabel alloc] initWithFrame:CGRectMake(30, 10+20*(i+1), 200, 20)];
            subCardLabel.font = [UIFont fontWithName:@"HiraKakuProN-W3" size:12];
            subCardLabel.textColor = [UIColor colorWithRed:180/255.0 green:180/255.0 blue:180/255.0 alpha:1.0];
            subCardLabel.text = cardMasterName;
            [cell.contentView addSubview:subCardLabel];
        }
        
        float height = 20*cardNameList.count+40;
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(screenWidth-30, (height-16)/2, 10, 16)];
        imageView.image = [UIImage imageNamed:@"preview"];
        [cell.contentView addSubview:imageView];
        
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES]; // 選択状態の解除
    
    UserWebObject *webObject = [_webServiceList objectAtIndex:indexPath.row];
    EditWebIdViewController *controller = [[EditWebIdViewController alloc] init];
    controller.webObject = webObject;
    [self.navigationController pushViewController:controller animated:YES];
}

@end

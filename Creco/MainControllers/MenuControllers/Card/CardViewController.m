//
//  CardViewController.m
//  Creco
//
//  Created by 于　超 on 2015/06/18.
//  Copyright (c) 2015年 Windward. All rights reserved.
//

#import "CardViewController.h"
#import "EditViewController.h"
#import "AddCardViewController.h"

#define screenWidth            [UIScreen mainScreen].bounds.size.width
#define screenHeight           [UIScreen mainScreen].bounds.size.height

@interface CardViewController () <UITableViewDelegate, UITableViewDataSource> {
    UIButton *addCardButton;
    UITableView *cardTableView;
    NSMutableArray *cardsArray;
}
@property (nonatomic) BOOL beginFlg;

@end

@implementation CardViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    self.navigationItem.title = @"カード管理";
    self.view.backgroundColor = COLOR_VIEW_OTHER_BACKGROUND;
 
    addCardButton = [UIButton buttonWithType:UIButtonTypeCustom];
    addCardButton.frame = CGRectMake(0, 0, 27, 21);
    [addCardButton setImage:[UIImage imageTopicNamed:@"btn_cardplus"] forState:UIControlStateNormal];
    [addCardButton addTarget:self action:@selector(addCard) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:addCardButton];
    
    cardsArray = [Entry getAllUserCards];
    int tableHeight = (int)(40*cardsArray.count);
    if (tableHeight > screenHeight-113) {
        tableHeight = screenHeight-113;
    }
    cardTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, tableHeight)];
    
    [cardTableView setEditing:YES animated:YES];
    cardTableView.allowsSelectionDuringEditing=YES;
    cardTableView.dataSource = self;
    cardTableView.delegate = self;
    
    [self.view addSubview:cardTableView];
}

-(void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    cardsArray = [Entry getAllUserCards];
    [cardTableView reloadData];
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
    return cardsArray.count;
}

// セル高さ
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 40;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellStr = @"CardCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellStr];
//    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellStr];
        UserCardObject *userCardObject = [cardsArray objectAtIndex:indexPath.row];
        
        if ([userCardObject.card_code isEqualToString:kAllCardCode]) {
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        } else {
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(-23, 12, 16, 16)];
            imageView.image = [UIImage imageNamed:@"btn_right.png"];
            [cell.contentView addSubview:imageView];
        }
        UILabel *card = [[UILabel alloc] initWithFrame:CGRectMake(7, 0, 200, 40)];
        card.text = userCardObject.card_name;
        [cell.contentView addSubview:card];
//    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES]; // 選択状態の解除
    UserCardObject *userCardObject = [cardsArray objectAtIndex:indexPath.row];
    if ([userCardObject.card_code isEqualToString:kAllCardCode]) {
        return;
    }
    EditViewController *controller = [[EditViewController alloc] init];
    controller.userCardObject = userCardObject;
    [self.navigationController pushViewController:controller animated:YES];
}

//先要设Cell可编辑
-(BOOL)tableView:(UITableView *) tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    //打开编辑
    return YES;
}

//定义编辑样式
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView setEditing:YES animated:YES];
    return UITableViewCellEditingStyleNone;
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    //允许移动
    return YES;
}

-(void) tableView: (UITableView *) tableView moveRowAtIndexPath: (NSIndexPath *) oldPath toIndexPath:(NSIndexPath *) newPath
{
    int old = (int)oldPath.row;
    int new = (int)newPath.row;
    UserCardObject *cardObject = [cardsArray objectAtIndex:old];
    [Entry updateUserCardByCard_code:cardObject.card_code seq:new];
    
    if (new > old) {
        for (int i = old+1; i <= new; i ++) {
            UserCardObject *cardObject = [cardsArray objectAtIndex:i];
            [Entry updateUserCardByCard_code:cardObject.card_code seq:(cardObject.card_seq-1)];
        }
    } else if (old > new) {
        for (int i = old-1; i >= new; i --) {
            UserCardObject *cardObject = [cardsArray objectAtIndex:i];
            [Entry updateUserCardByCard_code:cardObject.card_code seq:(cardObject.card_seq+1)];
        }
    }
    cardsArray = [Entry getAllUserCards];
    
    [kAppDelegate.appTabBarVC.homeVC reloadData];
}



@end

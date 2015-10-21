//
//  ColorViewController.m
//  Creco
//
//  Created by 于　超 on 2015/06/18.
//  Copyright (c) 2015年 Windward. All rights reserved.
//

#import "ColorViewController.h"
#import "CardManager.h"
#define screenWidth            [UIScreen mainScreen].bounds.size.width
#define screenHeight           [UIScreen mainScreen].bounds.size.height

@interface ColorViewController () {
    UIImageView *card;
    UIImageView *check;
}


@end

@implementation ColorViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    self.navigationItem.title = @"カードカラー選択";
    self.view.backgroundColor = COLOR_VIEW_OTHER_BACKGROUND;
    
    UIView *cardView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight-358)];
    UIImageView *bg = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight-358)];
    bg.image = [UIImage imageNamed:@"home_bg.png"];
    card = [[UIImageView alloc] initWithFrame:CGRectMake((screenWidth-255)/2, (screenHeight-358-160)/2, 255, 160)];
    NSString *name = [NSString stringWithFormat:@"card%d_big.png", [CardManager sharedManager].index+1];
    card.image = [UIImage imageNamed:name];
    [cardView addSubview:bg];
    [cardView addSubview:card];
    
    UIView *colorView = [[UIView alloc] initWithFrame:CGRectMake(17.5, screenHeight-358+15, screenWidth-35, 210)];
    colorView.backgroundColor = [UIColor whiteColor];
    
    check = [[UIImageView alloc] initWithFrame:CGRectMake(-100, -100, 34, 26)];
    check.image = [UIImage imageNamed:@"check.png"];
    check.contentMode = UIViewContentModeCenter;

    float space = (screenWidth-35-240)/3;
    for (int i = 0; i < 12; i ++) {
        if (i <= 3) {
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            button.frame = CGRectMake((60+space)*i, 0, 60, 60);
            button.tag = i;
            button.backgroundColor = [ShareMethods colorFromHexRGB:[[CardManager sharedManager].colorArray objectAtIndex:i]];
            [button addTarget:self action:@selector(select:) forControlEvents:UIControlEventTouchUpInside];
            [colorView addSubview:button];
            
            if ([CardManager sharedManager].index == i) {
                check.frame = button.frame;
            }
        }
        if (i > 3 && i <= 7) {
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            button.frame = CGRectMake((60+space)*(i-4), 75, 60, 60);
            button.tag = i;
            button.backgroundColor = [ShareMethods colorFromHexRGB:[[CardManager sharedManager].colorArray objectAtIndex:i]];
            [button addTarget:self action:@selector(select:) forControlEvents:UIControlEventTouchUpInside];
            [colorView addSubview:button];
            
            if ([CardManager sharedManager].index == i) {
                check.frame = button.frame;
            }
        }
        else if (i > 7 && i <= 11) {
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            button.frame = CGRectMake((60+space)*(i-8), 150, 60, 60);
            button.tag = i;
            button.backgroundColor = [ShareMethods colorFromHexRGB:[[CardManager sharedManager].colorArray objectAtIndex:i]];
            [button addTarget:self action:@selector(select:) forControlEvents:UIControlEventTouchUpInside];
            [colorView addSubview:button];
            
            if ([CardManager sharedManager].index == i) {
                check.frame = button.frame;
            }
        }
    }
    [colorView addSubview:check];
    
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:cardView];
    [self.view addSubview:colorView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) select:(id)sender {
    UIButton *button = (UIButton *)sender;
    
    NSString *imageName = [NSString stringWithFormat:@"card%d_big.png", (int)button.tag+1];
    card.image = [UIImage imageNamed:imageName];
    check.frame = button.frame;
    
    NSLog(@"%d", (int)button.tag);
    [CardManager sharedManager].index = (int)button.tag;
    [CardManager sharedManager].color = [[CardManager sharedManager].colorArray objectAtIndex:[CardManager sharedManager].index];
}

@end

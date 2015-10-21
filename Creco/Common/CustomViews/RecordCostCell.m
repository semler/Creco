//
//  RecordCostCell.m
//  Creco
//
//  Created by Windward on 15/6/7.
//  Copyright (c) 2015年 Windward. All rights reserved.
//

#import "RecordCostCell.h"
#import "Entry.h"
#import "UserCardObject.h"

@protocol TouchDetailCostViewDelegate <NSObject>
- (void)touchTheDetailCostViewWith:(DetailCostObject *)detailCostObj;
@end

@interface RecordCostView : UIView
@property (nonatomic, strong) UILabel *cardLabel;
@property (nonatomic, strong) UILabel *moneyLabel;
@property (nonatomic, strong) UILabel *placeLabel;
@property (nonatomic, strong) DetailCostObject *nowDetailCostObj;
@property (nonatomic, assign) id <TouchDetailCostViewDelegate> delegate;
@end

@implementation RecordCostView

- (id)initWithFrame:(CGRect)frame andDetailCostObject:(DetailCostObject *)detailCostObj
{
    if (self = [super initWithFrame:frame])
    {
        self.nowDetailCostObj = detailCostObj;
        
        UILabel *lineLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 10.f, 1.f, self.height-20.f)];
        lineLabel.backgroundColor = [[UIColor grayColor] colorWithAlphaComponent:0.3f];
        [self addSubview:lineLabel];
        
        UIImageView *firstImageView = nil;
        for (int i = 0; i < 2; i ++)
        {
            UIImage *image = nil;
            switch (i) {
                case 0:
                    image = [UIImage imageTopicNamed:@"card_icon"];
                    break;
                case 1:
                    image = [UIImage imageTopicNamed:@"place_icon"];
                    break;
                default:
                    break;
            }
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(10.f, 15.f+(image.size.height+8.f)*i, image.size.width, image.size.height)];
            imageView.userInteractionEnabled = YES;
            imageView.image = image;
            [self addSubview:imageView];
            
            UILabel *middleLabel = [[UILabel alloc] initWithFrame:CGRectMake(imageView.right+10.f, imageView.top, self.width-imageView.right-40.f, imageView.height)];
            middleLabel.font = [UIFont systemFontOfSize:14];
            middleLabel.textColor = [ShareMethods colorFromHexRGB:@"7e8699"];
            [self addSubview:middleLabel];
            
            UILabel *rightLabel = [[UILabel alloc] init];
            [self addSubview:rightLabel];
            
            switch (i) {
                case 0:
                {
                    firstImageView = imageView;
                    
                    UserCardObject *userCardObj = [Entry getUserCardObjectByService_code:nil andCard_code:detailCostObj.card_code];
                    if (!userCardObj && [Entry getAllUserCards].count == 1)
                        userCardObj = [SampleCard getUserCardObjectByCard_code:detailCostObj.card_code];
                    middleLabel.text = userCardObj.card_name;
                    
                    rightLabel.frame = CGRectMake(self.width-20.f-60.f, imageView.top, 60.f, imageView.height);
                    middleLabel.frame = CGRectMake(firstImageView.right+10.f, middleLabel.top, rightLabel.left-firstImageView.right-20.f, middleLabel.height);
                    rightLabel.font = middleLabel.font;
                    rightLabel.textColor = middleLabel.textColor;
                    rightLabel.textAlignment = NSTextAlignmentRight;
                    NSString *changedPrice = [ShareMethods moneyStrToDecimal:detailCostObj.price];
                    rightLabel.text = [NSString stringWithFormat:@"￥%@", changedPrice];
                }
                    break;
                case 1:
                    imageView.center = CGPointMake(firstImageView.center.x, imageView.center.y);
                    
                    middleLabel.frame = CGRectMake(firstImageView.right+10.f, middleLabel.top, self.width-firstImageView.right-40.f, middleLabel.height);
                    middleLabel.text = detailCostObj.name;
                    
                    if (detailCostObj.note.length > 0) {
                        rightLabel.frame = CGRectMake(self.width-20.f-6.f, middleLabel.top+6.f, 6.f, 6.f);
                        rightLabel.backgroundColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.6f];
                        rightLabel.layer.cornerRadius = 3.f;
                        rightLabel.clipsToBounds = YES;
                    }
                    break;
                default:
                    break;
            }
        }
    }
    return self;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    self.backgroundColor = [ShareMethods colorFromHexRGB:@"f5f8ff"];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    self.backgroundColor = [UIColor whiteColor];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    self.backgroundColor = [UIColor whiteColor];
    if (self.delegate && [self.delegate respondsToSelector:@selector(touchTheDetailCostViewWith:)])
        [self.delegate touchTheDetailCostViewWith:self.nowDetailCostObj];
}

@end

@interface RecordCostCell () <TouchDetailCostViewDelegate>
{
    UILabel *dateLabel;
    UILabel *lineLabel;
}
@end

@implementation RecordCostCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        CGFloat padding = 70.f;
        dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 15.f, padding, 12.f)];
        dateLabel.text = @"1日";
        dateLabel.font = [UIFont systemFontOfSize:14];
        dateLabel.textColor = [ShareMethods colorFromHexRGB:@"505050"];
        dateLabel.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:dateLabel];
        
        lineLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, kEveryRecordCostHeght-0.5f, kAllViewWidth, 0.5f)];
        lineLabel.backgroundColor = COLOR_LINE;
        [self.contentView addSubview:lineLabel];
    }
    return self;
}

- (void)reloadDataBy:(NSArray *)everydayCostsArray
{
    if (everydayCostsArray.count > 0)
    {
        for (UIView *recordCostView in self.contentView.subviews)
            [recordCostView removeFromSuperview];
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSDate *costDate = [formatter dateFromString:((DetailCostObject *)everydayCostsArray[0]).date];
        NSCalendar *calendar = [NSCalendar currentCalendar];
        NSDateComponents *dateComponents = [calendar components:NSCalendarUnitDay fromDate:costDate];
        dateLabel.text = [NSString stringWithFormat:@"%ld日", dateComponents.day];
        
        for (int i = 0; i < everydayCostsArray.count; i ++)
        {
            DetailCostObject *detailCostObj = everydayCostsArray[i];
            
            RecordCostView *recordCostView = [[RecordCostView alloc] initWithFrame:CGRectMake(dateLabel.right, i*kEveryRecordCostHeght, kAllViewWidth-dateLabel.right, kEveryRecordCostHeght) andDetailCostObject:detailCostObj];
            recordCostView.delegate = self;
            [self.contentView addSubview:recordCostView];
            
            if (i != everydayCostsArray.count-1) {
                UILabel *recordLineLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, kEveryRecordCostHeght-0.5f, recordCostView.width, 0.5f)];
                recordLineLabel.backgroundColor = COLOR_LINE;
                [recordCostView addSubview:recordLineLabel];
            }
        }
        
        lineLabel.frame = CGRectMake(0, everydayCostsArray.count*kEveryRecordCostHeght-0.5f, kAllViewWidth, 0.5f);
        [self.contentView addSubview:dateLabel];
        [self.contentView addSubview:lineLabel];
    }
}

#pragma mark - TouchDetailCostViewDelegate -

- (void)touchTheDetailCostViewWith:(DetailCostObject *)detailCostObj
{
    if (self.clickDelegate && [self.clickDelegate respondsToSelector:@selector(clickTheDetailCostViewWith:)])
        [self.clickDelegate clickTheDetailCostViewWith:detailCostObj];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end

//
//  CalendarView.m
//  Creco
//
//  Created by 于　超 on 2015/05/25.
//  Copyright (c) 2015年 Windward. All rights reserved.
//

#import "CalendarView.h"
#import "UIImageView+WebCache.h"
#import "CalendarManager.h"

#define screenWidth            [UIScreen mainScreen].bounds.size.width
#define screenHeight           [UIScreen mainScreen].bounds.size.height

@interface CalendarView()

// Gregorian calendar
@property (nonatomic, strong) NSCalendar *gregorian;

// Selected day
@property (nonatomic, strong) NSDate * selectedDate;

// Width in point of a day button
@property (nonatomic, assign) NSInteger dayWidth;
// Width in point of a day button
@property (nonatomic, assign) NSInteger dayHeight;

// NSCalendarUnit for day, month, year and era.
@property (nonatomic, assign) NSCalendarUnit dayInfoUnits;

// Array of label of weekdays
@property (nonatomic, strong) NSArray * weekDayNames;

// View shake
@property (nonatomic, assign) NSInteger shakes;
@property (nonatomic, assign) NSInteger shakeDirection;

// Gesture recognizers
@property (nonatomic, strong) UISwipeGestureRecognizer * swipeleft;
@property (nonatomic, strong) UISwipeGestureRecognizer * swipeRight;

@end
@implementation CalendarView

#pragma mark - Init methods

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        _dayWidth                   = frame.size.width/4;
        _dayHeight                  = _dayWidth;
        _originX                    = 0;
        _gregorian                  = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
        _originY                    = 45;
        //_calendarDate               = [NSDate date];
        _dayInfoUnits               = NSEraCalendarUnit | NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit;
        
        _monthAndDayTextColor       = [ShareMethods colorFromHexRGB:@"2045a1"];
        _dayBgColorWithoutData      = [UIColor whiteColor];
        _dayBgColorWithData         = [UIColor whiteColor];
        _dayBgColorSelected         = [UIColor brownColor];
        
        _dayTxtColorWithoutData     = [UIColor brownColor];;
        _dayTxtColorWithData        = [UIColor brownColor];
        _dayTxtColorSelected        = [UIColor whiteColor];
        
        _borderColor                = [UIColor lightGrayColor];
        _allowsChangeMonthByDayTap  = NO;
        _allowsChangeMonthByButtons = YES;
        _allowsChangeMonthBySwipe   = YES;
        _hideMonthLabel             = NO;
        _keepSelDayWhenMonthChange  = NO;
        
        _nextMonthAnimation         = UIViewAnimationOptionTransitionCrossDissolve;
        _prevMonthAnimation         = UIViewAnimationOptionTransitionCrossDissolve;
        
        _defaultFont                = [UIFont fontWithName:@"HelveticaNeue" size:15.0f];
        
        _swipeleft = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(showNextMonth)];
        _swipeleft.direction=UISwipeGestureRecognizerDirectionLeft;
        [self addGestureRecognizer:_swipeleft];
        _swipeRight = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(showPreviousMonth)];
        _swipeRight.direction=UISwipeGestureRecognizerDirectionRight;
        [self addGestureRecognizer:_swipeRight];
        
        NSDateComponents *components = [_gregorian components:_dayInfoUnits fromDate:[NSDate date]];
        components.hour         = 0;
        components.minute       = 0;
        components.second       = 0;
        
        _selectedDate = [_gregorian dateFromComponents:components];
        
        _weekDayNames  = @[@"S", @"M", @"T", @"W", @"T", @"F", @"S"];
        
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

#pragma mark - Public methods

-(void)showNextMonth
{
    NSDateComponents *components = [_gregorian components:_dayInfoUnits fromDate:_calendarDate];
    components.day = 1;
    components.month ++;
    NSDate * nextMonthDate =[_gregorian dateFromComponents:components];
    
    if ([self canSwipeToDate:nextMonthDate])
    {
        [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
        _calendarDate = nextMonthDate;
        components = [_gregorian components:_dayInfoUnits fromDate:_calendarDate];
        
        if (!_keepSelDayWhenMonthChange)
        {
            _selectedDate = [_gregorian dateFromComponents:components];
        }
        [self performViewAnimation:_nextMonthAnimation];
    }
    else
    {
        [self performViewNoSwipeAnimation];
    }
}


-(void)showPreviousMonth
{
    NSDateComponents *components = [_gregorian components:_dayInfoUnits fromDate:_calendarDate];
    components.day = 1;
    components.month --;
    NSDate * prevMonthDate = [_gregorian dateFromComponents:components];
    
    if ([self canSwipeToDate:prevMonthDate])
    {
        [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
        _calendarDate = prevMonthDate;
        components = [_gregorian components:_dayInfoUnits fromDate:_calendarDate];
        
        if (!_keepSelDayWhenMonthChange)
        {
            _selectedDate = [_gregorian dateFromComponents:components];
        }
        [self performViewAnimation:_prevMonthAnimation];
    }
    else
    {
        [self performViewNoSwipeAnimation];
    }
}

#pragma mark - Various methods


-(NSInteger)buttonTagForDate:(NSDate *)date
{
    NSDateComponents * componentsDate       = [_gregorian components:_dayInfoUnits fromDate:date];
    NSDateComponents * componentsDateCal    = [_gregorian components:_dayInfoUnits fromDate:_calendarDate];
    
    if (componentsDate.month == componentsDateCal.month && componentsDate.year == componentsDateCal.year)
    {
        // Both dates are within the same month : buttonTag = day
        return componentsDate.day;
    }
    else
    {
        //  buttonTag = deltaMonth * 40 + day
        NSInteger offsetMonth =  (componentsDate.year - componentsDateCal.year)*12 + (componentsDate.month - componentsDateCal.month);
        return componentsDate.day + offsetMonth*40;
    }
}

-(BOOL)canSwipeToDate:(NSDate *)date
{
    if (_datasource == nil)
        return YES;
    return [_datasource canSwipeToDate:date];
}

-(void)performViewAnimation:(UIViewAnimationOptions)animation
{
    [UIView transitionWithView:self
                      duration:0.5f
                       options:animation
                    animations:^ { [self setNeedsDisplay]; }
                    completion:nil];
}

-(void)performViewNoSwipeAnimation
{
    _shakeDirection = 1;
    _shakes = 0;
    [self shakeView:self];
}

// Taken from http://github.com/kosyloa/PinPad
-(void)shakeView:(UIView *)theOneYouWannaShake
{
    [UIView animateWithDuration:0.05 animations:^
     {
         theOneYouWannaShake.transform = CGAffineTransformMakeTranslation(5*_shakeDirection, 0);
         
     } completion:^(BOOL finished)
     {
         if(_shakes >= 4)
         {
             theOneYouWannaShake.transform = CGAffineTransformIdentity;
             return;
         }
         _shakes++;
         _shakeDirection = _shakeDirection * -1;
         [self shakeView:theOneYouWannaShake];
     }];
}

#pragma mark - Button creation and configuration

-(UIButton *)dayButtonWithFrame:(CGRect)frame
{
    UIButton *button                = [UIButton buttonWithType:UIButtonTypeCustom];
    button.titleLabel.font          = _defaultFont;
    button.frame                    = frame;
    button.layer.borderColor        = _borderColor.CGColor;
//    [button     addTarget:self action:@selector(tappedDate:) forControlEvents:UIControlEventTouchUpInside];
    return button;
}

-(void)configureDayButton:(UIButton *)button withDate:(NSDate*)date
{
    button.tag = [self buttonTagForDate:date];
    button.layer.borderWidth = 0.5;
    button.layer.borderColor = [[UIColor colorWithRed:0.863 green:0.863 blue:0.863 alpha:0.9] CGColor];
}

#pragma mark - Action methods

-(IBAction)tappedDate:(UIButton *)sender
{
    NSDateComponents *components = [_gregorian components:_dayInfoUnits fromDate:_calendarDate];
    
    // Day taped within the the displayed month
    NSDateComponents * componentsDateSel = [_gregorian components:_dayInfoUnits fromDate:_selectedDate];
    
    // Let's keep a backup of the old selectedDay
    NSDate * oldSelectedDate = [_selectedDate copy];
        
    // We redifine the selected day
    componentsDateSel.day       = sender.tag;
    componentsDateSel.month     = components.month;
    componentsDateSel.year      = components.year;
    _selectedDate               = [_gregorian dateFromComponents:componentsDateSel];
        
    // Configure  the new selected day button
    [self configureDayButton:sender             withDate:_selectedDate];
        
    // Configure the previously selected button, if it's visible
    UIButton *previousSelected =(UIButton *) [self viewWithTag:[self buttonTagForDate:oldSelectedDate]];
    if (previousSelected) {
        [self configureDayButton:previousSelected   withDate:oldSelectedDate];
        
        // Finally, notify the delegate
        [_delegate dayChangedToDate:_selectedDate];
    }
}


#pragma mark - Drawing methods

- (void)drawRect:(CGRect)rect
{
    [CalendarManager sharedManager].calendarDate = _calendarDate;
    
    NSDateComponents *components = [_gregorian components:_dayInfoUnits fromDate:_calendarDate];
    
    components.day = 1;
    NSDate *firstDayOfMonth         = [_gregorian dateFromComponents:components];
    NSDateComponents *comps         = [_gregorian components:NSWeekdayCalendarUnit fromDate:firstDayOfMonth];
    
    // 当月第一天的曜日 日曜日=1 月曜日=2
    int weekDay = (int)[comps weekday];
    
    NSInteger weekdayBeginning      = [comps weekday];  // Starts at 1 on Sunday
    weekdayBeginning = 0;
    
    NSRange days = [_gregorian rangeOfUnit:NSDayCalendarUnit
                                    inUnit:NSMonthCalendarUnit
                                   forDate:_calendarDate];
    
    NSInteger monthLength = days.length;
    NSInteger remainingDays = (monthLength + weekdayBeginning) % 4;
    
    
    // Frame drawing
//    NSInteger minY = _originY;
    NSInteger maxY = _originY + _dayHeight * (NSInteger)((monthLength+weekdayBeginning)/4) + ((remainingDays !=0)? _dayHeight:0);
    
    if (_delegate != nil && [_delegate respondsToSelector:@selector(setHeightNeeded:)]) {
        [_delegate setHeightNeeded:maxY];
    }
    
    BOOL enableNext = YES;
    BOOL enablePrev = YES;
    
    // Previous and next button
    _buttonPrev          = [[UIButton alloc] initWithFrame:CGRectMake(40, 0, _originY, _originY)];
    [_buttonPrev setImage:[UIImage imageTopicNamed:@"btn_back_cal"] forState:UIControlStateNormal];
    [_buttonPrev addTarget:self action:@selector(showPreviousMonth) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_buttonPrev];
    
    _buttonNext          = [[UIButton alloc] initWithFrame:CGRectMake(screenWidth-40-_originY, 0, _originY, _originY)];
    [_buttonNext setImage:[UIImage imageTopicNamed:@"btn_next_cal"] forState:UIControlStateNormal];
    [_buttonNext addTarget:self action:@selector(showNextMonth) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_buttonNext];
    
    NSDateComponents *componentsTmp = [_gregorian components:_dayInfoUnits fromDate:_calendarDate];
    componentsTmp.day = 1;
    componentsTmp.month --;
    NSDate * prevMonthDate =[_gregorian dateFromComponents:componentsTmp];
    if (![self canSwipeToDate:prevMonthDate])
    {
        _buttonPrev.alpha    = 0.5f;
        _buttonPrev.enabled  = NO;
        enablePrev          = NO;
    }
    componentsTmp.month +=2;
    NSDate * nextMonthDate =[_gregorian dateFromComponents:componentsTmp];
    if (![self canSwipeToDate:nextMonthDate])
    {
        _buttonNext.alpha    = 0.5f;
        _buttonNext.enabled  = NO;
        enableNext          = NO;
    }
    if (!_allowsChangeMonthByButtons)
    {
        _buttonNext.hidden = YES;
        _buttonPrev.hidden = YES;
    }
    if (_delegate != nil && [_delegate respondsToSelector:@selector(setEnabledForPrevMonthButton:nextMonthButton:)])
        [_delegate setEnabledForPrevMonthButton:enablePrev nextMonthButton:enableNext];
    
    // Month label
    NSDateFormatter *format         = [[NSDateFormatter alloc] init];
    [format setDateFormat:@"YYYY年 MMMM"];
    NSString *dateString            = [[format stringFromDate:_calendarDate] uppercaseString];
    
    if (!_hideMonthLabel)
    {
        _titleText              = [[UILabel alloc]initWithFrame:CGRectMake(0,0, self.bounds.size.width, _originY)];
        _titleText.textAlignment         = NSTextAlignmentCenter;
        _titleText.text                  = dateString;
        _titleText.textColor = [ShareMethods colorFromHexRGB:[[NSUserDefaults standardUserDefaults] valueForKey:kAppTopicColor]];
        _titleText.font = [UIFont fontWithName:@"HiraKakuProN-W6" size:16];
        [self addSubview:_titleText];
    }
    
    if (_delegate != nil && [_delegate respondsToSelector:@selector(setMonthLabel:)])
        [_delegate setMonthLabel:dateString];
    
    // Current month
    for (NSInteger i= 0; i<monthLength; i++)
    {
        components.day      = i+1;
        
        // 詳細取得
        NSMutableArray *detailDayArray;
        DetailCostObject *detailCostObject;
        
        NSDateFormatter *pFormat = [[NSDateFormatter alloc] init];
        [pFormat setDateFormat:@"yyyy-MM-dd"];
        NSString *pDate = [pFormat stringFromDate:[_gregorian dateFromComponents:components]];
        
        NSMutableArray *cardsArray = [Entry getAllUserCards];
        BOOL isSample;
        if (cardsArray.count > 1)
        {
            detailDayArray = [Details getDetailCostsByDate:pDate];
            isSample = NO;
        }else
        {
            detailDayArray = [SampleCard getSampleCardCostsByDate:pDate];
            isSample = YES;
        }
        
        if (detailDayArray.count > 0) {
            for (int i = 0; i < detailDayArray.count-1; i ++) {
                DetailCostObject *detail = [detailDayArray objectAtIndex:i];
                DetailCostObject *detail2 = [detailDayArray objectAtIndex:i+1];
                if ([detail.price intValue]>= [detail2.price intValue]) {
                    [detailDayArray exchangeObjectAtIndex:i+1 withObjectAtIndex:i];
                }
            }
            detailCostObject = [detailDayArray objectAtIndex:[detailDayArray count]-1];
        } else {
            //
        }
        
        NSInteger offsetX   = (_dayWidth*((i+weekdayBeginning)%4));
        NSInteger offsetY   = (_dayHeight *((i+weekdayBeginning)/4));
        
        UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(_originX+offsetX, _originY+offsetY, _dayWidth, _dayHeight)];
        
        // 曜日
        UILabel *week = [[UILabel alloc] initWithFrame:CGRectMake(0, _dayHeight*0.1, _dayWidth, _dayHeight*0.9)];
        week.font = [UIFont fontWithName:@"HelveticaNeue-Thin" size:22];
        week.text = [_weekDayNames objectAtIndex:(weekDay-1+i)%7];
        week.textAlignment = NSTextAlignmentCenter;
        if ((weekDay-1+i)%7 == 0) {
            week.textColor = [UIColor colorWithRed:1 green:0.824 blue:0.824 alpha:0.9];
        } else if ((weekDay-1+i)%7 == 6) {
            week.textColor = [UIColor colorWithRed:0.706 green:0.898 blue:1 alpha:0.9];
        } else {
            week.textColor = [UIColor colorWithRed:0.863 green:0.863 blue:0.863 alpha:0.9];
        }
        
        UIImageView *image = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, _dayWidth, _dayHeight)];
        [image setContentMode:UIViewContentModeScaleAspectFill];
        image.clipsToBounds = YES;
        if (detailCostObject != nil) {
            image.hidden = NO;
            
            if (isSample) {
                if (detailCostObject.picture1 != nil) {
                    NSString *str = detailCostObject.picture1;
                    NSData *data = [[NSData alloc] initWithBase64EncodedString:str options:NSDataBase64DecodingIgnoreUnknownCharacters];
                    UIImage* imageData = [UIImage imageWithData:data];
                    image.image = imageData;
                } else {
                    image.image = [UIImage imageNamed:@"box_noimage"];
                }
            } else {
                NSString *code = detailCostObject.code;
                
                NSString *year = [detailCostObject.date substringWithRange:NSMakeRange(0,4)];
                NSString *month = [detailCostObject.date substringWithRange:NSMakeRange(5,2)];
                NSString *day = [detailCostObject.date substringWithRange:NSMakeRange(8,2)];
                NSString *hour = [detailCostObject.date substringWithRange:NSMakeRange(11,2)];
                NSString *minute = [detailCostObject.date substringWithRange:NSMakeRange(14,2)];
                NSString *second = [detailCostObject.date substringWithRange:NSMakeRange(17,2)];
                NSString *time = [NSString stringWithFormat:@"%@%@%@%@%@%@", year, month, day, hour, minute, second];
                
                NSString *path;
                if (detailCostObject.bestshot == 1) {
                    path = [NSString stringWithFormat:@"%@/%@%@%@", [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"], time, code, @"_1.jpg"];
                } else if (detailCostObject.bestshot == 2) {
                    path = [NSString stringWithFormat:@"%@/%@%@%@", [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"], time, code, @"_2.jpg"];
                } else if (detailCostObject.bestshot == 3) {
                    path = [NSString stringWithFormat:@"%@/%@%@%@", [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"], time, code, @"_3.jpg"];
                } else {
                    path = [NSString stringWithFormat:@"%@/%@%@%@", [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"], time, code, @"_1.jpg"];
                }
                UIImage *savedImage = [UIImage imageWithContentsOfFile:path];
                
                if (savedImage != nil) {
                    image.image = savedImage;
                } else {
                    image.image = [UIImage imageNamed:@"box_noimage"];
                }
            }
        } else {
            image.hidden = YES;
        }
        
        UIView *topImage = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _dayWidth, _dayHeight*0.2)];
        topImage.alpha = 0.5;
        if ((weekDay-1+i)%7 == 0) {
            topImage.backgroundColor = [UIColor colorWithRed:1 green:0.824 blue:0.824 alpha:0.9];
        } else if ((weekDay-1+i)%7 == 6) {
            topImage.backgroundColor = [UIColor colorWithRed:0.706 green:0.898 blue:1 alpha:0.9];
        } else {
            topImage.backgroundColor = [UIColor colorWithRed:0.863 green:0.863 blue:0.863 alpha:0.9];
        }
        
        UIView *topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _dayWidth, _dayHeight*0.2)];
        topView.backgroundColor = [UIColor clearColor];
        
        UILabel *dayLabel;
        if (components.day < 10) {
            dayLabel = [[UILabel alloc] initWithFrame:CGRectMake(2, 0, _dayWidth*0.1, _dayHeight*0.2)];
        } else {
            dayLabel = [[UILabel alloc] initWithFrame:CGRectMake(2, 0, _dayWidth*0.2, _dayHeight*0.2)];
        }
        // 日
        dayLabel.font = [UIFont fontWithDescriptor:[UIFontDescriptor fontDescriptorWithName:@"HelveticaNeue-Italic" size:10] size:10];
        dayLabel.text = [NSString stringWithFormat:@"%ld",(long)components.day];
        dayLabel.textAlignment = NSTextAlignmentCenter;
        dayLabel.backgroundColor = [UIColor clearColor];
        dayLabel.textColor = [UIColor blackColor];
        UILabel *weekLabel;
        if (components.day < 10) {
            weekLabel = [[UILabel alloc] initWithFrame:CGRectMake(_dayWidth*0.1+2, 0, _dayWidth*0.2, _dayWidth*0.2)];
        } else {
            weekLabel = [[UILabel alloc] initWithFrame:CGRectMake(_dayWidth*0.2+2, 0, _dayWidth*0.2, _dayWidth*0.2)];
        }
        // 曜日
        weekLabel.font = [UIFont fontWithDescriptor:[UIFontDescriptor fontDescriptorWithName:@"HelveticaNeue-Italic" size:10] size:10];
        if (detailCostObject != nil) {
            weekLabel.text = [_weekDayNames objectAtIndex:(weekDay-1+i)%7];
        }
        weekLabel.textAlignment = NSTextAlignmentLeft;
        weekLabel.backgroundColor = [UIColor clearColor];
        weekLabel.textColor = [UIColor blackColor];
        // 金額
        UILabel *moneyLabel = [[UILabel alloc] initWithFrame:CGRectMake(_dayWidth*0.4, 0, _dayWidth*0.6-2, _dayHeight*0.2)];
        moneyLabel.font = [UIFont fontWithDescriptor:[UIFontDescriptor fontDescriptorWithName:@"HelveticaNeue-Italic" size:10] size:10];
        // 数値を3桁ごとカンマ区切り形式で文字列に変換する
        NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
        [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
        [formatter setGroupingSeparator:@","];
        [formatter setGroupingSize:3];
        
        int price = 0;
        for (DetailCostObject *obj in detailDayArray) {
            price += [obj.price integerValue];
        }
        if (detailCostObject != nil) {
            NSString *result = [formatter stringFromNumber:[NSNumber numberWithInt:price]];
            moneyLabel.text = [NSString stringWithFormat:@"¥%@", result];
        }
        moneyLabel.textAlignment = NSTextAlignmentRight;
        moneyLabel.backgroundColor = [UIColor clearColor];
        moneyLabel.textColor = [UIColor blackColor];
        [topView addSubview:dayLabel];
        [topView addSubview:weekLabel];
        [topView addSubview:moneyLabel];
        
        UIImageView *today = [[UIImageView alloc] initWithFrame:CGRectMake(_dayWidth*0.75, _dayHeight*0.75, _dayWidth*0.25, _dayHeight*0.25)];
        today.image = [UIImage imageTopicNamed:@"icon_today"];
        NSDateFormatter *format = [[NSDateFormatter alloc] init];
        [format setDateFormat:@"YYYY-MM-dd"];
        NSString *now = [format stringFromDate:[NSDate date]];
        NSString *date = [format stringFromDate:[_gregorian dateFromComponents:components]];
        if ([now isEqualToString:date]) {
            today.hidden = NO;
        } else {
            today.hidden = YES;
        }
        
        [contentView addSubview:week];
        [contentView addSubview:image];
        [contentView addSubview:topImage];
        [contentView addSubview:topView];
        [contentView addSubview:today];
        [self addSubview:contentView];
        
        UIButton *button = [self dayButtonWithFrame:CGRectMake(_originX+offsetX-0.25, _originY+offsetY-0.25, _dayWidth+0.5, _dayWidth+0.5)];
        [self configureDayButton:button withDate:[_gregorian dateFromComponents:components]];
        button.backgroundColor = [UIColor clearColor];
        if (detailDayArray.count > 0) {
            [button     addTarget:self action:@selector(tappedDate:) forControlEvents:UIControlEventTouchUpInside];
        }
        [self addSubview:button];
    }
}


@end


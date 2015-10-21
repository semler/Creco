//
//  AppCommon.h
//
//  Created by Windward on 14-4-3.
//  Copyright (c) 2013年 Windward. All rights reserved.
//

//When debug, then log
#ifdef DEBUG
#define TDLog(format, ...)  NSLog(format, ## __VA_ARGS__)
#else
#define TDLog(format, ...)
#endif

#import "AppConfig.h"
#import "ShareMethods.h"
#import "UIViewAdditions.h"
#import "MyScrollView.h"
#import "AppDelegate.h"
#import "BaseViewController.h"
#import "RequestManager.h"
#import "SDImageCache.h"
#import "UIImageView+WebCache.h"
#import "UIImage+FileName.h"

#import "DB.h"
#import "CardMaster.h"
#import "SampleCard.h"
#import "Entry.h"
#import "Details.h"
#import "WebId.h"
#import "InfoRead.h"
#import "Pdf.h"

//******************************** App User Default ********************************//

#define kAppTopicColor                                     @"AppTopicColor"
#define kAppOpenMoreThanOnce                               @"AppOpenMoreThanOnce"
#define kAppPassword                                       @"AppPassword"
#define kNeedEnterPassword                                 @"NeedEnterPassword"
#define kAutoUpdate                                        @"AutoUpdate"
#define kPDFNoitification                                  @"PDFNoitification"
#define kCostMoneyNotitication                             @"CostMoneyNotitication"
#define kNotifyCostMoneyLimit                              @"NotifyCostMoneyLimit"
#define kUserCode                                          @"user_code"

#define kDetailApiLastUpdateDate                           @"DetailApiLastUpdateDate"
#define kAggregationApiLastUpdateDate                      @"AggregationApiLastUpdateDate"
#define kPDFApiLastUpdateDate                              @"PDFApiLastUpdateDate"
#define kReviewPDFLastDate                                 @"ReviewPDFLastDate"
#define kMessageApiLastUpdateDate                          @"MessageApiLastUpdateDate"
#define kReviewMessageLastDate                             @"ReviewMessageLastDate"

#define kStartCount                                        @"StartCount"


//********************************* DB ***********************************//

#define kDBName                                            @"Creco.sqlite"
#define kDB_CardMaster                                     @"card_master"
#define kDB_SampleCard                                     @"sample_card"
#define kDB_Entry                                          @"entry"
#define kDB_Details                                        @"details"
#define kDB_WebId                                          @"web_id"
#define kDB_InfoRead                                       @"info_read"
#define kDB_Pdf                                            @"pdf"

//********************************* Tool ***********************************//

#define kAppDelegate                                       ((AppDelegate *)[[UIApplication sharedApplication] delegate])
#define kTabbarHeight                                      50
#define kAllViewWidth                                      [UIScreen mainScreen].bounds.size.width
#define kAllViewHeight                                     [UIScreen mainScreen].bounds.size.height-20-44-kTabbarHeight

#define Is_iPhone4Or4s                                     ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640, 960), [[UIScreen mainScreen] currentMode].size) : NO)
#define Is_iPhone5Or5s                                     ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640, 1136), [[UIScreen mainScreen] currentMode].size) : NO)
#define Is_iPhone6                                         ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(750, 1334), [[UIScreen mainScreen] currentMode].size) : NO)
#define Is_iPhone6_Plus                                     ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1242, 2208), [[UIScreen mainScreen] currentMode].size) : NO)
#define Is_iOS8OrLater                                     ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0 ? YES : NO)
#define kRGBColor(_r, _g, _b, _a)                          [UIColor colorWithRed:(_r)/255.0 green:(_g)/255.0 blue:(_b)/255.0 alpha:(_a)]

//****************************** App Style **********************************//

#define DEFAULT_APP_STSYLE_COLOR                           @"2045a1"
#define COLOR_BAR                                          [UIColor whiteColor]
#define COLOR_VIEW_BACKGROUND                              [UIColor whiteColor]
#define COLOR_VIEW_OTHER_BACKGROUND                        kRGBColor(242, 242, 242, 1.f)
#define COLOR_LINE                                         [ShareMethods colorFromHexRGB:@"dcdcdc"]
#define COLOR_DEFAULT_CARD                                 @"ffe800"

//*************************************** API **************************************//

#define kBaseURL                                           @"https://creco.cards/api/V1"
#define kStartUp                                           @"Startup"
#define kWEBIDRegist                                       @"WebIds/regist"
#define kWEBIDUpdate                                       @"WebIds/update"
#define kWEBIDDelete                                       @"WebIds/delete"
#define kAggregationRegist                                 @"Aggregation/regist"
#define kGetMessageNotification                            @"Information"
#define kGetDetail                                         @"Aggregation/detail"
#define kGetPDF                                            @"Aggregation/pdf"
#define kGetAgreement                                      @"Agreement"

//*********************************** App Setting ************************************//

#define kDeviceIdentifier                                  @"DeviceIdentifier"

#define kTopicIsChanged                                    @"TopicIsChanged"
#define kSwitchChangedValueNotification                    @"SwitchChangedValueNotification"
#define kNetworkIsValid                                    @"NetworkIsValid"
#define kUnReadMesageCountChanged                          @"UnReadMesageCountChanged"
#define kWebIdIsRegistSuccessed                            @"WebIdIsRegistSuccessed"

#define kAllCardCode                                       @"AllCard"

#define kRequestTimeout                                    30.f
#define kTimeoutCode                                       -1001
#define kFailedCode                                        -1009

#define kDefaultViewTag                                    1988

#define kEveryRecordCostHeght                              70.f

#define kAppStoreURL                                       @"https://itunes.apple.com/cn/app/gao-tu-zui-zhuan-ye-shou-ji/id461703208?mt=8"
#define kFAQURL                                            @"http://creco.cards/faq"
#define kCompanyURL                                        @"http://creco.cards/company"

#define kCardVerifyNoIDURL                                 @"https://creco.cards/howto/noaccount"
#define kCardVerifyNoWebServiceURL                         @"https://creco.cards/howto/noservice"

//******************************* Encryption Key *****************************//

#define kPasswordSecretKey                                 @"y>^{p0s="

static inline bool DrawLine(UIView *view,float x,float y,float lineWidth,float lineHeight,UIColor *color)
{
    CALayer *lineLayer = [CALayer layer];
    lineLayer.backgroundColor = color.CGColor;
    lineLayer.frame = CGRectMake(x, y, lineWidth, lineHeight);
    [view.layer addSublayer:lineLayer];
    
    return true;
}

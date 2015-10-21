//
//  RequestManager.m
//  Creco
//
//  Created by Windward on 14/9/20.
//  Copyright (c) 2014年 Windward. All rights reserved.
//

#import "RequestManager.h"
#import "RMMapper.h"
#import "ServerCardObject.h"
#import "UserCardObject.h"
#import "DetailCostObject.h"
#import "NewsObject.h"
#import "UIAlertView+BlocksKit.h"
#import "CalendarManager.h"
#import "PWSettingViewController.h"

@implementation RequestManager

+ (RequestManager *)manager
{
    RequestManager *manager = [[[self class] alloc] initWithBaseURL:[NSURL URLWithString:kBaseURL]];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    return manager;
}

+ (id)getObjectsResultFromInitDic:(NSMutableDictionary *)initDic byPathStr:(NSString *)pathStr
{
    id result = initDic;
    
    if (initDic[@"user_code"])
    {
        [[NSUserDefaults standardUserDefaults] setValue:initDic[@"user_code"] forKey:kUserCode];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:kAutoUpdate]) {
        if (initDic[@"auto_span"])
            [[AppConfig shareConfig] timeToRequestAggregationAPI:[initDic[@"auto_span"] integerValue]];
    }
    
    if (initDic[@"request_span"])
        [[AppConfig shareConfig] timeToRequestDetailAPI:[initDic[@"request_span"] integerValue]];
    
    if ([pathStr isEqualToString:kStartUp])
    {
        NSDictionary *serviceCardsDic = initDic[@"services"];
        if ([serviceCardsDic isKindOfClass:[NSDictionary class]]) {
            if (serviceCardsDic.allValues.count > 0) {
                NSMutableArray *serverCardObjsArr = [RMMapper mutableArrayOfClass:[ServerCardObject class] fromArrayOfDictionary:serviceCardsDic.allValues];
                [CardMaster replaceServerCardsIntoDBBy:serverCardObjsArr];
            }
        }
        
        BOOL isHaveRecords = NO;
        NSArray *userCardsArr = initDic[@"records"];
        if ([userCardsArr isKindOfClass:[NSArray class]]) {
            if (userCardsArr.count > 0) {
                isHaveRecords = YES;
                for (int i = 0; i < userCardsArr.count; i ++)
                {
                    NSDictionary *userCardDic = userCardsArr[i];
                    ServerCardObject *serverCardObj = [CardMaster getServerCardObjectByService_code:userCardDic[@"service_code"] andCard_master_code:userCardDic[@"card_master_code"]];
                    UserCardObject *userCardObj = [Entry getUserCardObjectByService_code:userCardDic[@"service_code"] andCard_code:userCardDic[@"card_code"]];
                    [Entry replaceUserCardIntoDBWithService_code:userCardDic[@"service_code"]
                                                       card_code:userCardDic[@"card_code"]
                                                       card_name:userCardObj.card_name.length > 0 ? userCardObj.card_name : serverCardObj.card_master_name
                                                            memo:userCardObj.memo
                                                           color:userCardObj.color.length > 0 ? userCardObj.color : COLOR_DEFAULT_CARD
                                                        card_seq:userCardObj ? userCardObj.card_seq : (int)[Entry getAllUserCards].count];
                }
            }
        }
        
        if (!isHaveRecords) {
            NSArray *calandarsArray = initDic[@"calandars"];
            if (calandarsArray.count > 0 && [calandarsArray isKindOfClass:[NSArray class]]) {
                [SampleCard replaceSampleCardsIntoDBBy:calandarsArray];
            }
        }
    }else if ([pathStr isEqualToString:kGetDetail])
    {
        if (initDic[@"last_update"]) {
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
            NSDate *updateDate = [formatter dateFromString:initDic[@"last_update"]];
            
            [[NSUserDefaults standardUserDefaults] setObject:updateDate forKey:kDetailApiLastUpdateDate];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
        
        NSDictionary *resultDic = initDic[@"results"];
        if ([resultDic isKindOfClass:[NSDictionary class]]) {
            if (resultDic.allValues.count > 0) {
                for (NSDictionary *tempDic in resultDic.allValues)
                {
                    NSDictionary *cardsDic = tempDic[@"cards"];
                    if ([cardsDic isKindOfClass:[NSDictionary class]])
                    {
                        NSString *cardCode = cardsDic[@"card_code"];
                        if (cardCode.length == 0) {
                            for (NSDictionary *cardDic in cardsDic.allValues)
                            {
                                if ([cardDic[@"data"] isKindOfClass:[NSDictionary class]])
                                {
                                    NSArray *costDetailsArray = ((NSDictionary *)cardDic[@"data"]).allValues;
                                    cardCode = cardDic[@"card_code"];
                                    [self storeDetailsIntoDBBy:costDetailsArray andCardCode:cardCode];
                                }
                            }
                        }else
                        {
                            if ([cardsDic[@"data"] isKindOfClass:[NSDictionary class]])
                            {
                                NSArray *costDetailsArray = ((NSDictionary *)cardsDic[@"data"]).allValues;
                                [self storeDetailsIntoDBBy:costDetailsArray andCardCode:cardCode];
                            }
                        }
                    }
                }
            }
        }
        
        if (result[@"records"]) {
            NSArray *userCardsArr = initDic[@"records"];
            if ([userCardsArr isKindOfClass:[NSArray class]]) {
                for (int i = 0; i < userCardsArr.count; i ++)
                {
                    NSDictionary *userCardDic = userCardsArr[i];
                    ServerCardObject *serverCardObj = [CardMaster getServerCardObjectByService_code:userCardDic[@"service_code"] andCard_master_code:userCardDic[@"card_master_code"]];
                    UserCardObject *userCardObj = [Entry getUserCardObjectByService_code:userCardDic[@"service_code"] andCard_code:userCardDic[@"card_code"]];
                    [Entry replaceUserCardIntoDBWithService_code:userCardDic[@"service_code"]
                                                       card_code:userCardDic[@"card_code"]
                                                       card_name:userCardObj.card_name.length > 0 ? userCardObj.card_name : serverCardObj.card_master_name
                                                            memo:userCardObj.memo
                                                           color:userCardObj.color.length > 0 ? userCardObj.color : COLOR_DEFAULT_CARD
                                                        card_seq:userCardObj ? userCardObj.card_seq : (int)[Entry getAllUserCards].count];
                }
            }
        }
    }else if ([pathStr isEqualToString:kGetMessageNotification])
    {
        if (initDic[@"last_update"]) {
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
            NSDate *updateDate = [formatter dateFromString:initDic[@"last_update"]];
            
            [[NSUserDefaults standardUserDefaults] setObject:updateDate forKey:kMessageApiLastUpdateDate];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
        
        NSArray *newsArray = initDic[@"news"];
        if ([newsArray isKindOfClass:[NSArray class]])
        {
            result = [RMMapper mutableArrayOfClass:[NewsObject class] fromArrayOfDictionary:newsArray];
            for (NewsObject *newsObj in result)
            {
                BOOL isExist = [InfoRead isExistInInfoReadByCode:newsObj.code];
                if (!isExist)
                    [InfoRead insertInfoReadIntoDBWithCode:newsObj.code title:newsObj.title content:newsObj.content read_flg:0 last_update:newsObj.modified];
            }
            
            kAppDelegate.appTabBarVC.menuTabbarItem.badgeValue = [InfoRead getUnReadMessageCount] > 0 ? @"N" : nil;
            [[NSNotificationCenter defaultCenter] postNotificationName:kUnReadMesageCountChanged object:nil];
        }
    }else if ([pathStr isEqualToString:kAggregationRegist])
    {
        if (initDic[@"last_update"]) {
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
            NSDate *updateDate = [formatter dateFromString:initDic[@"last_update"]];
            
            [[NSUserDefaults standardUserDefaults] setObject:updateDate forKey:kAggregationApiLastUpdateDate];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
    }else if ([pathStr isEqualToString:kGetPDF])
    {
        if (initDic[@"last_update"]) {
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
            NSDate *updateDate = [formatter dateFromString:initDic[@"last_update"]];
            
            [[NSUserDefaults standardUserDefaults] setObject:updateDate forKey:kPDFApiLastUpdateDate];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
        
        NSDictionary *resultDic = initDic[@"results"];
        if ([resultDic isKindOfClass:[NSDictionary class]]) {
            if (resultDic.allValues.count > 0) {
                for (NSDictionary *tempDic in resultDic.allValues)
                {
                    NSString *webIdCode = tempDic[@"web_id_code"];
                    NSDictionary *cardsDic = tempDic[@"cards"];
                    if ([cardsDic isKindOfClass:[NSDictionary class]])
                    {
                        NSString *cardCode = cardsDic[@"card_code"];
//                        NSString *cardMasterCode = cardsDic[@"card_master_code"];
                        if ([cardsDic[@"data"] isKindOfClass:[NSDictionary class]])
                        {
                            NSArray *pdfArray = ((NSDictionary *)cardsDic[@"data"]).allValues;
                            
                            NSMutableArray *resultPdfArray = [RMMapper mutableArrayOfClass:[PdfObject class] fromArrayOfDictionary:pdfArray];
                            for (PdfObject *pdfObj in resultPdfArray)
                            {
                                pdfObj.card_code = cardCode;
                                pdfObj.web_id_code = webIdCode;
                                [Pdf replacePdfIntoDBBy:pdfObj];
                            }
                        }
                    }
                }
            }
        }
        
    }else{
        result = initDic;
    }
    
    return result;
}

+ (void)storeDetailsIntoDBBy:(NSArray *)costDetailsArray andCardCode:(NSString *)cardCode
{
    NSMutableArray *resultDetailsArray = [RMMapper mutableArrayOfClass:[DetailCostObject class] fromArrayOfDictionary:costDetailsArray];
    for (DetailCostObject *detailCostObj in resultDetailsArray)
    {
        [[CalendarManager sharedManager] setGoogleImage:detailCostObj];
        UserCardObject *userCardObj = [Entry getUserCardObjectByService_code:nil andCard_code:detailCostObj.card_code];
        UserWebObject *userWebObj = [WebId getUserWebObjectByService_code:userCardObj.service_code];
        if (!userWebObj || userWebObj.detail_get_flg) {
            DetailCostObject *DBDetailCostObj = [Details getDetailCostObjectByCard_code:cardCode andCode:detailCostObj.code];
            if (DBDetailCostObj) {
                detailCostObj.picture1 = DBDetailCostObj.picture1;
                detailCostObj.picture2 = DBDetailCostObj.picture2;
                detailCostObj.picture3 = DBDetailCostObj.picture3;
                detailCostObj.bestshot = DBDetailCostObj.bestshot;
                detailCostObj.note = DBDetailCostObj.note;
            }else
                detailCostObj.bestshot = 0;
            detailCostObj.card_code = cardCode;
            [Details replaceDetailCostIntoDBBy:detailCostObj];
        }
    }
}

+ (void)requestPath:(NSString *)path
         parameters:(NSDictionary *)parameters
            success:(void (^)(AFHTTPRequestOperation *operation, id result))success
            failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    NSMutableDictionary *allParameters = [NSMutableDictionary dictionaryWithDictionary:parameters];
    [allParameters setValue:[AppConfig shareConfig].uuid forKey:@"uuid"];
    [allParameters setValue:[AppConfig shareConfig].deviceToken forKey:@"token_code"];
    [allParameters setValue:@"1" forKey:@"device_type"];
    [allParameters setValue:[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"] forKey:@"os_version"];
    
    RequestManager *requestManager = [RequestManager manager];
    [requestManager POST:path
              parameters:allParameters
                 success:^(AFHTTPRequestOperation *operation, id responseObject) {
                     if (responseObject)
                     {
                         NSError *err;
                         id changedResponseObj = [NSJSONSerialization JSONObjectWithData:responseObject
                                                                                 options:NSJSONReadingMutableContainers
                                                                                   error:&err];
                         if(err) {
                             TDLog(@"json parml failed：%@",err);
                             NSString *serverError = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
                             TDLog(@"server error:%@", serverError);
                             
                             [ShareMethods showAlertBy:serverError];
                             dispatch_async(dispatch_get_main_queue(), ^{
                                 success(operation, nil);
                             });
                         }else
                         {
                             responseObject = changedResponseObj;
                             
                             TDLog(@"responseObject:%@", responseObject);
                             
                             if ([responseObject isKindOfClass:[NSDictionary class]]) {
                                 if (!responseObject[@"status"] || [responseObject[@"status"] intValue] == 1 || [responseObject[@"status"] intValue] == 2) {
                                     id filterResult = [self getObjectsResultFromInitDic:responseObject byPathStr:path];
                                     dispatch_async(dispatch_get_main_queue(), ^{
                                         success(operation, filterResult);
                                     });
                                 }else
                                 {
                                     if ([responseObject[@"status"] intValue] == 5)
                                         [ShareMethods showAlertBy:@"維護中"];
                                     else if ([responseObject[@"status"] intValue] == 9)
                                         [ShareMethods showAlertBy:responseObject[@"error"][@"message"]];
                                     
                                     dispatch_async(dispatch_get_main_queue(), ^{
                                         success(operation, nil);
                                     });
                                 }
                             }else if ([responseObject isKindOfClass:[NSArray class]])
                             {
                                 TDLog(@"Server response error data!");
                             }
                         }
                     }else
                     {
                         if (![AppConfig shareConfig].isShowAPIAlert && ![path isEqualToString:kGetDetail]) {
                             [AppConfig shareConfig].isShowAPIAlert = YES;
                             [UIAlertView bk_showAlertViewWithTitle:@"一部情報取得が失敗しました。再読み込みしますか？"
                                                            message:nil
                                                  cancelButtonTitle:@"NO"
                                                  otherButtonTitles:@[@"YES"]
                                                            handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
                                                                [AppConfig shareConfig].isShowAPIAlert = NO;
                                                                if (buttonIndex == 1) {
                                                                    [self requestPath:path
                                                                           parameters:parameters
                                                                              success:success
                                                                              failure:failure];
                                                                }
                                                            }];
                         }
                         
                         dispatch_async(dispatch_get_main_queue(), ^{
                             success(operation, nil);
                         });
                     }
                 } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                     if ([error code] == kFailedCode)//No network
                     {
                         TDLog(@"受信に失敗しました。しばらくお試しください。");
                         if (![AppConfig shareConfig].isShowAPIAlert && ([path isEqualToString:kWEBIDRegist] || [path isEqualToString:kWEBIDUpdate] || [path isEqualToString:kWEBIDDelete] || [path isEqualToString:kWEBIDRegist])) {
                             [AppConfig shareConfig].isShowAPIAlert = YES;
                             [UIAlertView bk_showAlertViewWithTitle:@"接続失敗しました。\n通信環境の良い状態で再度接続してください。"
                                                            message:nil
                                                  cancelButtonTitle:nil
                                                  otherButtonTitles:@[@"OK"]
                                                            handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
                                                                [AppConfig shareConfig].isShowAPIAlert = NO;
                                                            }];
                         }
                     }else
                     {
                         if ([error code] == kTimeoutCode)
                             TDLog(@"Request timeout!");
                         
                         if (![AppConfig shareConfig].isShowAPIAlert && ![path isEqualToString:kGetDetail]) {
                             [AppConfig shareConfig].isShowAPIAlert = YES;
                             [UIAlertView bk_showAlertViewWithTitle:@"一部情報取得が失敗しました。再読み込みしますか？"
                                                            message:nil
                                                  cancelButtonTitle:@"NO"
                                                  otherButtonTitles:@[@"YES"]
                                                            handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
                                                                [AppConfig shareConfig].isShowAPIAlert = NO;
                                                                if (buttonIndex == 1) {
                                                                    [self requestPath:path
                                                                           parameters:parameters
                                                                              success:success
                                                                              failure:failure];
                                                                }
                                                            }];
                         }
                     }
                     
                     dispatch_async(dispatch_get_main_queue(), ^{
                         failure(operation, error);
                     });
                     
                     if ([path isEqualToString:kStartUp]) {
                         if ([[NSUserDefaults standardUserDefaults] boolForKey:kAppOpenMoreThanOnce]) {
                             if ([[NSUserDefaults standardUserDefaults] boolForKey:kNeedEnterPassword]) {
                                 [[NSNotificationCenter defaultCenter] postNotificationName:@"removeCalendar" object:nil];
                                 PWSettingViewController *pwSettingVC = [[PWSettingViewController alloc] init];
                                 [kAppDelegate.window.rootViewController presentViewController:pwSettingVC animated:NO completion:nil];
                             }
                         }
                     }
                 }];
}

@end

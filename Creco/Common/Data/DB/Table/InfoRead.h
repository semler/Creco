//
//  InfoRead.h
//  Creco
//
//  Created by Windward on 15/6/22.
//  Copyright (c) 2015年 Windward. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface InfoRead : NSObject

+ (BOOL)insertInfoReadIntoDBWithCode:(NSString *)code
                               title:(NSString *)title
                             content:(NSString *)content
                            read_flg:(int)read_flg
                         last_update:(NSString *)last_update;

+ (BOOL)updateInfoReadInDBByCode:(NSString *)code andIsRead:(int)isRead;

+ (BOOL)deleteInfoReadInDBByCode:(NSString *)code;

+ (BOOL)isExistInInfoReadByCode:(NSString *)code;

+ (BOOL)getMessageIsReadOrNotByCode:(NSString *)code;

+ (int)getUnReadMessageCount;

+ (NSMutableArray *)getAllNewsObjects;

+ (BOOL)cleanTable;

@end

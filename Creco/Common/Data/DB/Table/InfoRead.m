//
//  InfoRead.m
//  Creco
//
//  Created by Windward on 15/6/22.
//  Copyright (c) 2015年 Windward. All rights reserved.
//

#import "InfoRead.h"
#import "NewsObject.h"

@implementation InfoRead

+ (BOOL)insertInfoReadIntoDBWithCode:(NSString *)code
                               title:(NSString *)title
                             content:(NSString *)content
                            read_flg:(int)read_flg
                         last_update:(NSString *)last_update
{
    NSString *infoReadSql = [NSString stringWithFormat:@"INSERT INTO %@ (code, title, content, read_flg, last_update) VALUES (?,?,?,?,?)", kDB_InfoRead];
    BOOL result = [[DB getInstance] executeUpdate:infoReadSql,
                   code,
                   title,
                   content,
                   [NSNumber numberWithInt:read_flg],
                   last_update];
    return result;
}

+ (BOOL)updateInfoReadInDBByCode:(NSString *)code andIsRead:(int)isRead
{
    NSString *updateInfoReadSql = [NSString stringWithFormat:@"UPDATE %@ SET read_flg = ? WHERE code = ?", kDB_InfoRead];
    BOOL result = [[DB getInstance] executeUpdate:updateInfoReadSql,
                   [NSNumber numberWithInt:isRead],
                   code];
    return result;
}

+ (BOOL)deleteInfoReadInDBByCode:(NSString *)code
{
    NSString *delInfoReadSql = [NSString stringWithFormat:@"DELETE FROM %@ WHERE code = ?", kDB_InfoRead];
    return [[DB getInstance] executeUpdate:delInfoReadSql, code];
}

+ (BOOL)isExistInInfoReadByCode:(NSString *)code
{
    FMResultSet *rs = [[DB getInstance] executeQuery:[NSString stringWithFormat:@"SELECT * FROM %@ WHERE code = '%@'", kDB_InfoRead, code]];
    
    BOOL isExist = NO;
    if ([rs next])
    {
        NSString *DBCode = [rs stringForColumn:@"code"];
        if ([code isEqualToString:DBCode])
            isExist = YES;
    }
    [rs close];
    return isExist;
}

+ (BOOL)getMessageIsReadOrNotByCode:(NSString *)code
{
    FMResultSet *rs = [[DB getInstance] executeQuery:[NSString stringWithFormat:@"SELECT * FROM %@ WHERE code = '%@'", kDB_InfoRead, code]];
    
    BOOL isRead = NO;
    if ([rs next])
    {
        int read_flg = [rs intForColumn:@"read_flg"];
        isRead = read_flg;
    }
    [rs close];
    return isRead;
}

+ (int)getUnReadMessageCount
{
    FMResultSet *rs = [[DB getInstance] executeQuery:[NSString stringWithFormat:@"SELECT * FROM %@", kDB_InfoRead]];
    
    int unReadCount = 0;
    while ([rs next])
    {
        int read_flg = [rs intForColumn:@"read_flg"];
        if (read_flg == 0)
            unReadCount++;
    }
    [rs close];
    return unReadCount;
}

+ (NSMutableArray *)getAllNewsObjects
{
    FMResultSet *rs = [[DB getInstance] executeQuery:[NSString stringWithFormat:@"SELECT * FROM %@", kDB_InfoRead]];
    
    NSMutableArray *newsObjectsArr = [NSMutableArray array];
    while ([rs next])
    {
        NSString *code = [rs stringForColumn:@"code"];
        NSString *title = [rs stringForColumn:@"title"];
        NSString *content = [rs stringForColumn:@"content"];
        NSString *modified = [rs stringForColumn:@"last_update"];
        
        NewsObject *newsObj = [[NewsObject alloc] init];
        newsObj.code = code;
        newsObj.title = title;
        newsObj.content = content;
        newsObj.modified = modified;
        [newsObjectsArr addObject:newsObj];
    }
    [rs close];
    return newsObjectsArr;
}

+ (BOOL)cleanTable
{
    NSString *cleanInfoReadSql = [NSString stringWithFormat:@"DELETE FROM %@", kDB_InfoRead];
    return [[DB getInstance] executeUpdate:cleanInfoReadSql];
}

@end

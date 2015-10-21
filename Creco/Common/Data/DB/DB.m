//
//  DB.m
//  Help_Help
//
//  Created by Windward on 13-5-10.
//  Copyright (c) 2013年 Windward. All rights reserved.
//

#import "DB.h"

@implementation DB

static FMDatabase *db = nil;

+ (FMDatabase *)getInstance
{
    @synchronized(self)
    {
        if (!db)
        {
            NSString *documentDirectory = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory,NSUserDomainMask, YES) objectAtIndex:0];
            NSString *DBPath = [documentDirectory stringByAppendingPathComponent:kDBName];
            db = [[FMDatabase alloc] initWithPath:DBPath];
            TDLog(@"DBPath:%@",DBPath);
            
            if ([db open]){
                [db setShouldCacheStatements:YES];
                TDLog(@"Open success db !");
            }else{
                TDLog(@"Failed to open db!");
            }
            
#pragma mark -
            
            if (![[DB getInstance] tableExists:kDB_CardMaster])
            {
                NSString *base = @"CREATE TABLE IF NOT EXISTS '%@' ('service_code' VARCHAR, 'service_name' VARCHAR, 'card_master_code' VARCHAR, 'card_master_name' VARCHAR, 'description' TEXT, 'service_url' VARCHAR, 'additional_auth' VARCHAR, 'maintenance' VARCHAR, 'card_seq' INTEGER, PRIMARY KEY ('service_code','card_master_code'))";
                NSString *cardMasterTable = [NSString stringWithFormat:base, kDB_CardMaster];
                BOOL result = [[DB getInstance] executeUpdate:cardMasterTable];
                if (result)
                    TDLog(@"create table:%@ success",kDB_CardMaster);
            }else
            {
                TDLog(@"db table:%@ exists!",kDB_CardMaster);
            }

            if (![[DB getInstance] tableExists:kDB_SampleCard])
            {
                NSString *base = @"CREATE TABLE IF NOT EXISTS '%@' ('code' VARCHAR PRIMARY KEY, 'card_code' VARCHAR, 'calendar_memo' TEXT, 'image' TEXT, 'date' VARCHAR, 'name' VARCHAR, 'price' VARCHAR, 'color' VARCHAR, 'card_master_name' VARCHAR, 'card_master_code' VARCHAR)";
                NSString *sampleCardTable = [NSString stringWithFormat:base, kDB_SampleCard];
                BOOL result = [[DB getInstance] executeUpdate:sampleCardTable];
                if (result)
                {
                    TDLog(@"create table:%@ success",kDB_SampleCard);
                    
                    [SampleCard replaceSampleCostIntoDBWithCode:kAllCardCode
                                                      card_code:kAllCardCode
                                               card_master_code:kAllCardCode
                                                  calendar_memo:nil
                                                          image:nil
                                                           date:@"2000-01-01 00:00:00"
                                                           name:nil
                                                          price:nil
                                                          color:COLOR_DEFAULT_CARD
                                               card_master_name:@"全てのカード"];
                }
            }else
            {
                TDLog(@"db table:%@ exists!",kDB_SampleCard);
            }
            
            if (![[DB getInstance] tableExists:kDB_Entry])
            {
                NSString *base = @"CREATE TABLE IF NOT EXISTS '%@' ('service_code' VARCHAR, 'card_code' VARCHAR, 'card_name' VARCHAR, 'memo' TEXT, 'color' VARCHAR, 'card_seq' INTEGER, PRIMARY KEY ('service_code','card_code'))";
                NSString *entryTable = [NSString stringWithFormat:base, kDB_Entry];
                BOOL result = [[DB getInstance] executeUpdate:entryTable];
                if (result)
                {
                    TDLog(@"create table:%@ success",kDB_Entry);
                    
                    //Set AllCard To Entry Table
                    [Entry replaceUserCardIntoDBWithService_code:kAllCardCode
                                                       card_code:kAllCardCode
                                                       card_name:@"全てのカード"
                                                            memo:nil
                                                           color:nil
                                                        card_seq:0];
                }
            }else
            {
                TDLog(@"db table:%@ exists!",kDB_Entry);
            }

            if (![[DB getInstance] tableExists:kDB_Details])
            {
                NSString *base = @"CREATE TABLE IF NOT EXISTS '%@' ('card_code' VARCHAR, 'code' VARCHAR, 'date' VARCHAR, 'name' VARCHAR, 'note' VARCHAR, 'owner' VARCHAR, 'payday' VARCHAR, 'price' VARCHAR, 'disable' VARCHAR, 'picture1' TEXT, 'picture2' TEXT, 'picture3' TEXT, 'bestshot' INTEGER, PRIMARY KEY ('card_code','code'))";
                NSString *detailsTable = [NSString stringWithFormat:base, kDB_Details];
                BOOL result = [[DB getInstance] executeUpdate:detailsTable];
                if (result)
                    TDLog(@"create table:%@ success",kDB_Details);
            }else
            {
                TDLog(@"db table:%@ exists!",kDB_Details);
            }
            
            if (![[DB getInstance] tableExists:kDB_WebId])
            {
                NSString *base = @"CREATE TABLE IF NOT EXISTS '%@' ('service_code' VARCHAR PRIMARY KEY, 'service_name' VARCHAR, 'web_id_code' VARCHAR, 'card_code' VARCHAR, 'web_id' VARCHAR, 'initialization_vector' VARCHAR, 'password' VARCHAR, 'detail_get_flg' BOOL)";
                NSString *webIdTable = [NSString stringWithFormat:base, kDB_WebId];
                BOOL result = [[DB getInstance] executeUpdate:webIdTable];
                if (result)
                    TDLog(@"create table:%@ success",kDB_WebId);
            }else
            {
                TDLog(@"db table:%@ exists!",kDB_WebId);
            }
            
            if (![[DB getInstance] tableExists:kDB_InfoRead])
            {
                NSString *base = @"CREATE TABLE IF NOT EXISTS '%@' ('id' INTEGER PRIMARY KEY AUTOINCREMENT, 'code' VARCHAR, 'title' VARCHAR, 'content' TEXT, 'read_flg' INTEGER, 'last_update' VARCHAR)";
                NSString *infoReadTable = [NSString stringWithFormat:base, kDB_InfoRead];
                BOOL result = [[DB getInstance] executeUpdate:infoReadTable];
                if (result)
                    TDLog(@"create table:%@ success",kDB_InfoRead);
            }else
            {
                TDLog(@"db table:%@ exists!",kDB_InfoRead);
            }
            
            if (![[DB getInstance] tableExists:kDB_Pdf])
            {
                NSString *base = @"CREATE TABLE IF NOT EXISTS '%@' ('card_code' VARCHAR, 'web_id_code' VARCHAR, 'code' VARCHAR, 'date' VARCHAR, 'pdf' VARCHAR, 'pdf_last_update' VARCHAR, PRIMARY KEY ('card_code', 'date'))";
                NSString *infoPdfTable = [NSString stringWithFormat:base, kDB_Pdf];
                BOOL result = [[DB getInstance] executeUpdate:infoPdfTable];
                if (result)
                    TDLog(@"create table:%@ success",kDB_Pdf);
            }else
            {
                TDLog(@"db table:%@ exists!",kDB_Pdf);
            }
        }
        return db;
    }
}

+ (void)close
{
    if (db) {
        [db close];
        db = NULL;
    }
}

@end

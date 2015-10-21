//
//  Pdf.h
//  Creco
//
//  Created by 于　超 on 2015/07/08.
//  Copyright (c) 2015年 Windward. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PdfObject.h"

@interface Pdf : NSObject

+ (BOOL)replacePdfDBWithCard_code:(NSString *)card_code
                      web_id_code:(NSString *)web_id_code
                             code:(NSString *)code
                             date:(NSString *)date
                              pdf:(NSString *)pdf
                  pdf_last_update:(NSString *)pdf_last_update;

+ (BOOL)replacePdfIntoDBBy:(PdfObject *)pdfObject;

+ (NSMutableArray *)getAllPdf;
+ (NSMutableArray *)getPdfsBy:(NSString *)card_code;
+ (NSMutableArray *)getPdfsByDate:(NSString *)date;

+ (BOOL)deletePdfByCard_code:(NSString *)card_code web_id_code:(NSString *)web_id_code;
+ (BOOL)deletePdfByCard_code:(NSString *)card_code;
+ (BOOL)cleanTable;

@end

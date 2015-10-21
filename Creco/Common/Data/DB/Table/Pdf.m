//
//  Pdf.m
//  Creco
//
//  Created by 于　超 on 2015/07/08.
//  Copyright (c) 2015年 Windward. All rights reserved.
//

#import "Pdf.h"

@implementation Pdf

+ (BOOL)replacePdfDBWithCard_code:(NSString *)card_code
                      web_id_code:(NSString *)web_id_code
                             code:(NSString *)code
                             date:(NSString *)date
                              pdf:(NSString *)pdf
                  pdf_last_update:(NSString *)pdf_last_update
{
    NSString *detailsSql = [NSString stringWithFormat:@"REPLACE INTO %@ (card_code, web_id_code, code, date, pdf, pdf_last_update) VALUES (?,?,?,?,?,?)", kDB_Pdf];
    BOOL result = [[DB getInstance] executeUpdate:detailsSql,
                   card_code,
                   web_id_code,
                   code,
                   date,
                   pdf,
                   pdf_last_update];
    return result;
}

+ (BOOL)replacePdfIntoDBBy:(PdfObject *)pdfObject {

    return [self replacePdfDBWithCard_code:pdfObject.card_code web_id_code:pdfObject.web_id_code code:pdfObject.code date:pdfObject.date pdf:pdfObject.pdf pdf_last_update:pdfObject.pdf_last_update];
}

+ (NSMutableArray *)getAllPdf {
    FMResultSet *rs = [[DB getInstance] executeQuery:[NSString stringWithFormat:@"SELECT * FROM %@ ORDER BY date DESC", kDB_Pdf]];
    
    NSMutableArray *allPdfArr = [NSMutableArray array];
    while ([rs next])
    {
        NSString *card_code = [rs stringForColumn:@"card_code"];
        NSString *web_id_code = [rs stringForColumn:@"web_id_code"];
        NSString *code = [rs stringForColumn:@"code"];
        NSString *date = [rs stringForColumn:@"date"];
        NSString *pdf = [rs stringForColumn:@"pdf"];
        NSString *pdf_last_update = [rs stringForColumn:@"pdf_last_update"];
        
        PdfObject *pdfObject = [[PdfObject alloc] initWithCard_code:card_code web_id_code:web_id_code code:code date:date pdf:pdf pdf_last_update:pdf_last_update];
        [allPdfArr addObject:pdfObject];
    }
    [rs close];
    return allPdfArr;
}

+ (NSMutableArray *)getPdfsBy:(NSString *)card_code
{
    FMResultSet *rs = [[DB getInstance] executeQuery:[NSString stringWithFormat:@"SELECT * FROM %@ WHERE card_code = '%@' ORDER BY date DESC", kDB_Pdf, card_code]];
    
    NSMutableArray *pdfs = [NSMutableArray array];
    while ([rs next])
    {
        NSString *card_code = [rs stringForColumn:@"card_code"];
        NSString *web_id_code = [rs stringForColumn:@"web_id_code"];
        NSString *code = [rs stringForColumn:@"code"];
        NSString *date = [rs stringForColumn:@"date"];
        NSString *pdf = [rs stringForColumn:@"pdf"];
        NSString *pdf_last_update = [rs stringForColumn:@"pdf_last_update"];
        
        PdfObject *pdfObject = [[PdfObject alloc] initWithCard_code:card_code web_id_code:web_id_code code:code date:date pdf:pdf pdf_last_update:pdf_last_update];
        [pdfs addObject:pdfObject];
    }
    [rs close];
    return pdfs;
}

+ (NSMutableArray *)getPdfsByDate:(NSString *)date {
    FMResultSet *rs = [[DB getInstance] executeQuery:[NSString stringWithFormat:@"SELECT * FROM %@ WHERE date = '%@'", kDB_Pdf, date]];
    
    NSMutableArray *pdfs = [NSMutableArray array];
    while ([rs next])
    {
        NSString *card_code = [rs stringForColumn:@"card_code"];
        NSString *web_id_code = [rs stringForColumn:@"web_id_code"];
        NSString *code = [rs stringForColumn:@"code"];
        NSString *date = [rs stringForColumn:@"date"];
        NSString *pdf = [rs stringForColumn:@"pdf"];
        NSString *pdf_last_update = [rs stringForColumn:@"pdf_last_update"];
        
        PdfObject *pdfObject = [[PdfObject alloc] initWithCard_code:card_code web_id_code:web_id_code code:code date:date pdf:pdf pdf_last_update:pdf_last_update];
        [pdfs addObject:pdfObject];
    }
    [rs close];
    return pdfs;
}

+ (BOOL)deletePdfByCard_code:(NSString *)card_code web_id_code:(NSString *)web_id_code
{
    NSString *pdfDetailsSql = [NSString stringWithFormat:@"DELETE FROM %@ WHERE card_code = ? AND web_id_code = ?", kDB_Pdf];
    return [[DB getInstance] executeUpdate:pdfDetailsSql, card_code, web_id_code];
}

+ (BOOL)deletePdfByCard_code:(NSString *)card_code {
    NSString *pdfDetailsSql = [NSString stringWithFormat:@"DELETE FROM %@ WHERE card_code = ?", kDB_Pdf];
    return [[DB getInstance] executeUpdate:pdfDetailsSql, card_code];

}

+ (BOOL)cleanTable
{
    NSString *cleanDetailsSql = [NSString stringWithFormat:@"DELETE FROM %@", kDB_Pdf];
    return [[DB getInstance] executeUpdate:cleanDetailsSql];
}

@end

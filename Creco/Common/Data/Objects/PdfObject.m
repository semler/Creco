//
//  PdfObject.m
//  Creco
//
//  Created by 于　超 on 2015/07/08.
//  Copyright (c) 2015年 Windward. All rights reserved.
//

#import "PdfObject.h"

@implementation PdfObject

- (id)initWithCard_code:(NSString *)card_code
            web_id_code:(NSString *)web_id_code
                   code:(NSString *)code
                   date:(NSString *)date
                    pdf:(NSString *)pdf
        pdf_last_update:(NSString *)pdf_last_update
{
    if (self = [super init]) {
        _card_code = card_code;
        _web_id_code = web_id_code;
        _code = code;
        _date = date;
        _pdf = pdf;
        _pdf_last_update = pdf_last_update;
    }
    return self;
}

@end

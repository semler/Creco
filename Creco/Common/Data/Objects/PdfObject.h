//
//  PdfObject.h
//  Creco
//
//  Created by 于　超 on 2015/07/08.
//  Copyright (c) 2015年 Windward. All rights reserved.
//

#import "BaseObject.h"

@interface PdfObject : BaseObject

@property (nonatomic, strong) NSString *card_code;//Primary key
@property (nonatomic, strong) NSString *web_id_code;
@property (nonatomic, strong) NSString *code;
@property (nonatomic, strong) NSString *date;
@property (nonatomic, strong) NSString *pdf;
@property (nonatomic, strong) NSString *pdf_last_update;

- (id)initWithCard_code:(NSString *)card_code
            web_id_code:(NSString *)web_id_code
                   code:(NSString *)code
                   date:(NSString *)date
                    pdf:(NSString *)pdf
        pdf_last_update:(NSString *)pdf_last_update;

@end

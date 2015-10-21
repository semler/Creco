//
//  NewsObject.m
//  Creco
//
//  Created by Windward on 15/6/15.
//  Copyright (c) 2015年 Windward. All rights reserved.
//

#import "NewsObject.h"
#import "NewsCell.h"

@implementation NewsObject
@synthesize content, contentHeight, isShowAllWord;

- (void)setContent:(NSString *)_content
{
    content = _content;
    
    NSDictionary *attribute = @{NSFontAttributeName:[UIFont systemFontOfSize:13]};
    CGSize retSize = [content boundingRectWithSize:CGSizeMake(kNewsCellContentWidth, MAXFLOAT)
                                                     options:NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin |NSStringDrawingUsesFontLeading
                                                  attributes:attribute
                                                     context:nil].size;
    if (retSize.height > kNewsCellContentDefaultHeight)
        contentHeight = retSize.height;
    else
        contentHeight = kNewsCellContentDefaultHeight;
}

@end

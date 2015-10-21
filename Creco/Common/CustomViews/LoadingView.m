//
//  Created by Windward on 11-12-6.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "LoadingView.h"

@interface LoadingView ()

@end


@implementation LoadingView

@synthesize textLabel;
@synthesize activityIndicatorView;

- (id)initWithFrame:(CGRect)frame titleStr:(NSString *)string
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
		[self initializeWithStr:string];
    }
    return self;
}

- (void)initializeWithStr:(NSString *)string
{
	self.backgroundColor = [UIColor blackColor];
    self.alpha = 0.7f;
	self.layer.cornerRadius = 10.0f;
	self.autoresizingMask =
	UIViewAutoresizingFlexibleBottomMargin |
	UIViewAutoresizingFlexibleLeftMargin |
	UIViewAutoresizingFlexibleRightMargin |
	UIViewAutoresizingFlexibleTopMargin;
	
	UIActivityIndicatorView *aiView =
	[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
	aiView.center = CGPointMake(self.width/2-54.5, self.height/2);
	[aiView startAnimating];
	aiView.hidesWhenStopped = YES;
	[self addSubview:aiView];
	self.activityIndicatorView = aiView;
	
	UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.width/3*2, self.height)];
    label.center = CGPointMake(self.width/2+15, self.height/2);
	label.font = [UIFont boldSystemFontOfSize:17];
	label.textAlignment = NSTextAlignmentCenter;
	label.backgroundColor = [UIColor clearColor];
	label.textColor = [UIColor whiteColor];
    label.text = string;
	[self addSubview:label];
	self.textLabel = label;
}

@end

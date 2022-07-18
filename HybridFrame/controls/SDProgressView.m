//
//  SDProgressView.m
//  SCiP
//
//  Created by aquila on 2014. 3. 3..
//  Copyright (c) 2016년 samsungcard. All rights reserved.
//
#import "SDProgressView.h"


@interface SDProgressView () {
    UIImageView *loading;
}

@end

@implementation SDProgressView

- (id)init
{
	self = [super init];
	if(self)
	{
        [self setBackgroundColor: [UIColor clearColor]];
        [self setUserInteractionEnabled: YES];
        
		NSMutableArray *images	= [NSMutableArray array];
        for(int idx = 0 ; idx < 21 ; idx++)
        {
            [images addObject: [UIImage imageNamed: [NSString stringWithFormat: @"vw_progress_%d.png", idx]]];
        }
        
        loading	= [[UIImageView alloc] initWithFrame: CGRectMake(0.0, 0.0, 85.0, 85.0)];
        [loading setAnimationDuration: 1.0];
        [loading setAnimationImages: images];
        [loading setAnimationRepeatCount: 0];
        [loading startAnimating];
        
        [self addSubview: loading];
    }
    
    return self;
}

-(void)setProgFrame:(CGRect)parentFrame {
    CGFloat minWidth = MIN(parentFrame.size.width, SCREENWIDTH);
    CGFloat minHeight = MIN(parentFrame.size.height, SCREENHEIGHT);
    self.frame = CGRectMake(0, 0, minWidth, minHeight);
    [loading setCenter: [self center]];
}

@end

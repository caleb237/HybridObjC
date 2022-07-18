//
//  UINavigationBar+Helper.m
//  ods
//
//  Created by Mac on 2018. 6. 28..
//  Copyright © 2018년 Mac. All rights reserved.
//

#import "UINavigationBar+Helper.h"

@implementation UINavigationBar (Helper)

- (void)setBackNBorderColor:(UIColor *)borderColor
                  backColor:(UIColor *)backColor
                borderWidth:(CGFloat)borderWidth {
    [self setShadowImage:[AqUtil imageWithColor:borderColor width:borderWidth]];
    [self setBackgroundImage:[AqUtil imageWithColor:backColor width:borderWidth] forBarMetrics:UIBarMetricsDefault];
}

@end

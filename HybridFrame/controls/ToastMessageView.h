//
//  ToastMessageView.h
//  SCiP
//
//  Created by ym on 2016. 3. 1..
//  Copyright © 2016년 samsungcard. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ToastMessageView : UIView

+ (void)toastInView:(UIView *)parentView withText:(NSString *)text;


+ (void)toastInView:(UIView *)parentView withText:(NSString *)text duration:(CGFloat)duration alpha:(CGFloat)alpha;
@end

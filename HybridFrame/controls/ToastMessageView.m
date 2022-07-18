//
//  ToastMessageView.m
//  SCiP
//
//  Created by ym on 2016. 3. 1..
//  Copyright © 2016년 samsungcard. All rights reserved.
//

#import "ToastMessageView.h"

static const CGFloat kDuration = 2;
static NSMutableArray *ToastQueue;

@interface ToastMessageView ()

@property (nonatomic, readonly) UILabel *textLabel;
@property (nonatomic) CGFloat duration;

- (void)fadeToastOut;
+ (void)nextToastInView:(UIView *)parentView;

@end

@implementation ToastMessageView
#pragma mark - NSObject

- (id)initWithText:(NSString *)text {
    if ((self = [self initWithFrame:CGRectZero])) {
        
        self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:.6];
        self.layer.cornerRadius = 15;
        self.autoresizingMask = UIViewAutoresizingNone;
        self.autoresizesSubviews = NO;
        
        //text label
        _textLabel = [[UILabel alloc] init];
        _textLabel.text = text;
        _textLabel.font = [UIFont systemFontOfSize:16];
        _textLabel.textColor = [UIColor whiteColor];
        _textLabel.adjustsFontSizeToFitWidth = NO;
        _textLabel.backgroundColor = [UIColor clearColor];
        _textLabel.numberOfLines = 0;
        _textLabel.textAlignment = NSTextAlignmentCenter;
        _textLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        
        [self addSubview:_textLabel];
    }
    
    return self;
}



////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Public

+ (void)toastInView:(UIView *)parentView withText:(NSString *)text {
    
    [ToastMessageView toastInView:parentView withText:text duration:kDuration alpha:0.6];
}

+ (void)toastInView:(UIView *)parentView withText:(NSString *)text duration:(CGFloat)duration alpha:(CGFloat)alpha
{
    // 객체 생성
    ToastMessageView *view = [[ToastMessageView alloc] initWithText:text];
    
    view.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:alpha];
    
    CGRect bouns = [UIScreen mainScreen].bounds;
    bouns.size.width -= 20;
    CGRect textRect = [view.textLabel textRectForBounds:bouns limitedToNumberOfLines:0];
    view.textLabel.frame = CGRectMake(15, 10, textRect.size.width, textRect.size.height);
    
    CGFloat lWidth = textRect.size.width;
    CGFloat lHeight = textRect.size.height;
    CGFloat pWidth = parentView.frame.size.width;
    CGFloat pHeight = parentView.frame.size.height;
    
    // frame 설정
    view.frame = CGRectMake((pWidth - lWidth - 20) / 2., pHeight - lHeight - 100, lWidth + 30, lHeight + 20);
    view.alpha = 0.0f;
    
    if (ToastQueue == nil) {
        ToastQueue = [[NSMutableArray alloc] initWithCapacity:1];
        [ToastQueue addObject:view];
        [ToastMessageView nextToastInView:parentView];
    }
    else {
        [ToastQueue addObject:view];
    }
    view.duration = duration;
}


#pragma mark - Private

- (void)fadeToastOut {
    //Fade Out
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionAllowUserInteraction
     
                     animations:^{
                         self.alpha = 0.f;
                     }
                     completion:^(BOOL finished){
                         UIView *parentView = self.superview;
                         [self removeFromSuperview];
                         
                         [ToastQueue removeObject:self];
                         if ([ToastQueue count] == 0) {
                             ToastQueue = nil;
                         }
                         else
                             [ToastMessageView nextToastInView:parentView];
                     }];
}


+ (void)nextToastInView:(UIView *)parentView {
    if ([ToastQueue count] > 0) {
        ToastMessageView *view = [ToastQueue objectAtIndex:0];
        
        //Fade in
        [parentView addSubview:view];
        [UIView animateWithDuration:.5  delay:0 options:UIViewAnimationOptionAllowUserInteraction
                         animations:^{
                             view.alpha = 1.0;
                         } completion:^(BOOL finished){}];
        
        // kDuration 초 후에 자동 remove
        CGFloat duration = kDuration;
        if ([ToastQueue count] > 1) { //여러개 있을 경우 앞 토스트 뷰를 빨리 삭제함
            duration = 0.5f;
        }
        [view performSelector:@selector(fadeToastOut) withObject:nil afterDelay:duration];
    }
}

@end

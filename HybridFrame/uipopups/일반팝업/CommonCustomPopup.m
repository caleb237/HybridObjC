//
//  CommonCustomPopup
//
//  Created by Mac on 2018. 5. 8..
//  Copyright © 2018년 aquila. All rights reserved.
//

#import "CommonCustomPopup.h"
#import "CommonCustomPopupContentV.h"

#define kCommonPopupTitleHeight     47.0

@interface CommonCustomPopup ()

@property (weak, nonatomic) IBOutlet CommonCustomPopupContentV *contentV;
@property (nonatomic, strong) CommonCustomPopupBlock dismissBlock;

@end

@implementation CommonCustomPopup

// CommonCustomPopup 보여주는 중인지 체크
+(BOOL)isShowingAlert {
    NSArray *winSubs = [aqDelegate.window subviews];
    for (UIView *sub in winSubs) {
        if([sub isKindOfClass:[CommonCustomPopup class]]) {
            return YES;
        }
    }
    return NO;
}

+(void)showDefaultAlert:(NSString*)msg callback:(void (^)(NSInteger btnIndex))callback {
    if(msg.length==0) return;
    CommonCustomPopup *popup = [[CommonCustomPopup alloc] init];
    [popup showCustomPopupView:nil msg:msg cancelTitle:nil confirmTitle:@"확인"];
    [popup show:^(NSInteger btnIndex){
        if(callback){
            callback(btnIndex);
        }
    }];
}

+(void)showDefaultConfirm:(NSString*)msg callback:(void (^)(NSInteger btnIndex))callback {
    if(msg.length==0) return;
    CommonCustomPopup *popup = [[CommonCustomPopup alloc] init];
    [popup showCustomPopupView:nil msg:msg cancelTitle:@"취소" confirmTitle:@"확인"];
    [popup show:^(NSInteger btnIndex){
        if(callback){
            callback(btnIndex);
        }
    }];
}

+(void)showCustomPopup:(NSString*)title msg:(NSString*)msg cancelTitle:(NSString*)cancelTitle confirmTitle:(NSString*)confirmTitle callback:(void (^)(NSInteger btnIndex))callback {
    if(msg.length==0) return;
    CommonCustomPopup *popup = [[CommonCustomPopup alloc] init];
    [popup showCustomPopupView:title msg:msg cancelTitle:cancelTitle confirmTitle:confirmTitle];
    [popup show:^(NSInteger btnIndex){
        if(callback){
            callback(btnIndex);
        }
    }];
}

+(void)showPermissionPopup:(void (^)(NSInteger btnIndex))callback
{
    CommonCustomPopup *popup = [[CommonCustomPopup alloc] init];
    [popup showPermissionPopupView];
    [popup show:^(NSInteger btnIndex){
        if(callback){
            callback(btnIndex);
        }
    }];
}

-(void)showCustomPopupView:(NSString*)title msg:(NSString*)msg cancelTitle:(NSString*)cancelTitle confirmTitle:(NSString*)confirmTitle
{
    self.contentV = (CommonCustomPopupContentV *)[[[NSBundle mainBundle] loadNibNamed:@"CommonCustomPopupContentV" owner:nil options:nil] objectAtIndex:0];
    self.contentV.frame = aqDelegate.window.bounds;
    [self.contentV.closeBtn addTarget:self action:@selector(onClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentV.confirmBtn addTarget:self action:@selector(onClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentV.confirmLongBtn addTarget:self action:@selector(onClick:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.contentV.closeBtn setTitle:cancelTitle forState:UIControlStateNormal];
    [self.contentV.confirmBtn setTitle:confirmTitle forState:UIControlStateNormal];
    [self.contentV.confirmLongBtn setTitle:confirmTitle forState:UIControlStateNormal];
    
    // 버튼 뷰 셋팅
    if(cancelTitle.length>0){
        [self.contentV.closeBtn setTitle:AvoidNil(cancelTitle) forState:UIControlStateNormal];
        [self.contentV.confirmBtn setTitle:AvoidNil(confirmTitle) forState:UIControlStateNormal];
        [self.contentV.confirmLongBtn setHidden:YES];
    }else{
        [self.contentV.closeBtn setHidden:YES];
        [self.contentV.confirmBtn setHidden:YES];
        [self.contentV.confirmLongBtn setTitle:AvoidNil(confirmTitle) forState:UIControlStateNormal];
    }
    
    // 타이틀이 있다면 타이틀 화면을 보여주고 타이틀이 없다면 보여주지 않는다.
    if(title.length>0){
        self.contentV.titleHeight.constant = kCommonPopupTitleHeight;
        self.contentV.titleLabl.text = title;
    } else {
        self.contentV.titleHeight.constant = 0;
    }
    
    // 내용 셋팅
    self.contentV.msgLb.text = msg ? msg : @"";
    self.contentV.msgTv.text = msg ? msg : @"";
    
    CGFloat msgHeight = [AqUtil getLabelHeight:self.contentV.msgLb];
    if(msgHeight > 300){
        [self.contentV.msgLb setHidden:YES];
        [self.contentV.msgTv setHidden:NO];
    }else{
        [self.contentV.msgLb setHidden:NO];
        [self.contentV.msgTv setHidden:YES];
    }
}

-(void)showPermissionPopupView
{
    self.contentV = (CommonCustomPopupContentV *)[[[NSBundle mainBundle] loadNibNamed:@"CommonCustomPopupContentV" owner:nil options:nil] objectAtIndex:1];
    self.contentV.frame = aqDelegate.window.bounds;
    [self.contentV.closeBtn addTarget:self action:@selector(onClick:) forControlEvents:UIControlEventTouchUpInside];
}

// aquila 20171214 - 조건에 따른 다이얼로그 닫기 처리를 위해
-(void)onClickForCondition:(UIButton *)button {
    if(button==self.contentV.closeBtn){
        if([self.contentV isAvailableDismiss:onCustomPopupClose]) {
            [self dismiss:onCustomPopupClose];
        }
    }
    else if(button==self.contentV.confirmBtn){
        if([self.contentV isAvailableDismiss:onCustomPopupConfirm]) {
            [self dismiss:onCustomPopupConfirm];
        }
    }
}

-(void)onClick:(UIButton *)button {
    if(button==self.contentV.closeBtn){
        [self dismiss:onCustomPopupClose];
    }
    else if(button==self.contentV.confirmBtn){
        [self dismiss:onCustomPopupConfirm];
    }
    else if(button==self.contentV.confirmLongBtn){
        [self dismiss:onCustomPopupConfirm];
    }
}

-(void)show:(void (^)(NSInteger btnIndex))dismiss
{
    self.dismissBlock = dismiss;
    
    self.frame = aqDelegate.window.bounds;
    [aqDelegate.window addSubview:self];
    
    [self addSubview:self.contentV];
    
    self.contentV.popV.layer.cornerRadius = 5;
    self.contentV.popV.clipsToBounds = YES;
    self.contentV.popV.transform = CGAffineTransformMakeScale(0.2f, 0.2f);
    self.contentV.popV.alpha = 0;
    [UIView animateWithDuration:0.25f animations:^{
        self.contentV.popV.transform = CGAffineTransformIdentity;
        self.contentV.popV.alpha = 1;
    } completion:^(BOOL finished) {
        UIAccessibilityPostNotification(UIAccessibilityLayoutChangedNotification, self.contentV);
    }];
}

- (void)dismiss:(NSInteger)btnType
{
    [UIView animateWithDuration:0.25f animations:^{
        self.contentV.popV.transform = CGAffineTransformMakeScale(0.2f, 0.2f);
        self.contentV.popV.alpha = 0;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
        self.dismissBlock(btnType);
    }];
}

#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if (touch.view != self) {
        return NO;
    }
    return YES;
}

@end

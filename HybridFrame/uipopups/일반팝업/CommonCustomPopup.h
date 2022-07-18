//
//  CommonCustomPopup
//
//  Created by Mac on 2018. 5. 8..
//  Copyright © 2018년 aquila. All rights reserved.
//

typedef enum {
    onCustomPopupClose = 0,
    onCustomPopupConfirm = 1,
} CommonCustomPopupClickType;

typedef void (^CommonCustomPopupBlock)(NSInteger btnIndex);

@interface CommonCustomPopup : UIView

// CommonCustomPopup 보여주는 중인지 체크
+(BOOL)isShowingAlert;

// 기본 alert
+(void)showDefaultAlert:(NSString*)msg callback:(void (^)(NSInteger btnIndex))callback;

// 기본 confirm
+(void)showDefaultConfirm:(NSString*)msg callback:(void (^)(NSInteger btnIndex))callback;

// 커스텀 팝업
+(void)showCustomPopup:(NSString*)title msg:(NSString*)msg cancelTitle:(NSString*)cancelTitle confirmTitle:(NSString*)confirmTitle callback:(void (^)(NSInteger btnIndex))callback;

// 퍼미션 팝업
+(void)showPermissionPopup:(void (^)(NSInteger btnIndex))callback;

@end

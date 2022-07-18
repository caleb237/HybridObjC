//
//  CommonCustomPopupContentV
//
//  Created by Mac on 2018. 5. 8..
//  Copyright © 2018년 Mac. All rights reserved.
//

#import "CommonCustomPopup.h"

@interface CommonCustomPopupContentV : UIView

// 공통
@property (weak, nonatomic) IBOutlet UIView *popV;
@property (weak, nonatomic) IBOutlet UIButton *closeBtn;
@property (weak, nonatomic) IBOutlet UIButton *confirmBtn;
@property (weak, nonatomic) IBOutlet UILabel *titleLabl;
@property (weak, nonatomic) IBOutlet UIButton *confirmLongBtn;
@property (weak, nonatomic) IBOutlet UILabel *msgLb;
@property (weak, nonatomic) IBOutlet UITextView *msgTv;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *titleHeight;

// 닫을수 있는지 현재 상태를 판단하는 함수
-(BOOL)isAvailableDismiss:(CommonCustomPopupClickType)dismissType;

@end

//
//  CommonCustomPopupContentV
//
//  Created by Mac on 2018. 5. 8..
//  Copyright © 2018년 Mac. All rights reserved.
//

#import "CommonCustomPopupContentV.h"

@interface CommonCustomPopupContentV ()

@property NSString * webUrl;

@end

@implementation CommonCustomPopupContentV

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.frame = aqDelegate.window.bounds;
}

#pragma - 공통함수

// 닫을수 있는지 현재 상태를 판단하는 함수
-(BOOL)isAvailableDismiss:(CommonCustomPopupClickType)dismissType {
    return YES;
}

@end

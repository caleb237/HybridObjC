//
//  TouchReactButton.h
//  ods
//
//  Created by Mac on 2018. 6. 1..
//  Copyright © 2018년 Mac. All rights reserved.
//

typedef enum {
    ANIMATION_DIRECTION_NONE = 0,
    ANIMATION_DIRECTION_NORMAL,
    ANIMATION_DIRECTION_PRESS,
} ANIMATION_DIRECTION;

@interface TouchReactButton : UIButton

// 레이아웃 초기화
-(void)initLayout;

@end

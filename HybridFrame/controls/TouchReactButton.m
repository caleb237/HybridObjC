//
//  TouchReactButton.m
//  ods
//
//  Created by Mac on 2018. 6. 1..
//  Copyright © 2018년 Mac. All rights reserved.
//

#import "TouchReactButton.h"

@interface TouchReactButton() {
    CGAffineTransform transformNormal;
    CGAffineTransform transformPress;
    ANIMATION_DIRECTION animDict;
}

@end

@implementation TouchReactButton

-(void)awakeFromNib {
    [super awakeFromNib];
    self.exclusiveTouch = YES;
    transformNormal = CGAffineTransformScale(self.transform, 1.0, 1.0);
    transformPress = CGAffineTransformScale(self.transform, 0.90, 0.90);
}

// 레이아웃 초기화
-(void)initLayout {
    [self startAimation:NO];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
//    NSLog(@">>>>>>>>> 버튼 touch Began");
    [self startAimation:YES];
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(nullable UIEvent *)event {
    [super touchesMoved:touches withEvent:event];
//    NSLog(@">>>>>>>>> 버튼 touch moved");
//    [self startAimation:NO];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(nullable UIEvent *)event {
    [super touchesEnded:touches withEvent:event];
//    NSLog(@">>>>>>>>> 버튼 touch end");
    [self startAimation:NO];
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(nullable UIEvent *)event {
    [super touchesCancelled:touches withEvent:event];
//    NSLog(@">>>>>>>>> 버튼 touch cancel");
    [self startAimation:NO];
}

-(void)startAimation:(BOOL)toPress {
    // 버튼을 눌렀는데 현재 프레스 애니메이션 중일때
    if(toPress && animDict==ANIMATION_DIRECTION_PRESS) return;
    // 버튼을 눌렀다 띄었는데 현재 normal 애니메이션 중일때
    if(!toPress && animDict==ANIMATION_DIRECTION_NORMAL) return;
    // 버튼을 눌렀는데 이미 눌린 상태인 경우
    if(toPress && [self isPressed]) return;
    // 버튼을 눌렀다 띄었는데 이미 normal인 상태
    if(!toPress && [self isNormaled]) return;
    
    if(toPress) {
        animDict = ANIMATION_DIRECTION_PRESS;
    } else {
        animDict = ANIMATION_DIRECTION_NORMAL;
    }
    
    [UIView animateWithDuration:0.15f
                          delay:0
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         if(toPress) {
                             self.transform = self->transformPress;
                         } else {
                             self.transform = self->transformNormal;
                         }
                         [self layoutIfNeeded];
                     }
                     completion:^(BOOL finished) {
                         self->animDict = ANIMATION_DIRECTION_NONE;
                     }];
}

// 최초 상태여부
-(BOOL)isNormaled {
    CGAffineTransform curTransform = CGAffineTransformScale(self.transform, 1.0, 1.0);
    return CGAffineTransformEqualToTransform(transformNormal, curTransform);
}

// 프레스 상태여부
-(BOOL)isPressed {
    CGAffineTransform curTransform = CGAffineTransformScale(self.transform, 1.0, 1.0);
    return CGAffineTransformEqualToTransform(transformPress, curTransform);
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end

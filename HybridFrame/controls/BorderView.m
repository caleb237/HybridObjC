//
//  BorderView
//  SCiP
//
//  Created by Y0000111 on 2017. 12. 19..
//  Copyright © 2017년 samsungcard. All rights reserved.
//

#import "BorderView.h"

@interface BorderView() {
    
}

@end

@implementation BorderView

- (void) awakeFromNib {
    [super awakeFromNib];
    
    self.layer.borderWidth = 2;
    self.layer.borderColor = UIColorFromHexToRGB(0x0b59a5).CGColor;
}

@end

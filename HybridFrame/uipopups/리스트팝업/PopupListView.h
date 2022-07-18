//
//  PopupListView.h
//  SCiP
//
//  Created by ym on 2016. 1. 14..
//  Copyright © 2016년 samsungcard. All rights reserved.
//

#import "PopupListContentView.h"

#define kCellHeight 60
#define kPopUpWidth 300
#define kCellFontSize 20.0

typedef void (^PopupListBlock)(NSInteger index);

@interface PopupListView : UIView

- (void)show:(NSArray *)dataList dismiss:(PopupListBlock)dismiss;
- (void)show:(NSArray *)dataList selectedValue:(id)selectedValue dismiss:(PopupListBlock)dismiss;
- (void)show:(NSString *)title dataList:(NSArray *)dataList selectedValue:(id)selectedValue dismiss:(PopupListBlock)dismiss;

@end

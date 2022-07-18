//
//  PopupListView.m
//  SCiP
//
//  Created by ym on 2016. 1. 14..
//  Copyright © 2016년 samsungcard. All rights reserved.
//

#import "PopupListView.h"
#import "PopupListContentView.h"

@interface PopupListView () <PopupListContentViewDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, weak) UIView *contentView;
@property (nonatomic, strong) PopupListBlock dismissBlock;

@end

@implementation PopupListView

- (void)show:(NSArray *)dataList dismiss:(PopupListBlock)dismiss
{
    [self show:dataList selectedValue:nil dismiss:dismiss];
}

- (void)show:(NSArray *)dataList selectedValue:(id)selectedValue dismiss:(PopupListBlock)dismiss
{
    [self show:@"" dataList:dataList selectedValue:selectedValue dismiss:dismiss];
}

- (void)show:(NSString *)title dataList:(NSArray *)dataList selectedValue:(id)selectedValue dismiss:(PopupListBlock)dismiss
{
    [self show:title dataList:dataList selectedValue:selectedValue cellName:@"PopupListCell" dismiss:dismiss];
}

- (void)show:(NSString *)title dataList:(NSArray *)dataList selectedValue:(id)selectedValue cellName:(NSString *)cellName dismiss:(PopupListBlock)dismiss
{
    
    self.dismissBlock = dismiss;
    
    self.frame = aqDelegate.window.bounds;
    self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.7f];
    [aqDelegate.window addSubview:self];
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapHandler:)];
    tapGesture.delegate = self;
    [self addGestureRecognizer:tapGesture];
    
    PopupListContentView *contentView = [[[NSBundle mainBundle] loadNibNamed:@"PopupListContentView" owner:nil options:nil] firstObject];
    contentView.delegate = self;
    contentView.cellName = cellName;
    contentView.dataList = dataList;
    contentView.hiddenTitleView = ([title length] == 0);
    [contentView setTitle:title];
    self.contentView = contentView;
    
    NSArray *nibs = [[NSBundle mainBundle] loadNibNamed:cellName owner:self options:nil];
    UITableViewCell *cell = [nibs lastObject];
    [cell setIsAccessibilityElement:YES];
    
    NSInteger count = [dataList count];
    if (count < 1) {
        count = 1;
    }
    if (count > 6) {
        count = 6;
    }
    
    CGFloat height = kCellHeight * count + 60;
    contentView.frame = CGRectMake(0, 0, kPopUpWidth, height);
    contentView.center = CGPointMake(aqDelegate.window.bounds.size.width/2, aqDelegate.window.bounds.size.height/2);
    contentView.layer.cornerRadius = 5;
    contentView.clipsToBounds = YES;
    [self addSubview:contentView];
    
    NSInteger index = 0;
    if (selectedValue != nil && [dataList containsObject:selectedValue]) {
        index = [dataList indexOfObject:selectedValue];
    }
    //    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
    //        @try {
    [contentView.tableView reloadData];
    [contentView.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0] atScrollPosition:UITableViewScrollPositionMiddle animated:NO];
    //        } @catch (NSException *exception) {
    //            NSLog(@"<WARRING> popup list view : %@", exception.description);
    //        }
    //    });
    
    contentView.transform = CGAffineTransformMakeScale(0.2f, 0.2f);
    contentView.alpha = 0;
    [UIView animateWithDuration:0.25f animations:^{
        contentView.transform = CGAffineTransformIdentity;
        contentView.alpha = 1;
    } completion:^(BOOL finished) {
        
    }];
   
}

- (void)dismiss:(NSInteger)index
{
    [UIView animateWithDuration:0.25f animations:^{
        self.contentView.transform = CGAffineTransformMakeScale(0.2f, 0.2f);
        self.contentView.alpha = 0;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
        
        if(index!=-1) {
            if (self.dismissBlock != nil) {
                self.dismissBlock(index);
            }
        }
        
    }];
}


#pragma mark - PopupListContentViewDelegate

- (void)popupListContentView:(PopupListContentView *)sender didSelectAtIndex:(NSInteger)index
{
    [self dismiss:index];
}

- (void)tapHandler:(UITapGestureRecognizer *)gesture
{
    CGRect contentFrame = self.contentView.frame;
    CGPoint location = [gesture locationInView:self];
    if (!CGRectContainsPoint(contentFrame, location)) {
        [self dismiss:-1];
    }
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

//
//  PopupListContentView.h
//  SCiP
//
//  Created by ym on 2016. 1. 14..
//  Copyright © 2016년 samsungcard. All rights reserved.
//

@protocol PopupListContentViewDelegate;

@interface PopupListContentView : UIView

@property (nonatomic, weak) id<PopupListContentViewDelegate> delegate;
@property (nonatomic, copy) NSString *cellName; //테이블 샐 nib이름
@property (nonatomic, copy) NSArray *dataList;  //데이터 리시트
@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic) BOOL hiddenTitleView;

- (void)setTitle:(NSString *)title;

@end


@protocol PopupListContentViewDelegate <NSObject>

- (void)popupListContentView:(PopupListContentView *)sender didSelectAtIndex:(NSInteger)index;

@end

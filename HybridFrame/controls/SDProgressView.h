//
//  SDProgressView.h
//  SCiP
//
//  Created by aquila on 2014. 3. 3..
//  Copyright (c) 2016년 samsungcard. All rights reserved.
//

/*!
 * @brief 로딩 팝업
 */
@interface SDProgressView : UIView

@property (nonatomic, assign) id sender;

-(void)setProgFrame:(CGRect)parentFrame;

@end

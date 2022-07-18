//
//  RefreshWKWebV.m
//  HybridFrame
//
//  Created by aquila choi on 2019. 1. 24..
//  Copyright © 2019년 aquila. All rights reserved.
//

#import "RefreshWKWebV.h"

@implementation RefreshWKWebV

- (instancetype)initWithFrame:(CGRect)frame configuration:(WKWebViewConfiguration *)configuration
{
    self = [super initWithFrame:frame configuration:configuration];
    if (self) {
        // refresh ui 추가
//        self.refreC = [[UIRefreshControl alloc] init];
//        [self.refreC addTarget:self action:@selector(handleRefresh:) forControlEvents:UIControlEventValueChanged];
//        [self.scrollView addSubview:self.refreC];
        self.scrollView.backgroundColor = [UIColor whiteColor];
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.backgroundColor = [UIColor whiteColor];
        [self.scrollView setBounces:NO];
    }
    return self;
}

-(void)stopRefreshUI {
//    if(self.refreC && self.refreC.isRefreshing) {
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//            [self.refreC endRefreshing];
//        });
//    }
}

#pragma mark - refresh ui 관련

-(void)handleRefresh:(UIRefreshControl *)refreC
{
    [refreC beginRefreshing];
    [self reload];
}

@end

//
//  RefreshWKWebV.h
//
//  Created by aquila choi on 2019. 1. 24..
//  Copyright © 2019년 aquila. All rights reserved.
//

#import <WebKit/WebKit.h>

@interface RefreshWKWebV : WKWebView

@property (retain, nonatomic) UIRefreshControl *refreC;

-(void)stopRefreshUI;

@end

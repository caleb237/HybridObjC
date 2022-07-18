//
//  WkWebHelper.m
//
//  Created by Aquila on 2016. 10. 10..
//  Copyright © 2016년 aquila. All rights reserved.
//


#import "WkWebHelper.h"

@interface WkWebHelper () {
}

@end

@implementation WkWebHelper

// window.close 처리를 위한 스크립트
-(void)windowCloseScript:(WKUserContentController *)userContentController
{
    NSString *script = @"var originalWindowClose=window.close;window.close=function(){var iframe=document.createElement('IFRAME');iframe.setAttribute('src','back://'),document.documentElement.appendChild(iframe);originalWindowClose.call(window)}; var cookieNames = document.cookie.split('; ').map(function(cookie) { return cookie.split('=')[0] } );\n";
    WKUserScript *cookieScript = [[WKUserScript alloc]
                                  initWithSource:script
                                  injectionTime:WKUserScriptInjectionTimeAtDocumentStart
                                  forMainFrameOnly:NO];
    [userContentController addUserScript:cookieScript];
}

// 공통 웹뷰 request 처리
-(void)loadCustomRequest:(WKWebView *)wView requestStr:(NSString *)requestStr
{
    if(requestStr.length==0) return;
    NSURL *loadUrl = [NSURL URLWithString:requestStr];
    if([[UIApplication sharedApplication] canOpenURL:loadUrl]) {
        
    NSMutableURLRequest *request;
#if USE_WEB_CASH
        request = [NSMutableURLRequest requestWithURL:loadUrl];
#else
        request = [NSMutableURLRequest requestWithURL:loadUrl cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:TIME_OUT];
#endif
        [wView loadRequest:request];
    }
}

@end

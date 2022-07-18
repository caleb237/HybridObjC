//
//  WkWebHelper.h
//
//  Created by Aquila on 2016. 10. 10..
//  Copyright © 2016년 aquila. All rights reserved.
//

@interface WkWebHelper : NSObject

// window.close 처리를 위한 스크립트
-(void)windowCloseScript:(WKUserContentController *)userContentController;

// 공통 웹뷰 request 처리
-(void)loadCustomRequest:(WKWebView *)wView requestStr:(NSString *)requestStr;

@end

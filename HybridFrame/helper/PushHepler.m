//
//  PushHepler
//
//  Created by Mac on 2018. 7. 4..
//  Copyright © 2018년 aquila. All rights reserved.
//

#import "PushHepler.h"

@implementation PushHepler

+(PushHepler*)getInstance
{
    static PushHepler* manager;
    static dispatch_once_t once;
    
    dispatch_once(&once, ^{
        if(manager == nil) {
            manager = [[PushHepler alloc] init];
        }
    });
    return manager;
}

// 링크 파라미터를 초기화
-(void)initPushUrl
{
    self.pushUrl = nil;
}

// payload로 부터 linkurl을 셋팅
-(void)setPushUrlFromApnsPayload:(NSDictionary *)launchOptions
{
    // link url 셋팅
    self.pushUrl = launchOptions[@"linkurl"];
    // alert 정보 셋팅
    NSDictionary *alertInfo = launchOptions[@"aps"][@"alert"];
    if(alertInfo && [alertInfo isKindOfClass:[NSDictionary class]]) {
        self.pushTitle = alertInfo[@"title"];
        self.pushMsg = alertInfo[@"body"];
    }
}

@end

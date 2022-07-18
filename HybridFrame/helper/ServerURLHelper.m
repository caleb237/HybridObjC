//
//  ServerURLHelper.m
//
//  Created by choi on 2015. 5. 8..
//  Copyright (c) 2015년 aquila. All rights reserved.
//

#import "ServerURLHelper.h"

@implementation ServerURLHelper

+(ServerURLHelper*)getInstance
{
    static ServerURLHelper* manager;
    static dispatch_once_t once;
    
    dispatch_once(&once, ^{
        if(manager == nil) {
            manager = [[ServerURLHelper alloc] init];
        }
    });
    return manager;
}

// api domain 반환
-(NSString *)getApiDomain {
    switch (self.serverType) {
        case APP_SERVER_TYPE_DEV:
            return DEV_API_DOMIAN;
        case APP_SERVER_TYPE_RELEASE:
            return RELEASE_API_DOMIAN;
        default:
            return RELEASE_API_DOMIAN;
    }
}

// 홈페이지 url 반환
-(NSString *)getHomeURL {
    switch (self.serverType) {
        case APP_SERVER_TYPE_DEV:
            return DEV_HOME_URL;
        case APP_SERVER_TYPE_RELEASE:
            return RELEASE_HOME_URL;
        default:
            return DEV_HOME_URL;
    }
}

@end

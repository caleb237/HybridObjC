//
//  ServerURLHelper.h
//
//  Created by aquila on 2015. 5. 8..
//  Copyright (c) 2015년 aquila. All rights reserved.
//

//#define DEV_HOME_URL @"http://igcfo.innodis.co.kr/main/main.do"
#define DEV_HOME_URL @"http://theprayer.cafe24.com/test/appMain.html"
#define DEV_API_DOMIAN @"http://theprayer.cafe24.com"

#define RELEASE_HOME_URL @"http://igcfo.innodis.co.kr/main/main.do"
#define RELEASE_API_DOMIAN @"http://theprayer.cafe24.com"

typedef enum {
    APP_SERVER_TYPE_DEV = 0,
    APP_SERVER_TYPE_RELEASE,
} APP_SERVER_TYPE;

@interface ServerURLHelper : NSObject

@property (retain, nonatomic) NSString *serverURL;
@property (assign, nonatomic) APP_SERVER_TYPE serverType;

+(ServerURLHelper*)getInstance;

// api domain 반환
-(NSString *)getApiDomain;

// 홈페이지 url 반환
-(NSString *)getHomeURL;

@end

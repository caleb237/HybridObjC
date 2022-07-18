//
//  Service.h
//  SCiP
//
//  Created by ym on 2016. 1. 12..
//  Copyright © 2016년 samsungcard. All rights reserved.
//

#define kCommonKey @"common"
#define kParseErrCode @"parseErrCode"
#define kParseErrDesc @"parseErrDesc"

typedef void (^ServiceResponseBlock)(NSDictionary *response, NSError *error);
typedef void (^UserAgentBlock)(void);

@interface ServiceManager : NSObject

// user agent 값
@property (retain, nonatomic) NSString *defaultUsrAgent; // 변경 전 user agent
@property (retain, nonatomic) NSString *customUsrAgent; // 변경 후 user agent

+ (ServiceManager*)sharedInstance;

// user agent 변경
-(void)changeUserAgent:(WKWebView *)curWebV completion:(UserAgentBlock)completion;

// 인트로 정보 요청
- (void)requestIntroInfo:(NSDictionary *)params completion:(ServiceResponseBlock)completion;

#pragma mark - 공통 response 처리

// response 공통 처리
-(BOOL)isSucessService:(NSDictionary *)response isShowErr:(BOOL)isShowErr defaultErrMsg:(NSString *)defaultErrMsg;

@end

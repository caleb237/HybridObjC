//
//  Service.m
//  SCiP
//
//  Created by ym on 2016. 1. 12..
//  Copyright © 2016년 samsungcard. All rights reserved.
//

#import "ServiceManager.h"
#import "RequestManager.h"

@interface ServiceManager () {
}

@end

@implementation ServiceManager

+ (ServiceManager*)sharedInstance
{
    static ServiceManager* service;
    static dispatch_once_t once;
    
    dispatch_once(&once, ^{
        if(service == nil) {
            service = [[ServiceManager alloc] init];
        }
    });
    return service;
}

// user agent 변경
-(void)changeUserAgent:(WKWebView *)curWebV completion:(UserAgentBlock)completion
{
    // user agent 값을 수정한 뒤 웹을 로드한다.
    [curWebV evaluateJavaScript:@"navigator.userAgent" completionHandler:^(NSString *result, NSError *error){
        // jo-Agent가 없으면 default user agent
        if(![result containsString:@"aq-agent:ios"]) {
            self.defaultUsrAgent = result;
        }
        self.customUsrAgent = [NSString stringWithFormat:@"%@ aq-agent:ios", self.defaultUsrAgent];
        curWebV.customUserAgent = self.customUsrAgent;
        [curWebV evaluateJavaScript:@"navigator.userAgent" completionHandler:^(NSString *result, NSError *error){
            NSLog(@"#################### USER AGENT 정보 시작 ####################");
            NSLog(@"기본 useragent : %@", self.defaultUsrAgent);
            NSLog(@"변경 useragent : %@", result);
            NSLog(@"#################### USER AGENT 정보 끝 ####################");
            completion();
        }];
    }];
}

#pragma mark - 공통 response 처리

// response 공통 처리
-(BOOL)isSucessService:(NSDictionary *)response isShowErr:(BOOL)isShowErr defaultErrMsg:(NSString *)defaultErrMsg
{
    // 통신 성공 처리
    if([response[@"header"][@"code"] isEqualToString:@"0000"]) {
        return YES;
    }
    // 통신 실패 처리
    else {
        if(isShowErr) {
            NSString *errMsg = response[@"header"][@"message"];
            if(errMsg.length==0) {
                errMsg = defaultErrMsg;
            }
            [CommonCustomPopup showDefaultAlert:errMsg callback:^(NSInteger btnIndex){
            }];
        }
        return NO;
    }
}

#pragma mark - 서비스 개별 호출

// 인트로 정보 요청
- (void)requestIntroInfo:(NSDictionary *)params completion:(ServiceResponseBlock)completion
{
    NSString *svcUrl = [NSString stringWithFormat:@"%@/test/intro.php", [[ServerURLHelper getInstance] getApiDomain]];
    NSLog(@"\n####################################################\n %s \n서비스 URL : %@\n파라미터 : %@\n####################################################",__func__ , svcUrl, params);
    RequestManager *manager = [RequestManager manager];
    [manager post:svcUrl headers:nil params:params completion:^(NSDictionary *resultDic, NSError *error) {
        if(completion) {
            completion(resultDic, error);
        }
    }];
}


@end

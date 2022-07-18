//
//  PushHepler
//
//  Created by Mac on 2018. 7. 4..
//  Copyright © 2018년 aquila. All rights reserved.
//

@interface PushHepler : NSObject

// link, push 연결 url
@property (retain, nonatomic) NSString *pushUrl;
// 앱실행 시 푸시 타이틀
@property (retain, nonatomic) NSString *pushTitle;
// 앱실행 시 푸시 메세지
@property (retain, nonatomic) NSString *pushMsg;

+(PushHepler*) getInstance;

// 링크 파라미터를 초기화
-(void)initPushUrl;

// payload로 부터 linkurl을 셋팅
-(void)setPushUrlFromApnsPayload:(NSDictionary *)launchOptions;

@end

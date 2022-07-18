//
//  IntroVC
//  ods
//
//  Created by Mac on 2018. 5. 8..
//  Copyright © 2018년 Mac. All rights reserved.
//

#import "IntroVC.h"
#import "PopupListView.h"
#import "WebVC.h"

@interface IntroVC () {
}

@property (nonatomic, assign) BOOL isCompleteVersionCheck; // 버전체크 완료 여부
@property (nonatomic, assign) BOOL isCompleteDelay; // 딜레이 완료 여부

@end

@implementation IntroVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 현재 udid 가져오기
    NSLog(@">>>>> 현재 UDID : %@", [AqUtil getDeviceUDID]);
    
#if TEST_MODE
    [[ServerURLHelper getInstance] setServerType:APP_SERVER_TYPE_DEV];
#else
    [[ServerURLHelper getInstance] setServerType:APP_SERVER_TYPE_RELEASE];
#endif
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    // 탈옥폰 탐지
    if([AqUtil isJailBreakCheck]) {
        [CommonCustomPopup showDefaultAlert:@"탈옥이 감지되었습니다." callback:^(NSInteger btnIndex) {
            exit(0);
        }];
        return;
    }
    
    // top, bottom guide 셋팅
    aqDelegate.bottomGuideValue = self.bottomLayoutGuide.length;
    aqDelegate.topGuideValue = self.topLayoutGuide.length;
    NSLog(@">>>>>>> 디바이스 bottom guide : %f, top guide : %f", self.bottomLayoutGuide.length, self.topLayoutGuide.length);
    
#if TEST_MODE
    [self selectServer];
#else
    [self versionCheck];
#endif
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.isCompleteDelay = YES;
        [self goToMain];
    });
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

// 서버 고르기
-(void)selectServer
{
    NSArray *arr = [NSArray arrayWithObjects:
                    @{kPopListCellTitleKey:@"앱테스트"},
                    @{kPopListCellTitleKey:@"개발계"},
                    nil];
    PopupListView *listView = [[PopupListView alloc] init];
    [listView show:arr dismiss: ^(NSInteger seletedIndex)
    {
        if (seletedIndex >= 0) {
            [[ServerURLHelper getInstance] setServerType:(APP_SERVER_TYPE)seletedIndex];
            [self versionCheck];
        }
    }];
}

// 버전 체크
-(void)versionCheck {
    NSDictionary* param = @{
                            @"app_os":@"I",
                            @"app_ver":AvoidNil(APP_VERSION),
                            };
    [[ServiceManager sharedInstance] requestIntroInfo:param completion:^(NSDictionary *response, NSError *error) {
        BOOL isNeedUpdate = [response[@"isNeedUpdate"] isEqualToString:@"Y"];
        BOOL isForceUpdate = [response[@"isForceUpdate"] isEqualToString:@"Y"];
        if(isNeedUpdate) {
            [CommonCustomPopup showCustomPopup:nil
                                           msg: isForceUpdate ? @"중요한 업데이트 사항이 있습니다. 업데이트 후 이용해 주시기 바랍니다." : @"앱이 업데이트 되었습니다. 지금 업데이트 하시겠습니까?"
                                   cancelTitle: isForceUpdate ? @"종료" : @"다음에하기"
                                  confirmTitle: @"지금업데이트"
                                      callback:^(NSInteger btnIndex) {
                                          // 종료
                                          if(btnIndex==onCustomPopupClose) {
                                              if(isForceUpdate) {
                                                  exit(1);
                                              } else {
                                                  self.isCompleteVersionCheck = YES;
                                                  [self goToMain];
                                              }
                                          }
                                          // 업데이트
                                          else if(btnIndex==onCustomPopupConfirm) {
                                              [[UIApplication sharedApplication] openURL: [NSURL URLWithString:APPSTORE_URL]];
                                              exit(1);
                                          }
                                      }];
        }
        else {
            self.isCompleteVersionCheck = YES;
            [self goToMain];
        }
    }];
}

-(void)goToMain
{
    if(self.isCompleteVersionCheck && self.isCompleteDelay)
    {
        [self performSegueWithIdentifier:@"SegueMain" sender:self];
    }
}
    
@end

//
//  AppDelegate.m
//  하이브리드앱
//
//  Created by Mac on 23/01/2019.
//  Copyright © 2019 aquila. All rights reserved.
//

#import "AppDelegate.h"
#import "PushHepler.h"

@interface AppDelegate () <UNUserNotificationCenterDelegate, FIRMessagingDelegate>

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    // apns 셋팅
    [self initApnsSet];
    
    // 푸시로 들어온 경우 처리
    if(launchOptions && [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey]){
        // link url 셋팅
        [[PushHepler getInstance] setPushUrlFromApnsPayload:launchOptions];
    }
    
    // firebase 셋팅
    [FIRApp configure];
    //    [Fabric.sharedSDK setDebug:YES];
    [FIRMessaging messaging].delegate = self;
    [FIRMessaging messaging].autoInitEnabled = YES;
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark - FCM

- (void)messaging:(FIRMessaging *)messaging didReceiveRegistrationToken:(NSString *)fcmToken {
    NSLog(@">>>>>>>>>> FCM registration token: %@", fcmToken);
}

#pragma mark - 푸시관련 처리 공통

- (void)application: (UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken: (NSData *)deviceToken
{
    [FIRMessaging messaging].APNSToken = deviceToken;
}

#pragma mark - 푸시관련 처리 ios9 이하

// 푸시 type 셋팅 시 regist 실행
- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings
{
    [application registerForRemoteNotifications];
    // 시스템 알림 설정 == OFF 처리
    if([UIApplication sharedApplication].currentUserNotificationSettings.types == UIUserNotificationTypeNone){
    }
}

// 푸시 서비스 등록 실패시 호출되는 함수
- (void)application: (UIApplication *)application didFailToRegisterForRemoteNotificationsWithError: (NSError *)error
{
    NSLog(@">>>>>>>>>>> didFailToRegisterForRemoteNotificationsWithError\n%@", [error description]);
}

// 푸시 데이터가 들어오는 함수
- (void)application: (UIApplication *)application didReceiveRemoteNotification: (NSDictionary *)userInfo
{
    NSLog(@">>>>>>>>>>> didReceiveRemoteNotification : %@",userInfo);
    // 푸시 알림
    [[PushHepler getInstance] setPushUrlFromApnsPayload:userInfo];
    [[NSNotificationCenter defaultCenter] postNotificationName:kApnsNoti object:self];
}

#pragma mark - 푸시관련 처리 ios10 이상

// 푸시를 받고 노티를 띄울지 여부 판단
- (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions options))completionHandler API_AVAILABLE(ios(10.0)) {
    NSLog(@">>>>>>>>>>> willPresentNotification notification : %@",notification.request.content.userInfo);
    // 푸시 배너를 띄워준다
    if (@available(iOS 10.0, *)) {
        completionHandler(UNNotificationPresentationOptionAlert | UNNotificationPresentationOptionBadge | UNNotificationPresentationOptionSound);
    }
}

// 유저가 노티피케이션을 클릭해서 앱으로 진입 시 처리
- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void(^)(void))completionHandler API_AVAILABLE(ios(10.0)) {
    NSLog(@">>>>>>>>>>> didReceiveNotificationResponse notification : %@",response.notification.request.content.userInfo);
    // 푸시 알림
    [[PushHepler getInstance] setPushUrlFromApnsPayload:response.notification.request.content.userInfo];
    [[NSNotificationCenter defaultCenter] postNotificationName:kApnsNoti object:self];
    if (@available(iOS 10.0, *)) {
        completionHandler();
    }
}

#pragma mark - 푸시셋팅

// 최초 apns 셋팅
-(void)initApnsSet
{
    if (@available(iOS 10_0, *)) {
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        center.delegate = self;
        [center requestAuthorizationWithOptions:(UNAuthorizationOptionSound | UNAuthorizationOptionAlert | UNAuthorizationOptionBadge) completionHandler:^(BOOL granted, NSError * _Nullable error){
            if(!error){
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[UIApplication sharedApplication] registerForRemoteNotifications];
                });
            }
        }];
    } else {
        // ios 8인 경우 - APNS서버에 Push토큰 요청
        if ([[UIApplication sharedApplication] respondsToSelector:@selector(registerForRemoteNotifications)]) {
            [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
            // didRegisterUserNotificationSettings 에서 이후 처리
        }
    }
}

#pragma mark - 앱진입관리

- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<NSString *,id> *)options
{
    NSLog(@">>>>>>>> openURL : [%@], [%@], [%@]", app.description, url.scheme, options);
    if([url.scheme isEqualToString:@"hybridframe"]) {
        return YES;
    }
    return NO;
}

@end

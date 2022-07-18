//
//  WebVC
//  ods
//
//  Created by Mac on 2018. 5. 10..
//  Copyright © 2018년 Mac. All rights reserved.
//

#import "WebVC.h"
#import "WkWebHelper.h"
#import "NSString+Replace.h"
#import "PushHepler.h"
#import "ZoomOnlyImgVC.h"
#import "FileWebVC.h"
#import "RefreshWKWebV.h"

#define talkHeight 31.0
#define chatInitConstant 15.0
#define chatBottomConstant -70.0

@interface WebVC () <WKNavigationDelegate, WKUIDelegate, WKScriptMessageHandler>
{
    WkWebHelper *wkWebHelper;
    NSMutableArray *createdWKWebViews; // 생성된 웹뷰들
}

@property (weak, nonatomic) IBOutlet UIView *wkContainer;
@property (weak, nonatomic) IBOutlet UIProgressView *wkProgV;

@end

@implementation WebVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    wkWebHelper = [[WkWebHelper alloc] init];
    createdWKWebViews = [NSMutableArray array];
    
    [self createMainWebView];
    
    // 푸시 진입 시 처리
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showPush:) name:kApnsNoti object:nil];
}

- (BOOL)prefersStatusBarHidden {
    return NO;
}

#pragma mark - 푸시, 링크, 도메인 관리

-(void)showPush:(NSNotification *)notification
{
    // 만약 child 웹뷰가 있다면 모두 삭제한다.
    [self removeAllChildWebView];
    // push url 로드
    if([PushHepler getInstance].pushUrl.length>0) {
        [wkWebHelper loadCustomRequest:[self curWebView] requestStr:[PushHepler getInstance].pushUrl];
    }
}

#pragma mark - 웹뷰 관련

- (void)createMainWebView
{
    // 모든 웹뷰를 삭제하고 메인 웹뷰를 생성한다.
    [self removeAllWebView];
    
    WKWebViewConfiguration *webViewConfig = [[WKWebViewConfiguration alloc] init];
    webViewConfig.preferences.javaScriptCanOpenWindowsAutomatically = YES;
    
    // window close 처리
    WKUserContentController *userContentController = [[WKUserContentController alloc] init];
    // window.close 처리를 위한 스크립트
    [wkWebHelper windowCloseScript:userContentController];
    
    // 브릿지 선언
    [userContentController addScriptMessageHandler:self name:@"getDeviceInfo"];
    [userContentController addScriptMessageHandler:self name:@"showToast"];
    [userContentController addScriptMessageHandler:self name:@"openBrowser"];
    [userContentController addScriptMessageHandler:self name:@"startDownload"];
    [userContentController addScriptMessageHandler:self name:@"showImageViewer"];
    
    webViewConfig.userContentController = userContentController;
    
    // 웹뷰를 셋팅 후 현재 웹뷰 처리
    RefreshWKWebV *wkWebView = [[RefreshWKWebV alloc] initWithFrame:CGRectZero configuration:webViewConfig];
    [createdWKWebViews addObject:wkWebView];
    
    [self setWebVSettingDelegate:[self curWebView]];
    [_wkContainer addSubview:[self curWebView]];
    [[self curWebView] fill_parent];
    
    // user agent 값을 수정한 뒤 웹을 로드한다.
    [[ServiceManager sharedInstance] changeUserAgent:[self curWebView] completion:^(void) {
        // user agent 수정 후 최초 페이지를 로드한다.
        [self startFirstLoad];
    }];
}

// wkwebview의 delegate와 settring 처리 공통
-(void)setWebVSettingDelegate:(WKWebView *)webV {
    webV.navigationDelegate = self;
    webV.UIDelegate = self;
    //    webV.scrollView.delegate = self;
    // progress bar 처리
    [webV addObserver:self forKeyPath:NSStringFromSelector(@selector(estimatedProgress)) options:NSKeyValueObservingOptionNew context:NULL];
}

// 최초 시작
-(void)startFirstLoad
{
    // 만약 link로 들어온 경우 param 값이 있는지 확인하고 있다면 param을 로드하고 아니면 홈페이지로 이동한다.
    NSString *pushUrl = [PushHepler getInstance].pushUrl;
    if(pushUrl.length>0 && [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:pushUrl]])
    {
        // link url 로드
        [wkWebHelper loadCustomRequest:[self curWebView] requestStr:pushUrl];
        // 로드 후 초기화 한다.
        [[PushHepler getInstance] initPushUrl];
    }
    // 링크값이 없는 경우 홈페이지를 로드한다.
    else
    {
        // 홈페이지 로드
        [wkWebHelper loadCustomRequest:[self curWebView] requestStr:[[ServerURLHelper getInstance] getHomeURL]];
    }
}

// 현재 웹뷰를 가져온다.
-(RefreshWKWebV *)curWebView {
    if(createdWKWebViews.count==0)
        return nil;
    else
        return [createdWKWebViews objectAtIndex:(createdWKWebViews.count-1)];
}

// 모든 웹뷰를 삭제한다.
-(void)removeAllWebView {
    // 만약 child 웹뷰가 있다면 모두 삭제하고 base 웹뷰에 delegate 셋팅을 한다.
    __block NSArray *webArr = createdWKWebViews;
    for (WKWebView *child in webArr) {
        [child removeObserver:self forKeyPath:NSStringFromSelector(@selector(estimatedProgress))];
        [child removeFromSuperview];
    }
    [createdWKWebViews removeAllObjects];
}

// 모든 child 웹뷰를 삭제한다.
-(void)removeAllChildWebView {
    // 만약 child 웹뷰가 있다면 모두 삭제하고 base 웹뷰에 delegate 셋팅을 한다.
    __block NSArray *webArr = createdWKWebViews;
    NSInteger lastIndex = webArr.count-1;
    for (NSInteger i=0; i<lastIndex; i++) {
        [self removeWebViewAtIndex:lastIndex-i];
    }
}

// 해당 인덱스의 웹뷰를 삭제하고 하위 웹뷰에 delegate를 연결한다.
-(void)removeWebViewAtIndex:(NSInteger)targetIndex
{
    // base 웹은 삭제 할수 없다.
    if(targetIndex==0) return;
    WKWebView *child = [createdWKWebViews objectAtIndex:targetIndex];
    // 해당뷰를 삭제
    [child removeFromSuperview];
    // 배열에서 인스턴스 삭제
    [createdWKWebViews removeObject:child];
    // 이전 WkWebView Delegate와 Setting 처리
    WKWebView *curView = [createdWKWebViews objectAtIndex:[createdWKWebViews count]-1];
    [self setWebVSettingDelegate:(WKWebView *)curView];
}

#pragma mark - UIViewController

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:NSStringFromSelector(@selector(estimatedProgress))]) {
        [self.wkProgV setAlpha:1.0f];
        [self.wkProgV setProgress:[self curWebView].estimatedProgress animated:YES];
        
        if([self curWebView].estimatedProgress >= 1.0f) {
            [UIView animateWithDuration:0.3 delay:0.3 options:UIViewAnimationOptionCurveEaseOut animations:^{
                [self.wkProgV setAlpha:0.0f];
            } completion:^(BOOL finished) {
                [self.wkProgV setProgress:0.0f animated:NO];
            }];
        }
    }
    else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - WKNavigationDelegate
    
- (void)webViewWebContentProcessDidTerminate:(WKWebView *)webView {
    [webView reload];
}
    
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(null_unspecified WKNavigation *)navigation {
    NSLog(@">>>>>>> WKWebView didStartProvisionalNavigation");
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(null_unspecified WKNavigation *)navigation
{
    NSLog(@">>>>>>> WKWebView didFinishNavigation");
    [[self curWebView] stopRefreshUI];
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler
{
    NSLog(@">>>>>>> WKWebView decidePolicyForNavigationAction");
    
    if (navigationAction.request.URL == nil) {
        decisionHandler(WKNavigationActionPolicyCancel);
        return;
    }
    
    // 전화앱으로 연결
    if([navigationAction.request.URL.scheme isEqualToString:@"tel"]||[navigationAction.request.URL.scheme isEqualToString:@"mailto"]) {
        [[UIApplication sharedApplication] openURL:navigationAction.request.URL];
        decisionHandler(WKNavigationActionPolicyCancel);
        return;
    }
    
    NSString *originalURL = navigationAction.request.URL.absoluteString;
    NSLog(@">>>>>>> WKWebView decidePolicyForNavigationAction original url : %@", originalURL);
    
    // createdWKWebViews base 웹뷰는 삭제할 수 없다.
    if([createdWKWebViews count]>1 && [originalURL isEqualToString:@"back://"]){
        // 현재 WkWebview 삭제 및 Delegate와 Setting 처리
        [self removeWebViewAtIndex:[createdWKWebViews count]-1];
        decisionHandler(WKNavigationActionPolicyCancel);
        return;
    }
    
    decisionHandler(WKNavigationActionPolicyAllow);
}

- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error
{
    NSLog(@">>>>>>> WKWebView didFailProvisionalNavigation");
    [[self curWebView] stopRefreshUI];
}
    
- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler
{
    NSLog(@">>>>>>> WKWebView decidePolicyForNavigationResponse");
    decisionHandler(WKNavigationResponsePolicyAllow);
}

#pragma mark - WKScriptMessageHandler

// 브릿지 처리
- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    
    NSLog(@">>>>>>> WKWebView userContentController bridge name : %@", message.name);
    NSString *jsonTxt = message.body;
    NSDictionary *bridInfo = [AqUtil jsonStrToDic:jsonTxt];
    
    // 토스트 보여주기
    if([message.name isEqualToString:@"showToast"]) {
        NSString *msg = bridInfo[@"msg"];
        [ToastMessageView toastInView:aqDelegate.window withText:msg];
    }
    // 브라우저 열기
    else if([message.name isEqualToString:@"openBrowser"]) {
        NSString *url = bridInfo[@"url"];
        if([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:url]]) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
        }
    }
    // 디바이스 정보 요청
    else if([message.name isEqualToString:@"startDownload"]) {
        NSString *fileUrl = bridInfo[@"url"];
        FileWebVC *fileVC =[self.storyboard instantiateViewControllerWithIdentifier:@"FileWebVC"];
        [fileVC setLoadFileUrl:fileUrl];
        [self presentViewController:fileVC animated:YES completion:nil];
    }
    // 이미지 보여주기
    else if([message.name isEqualToString:@"showImageViewer"]) {
        NSString *imgUrl = bridInfo[@"url"];
        ZoomOnlyImgVC *imgVC =[self.storyboard instantiateViewControllerWithIdentifier:@"ZoomOnlyImgVC"];
        [imgVC setImgUrl:imgUrl];
        [self presentViewController:imgVC animated:YES completion:^{
        }];
    }
}

#pragma mark - WKUIDelegate

// opener로 열린 웹뷰 처리
- (WKWebView *)webView:(WKWebView *)webView createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration forNavigationAction:(WKNavigationAction *)navigationAction windowFeatures:(WKWindowFeatures *)windowFeatures {
    
    NSLog(@">>>>>>>> WKWebView createWebViewWithConfiguration url: %@", navigationAction.request.URL.absoluteString);
    
    // child webview 추가
    RefreshWKWebV *newWebView = [[RefreshWKWebV alloc] initWithFrame:CGRectZero configuration:configuration];
    [self setWebVSettingDelegate:newWebView];
    [_wkContainer addSubview:newWebView];
    [newWebView fill_parent];
    
    // array에 추가한다.
    [createdWKWebViews addObject:newWebView];
    
    return newWebView;
}

- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler
{
//    NSString *hostString = webView.URL.host;
//    NSLog(@">>>>> host : %@", hostString);
    dispatch_async(dispatch_get_main_queue(), ^(){
        [CommonCustomPopup showDefaultAlert:message callback:^(NSInteger btnIndex){
            @try {
                completionHandler();
            } @catch (NSException *exception) {
                NSLog(@">>>>>>>>>> %s %@", __func__, exception.description);
            }
        }];
    });
}

- (void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL))completionHandler
{
    dispatch_async(dispatch_get_main_queue(), ^(){
        [CommonCustomPopup showDefaultConfirm:message callback:^(NSInteger btnIndex){
            @try {
                if(btnIndex==onCustomPopupConfirm) {
                    completionHandler(YES);
                } else {
                    completionHandler(NO);
                }
            } @catch (NSException *exception) {
                NSLog(@">>>>>>>>>> %s %@", __func__, exception.description);
            }
        }];
    });
}

@end

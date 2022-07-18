//
//  FileWebVC.m
//  ods
//
//  Created by Mac on 2018. 9. 4..
//  Copyright © 2018년 Mac. All rights reserved.
//

#import "FileWebVC.h"

@interface FileWebVC ()

@property (retain, nonatomic) WKWebView *fileWv;

@property (weak, nonatomic) IBOutlet UIView *wkContainer;
@property (weak, nonatomic) IBOutlet UIProgressView *wkProgV;

@end

@implementation FileWebVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if(self.loadFileUrl.length>0)
    {
        WKWebViewConfiguration *webViewConfig = [[WKWebViewConfiguration alloc] init];
        self.fileWv = [[WKWebView alloc] initWithFrame:CGRectZero configuration:webViewConfig];
        [self.wkContainer addSubview:self.fileWv];
        [self.fileWv fill_parent];
        
//        self.fileWv.navigationDelegate = self;
//        self.fileWv.UIDelegate = self;
//        self.fileWv.scrollView.delegate = self;
        self.fileWv.scrollView.backgroundColor = [UIColor whiteColor];
        self.fileWv.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.fileWv.backgroundColor = [UIColor whiteColor];
        
        // 프로그래스 색상 적용
//        self.wkProgV.tintColor = [[ServerURLHelper getInstance] getDomainColor];
        self.wkProgV.alpha = 0;
        self.wkProgV.progress = 0;
        
        // progress bar 처리
        [self.fileWv addObserver:self forKeyPath:NSStringFromSelector(@selector(estimatedProgress)) options:NSKeyValueObservingOptionNew context:NULL];
        
        // user agent 값을 수정한 뒤 웹을 로드한다.
        [[ServiceManager sharedInstance] changeUserAgent:self.fileWv completion:^(void) {
            // user agent 수정 후 최초 페이지를 로드한다.
            [self startFirstLoad];
        }];
    }
}

-(void)startFirstLoad
{
    NSString *svcUrl = self.loadFileUrl;
    svcUrl = [svcUrl stringByAddingPercentEncodingWithAllowedCharacters:NSCharacterSet.URLQueryAllowedCharacterSet];
    NSURL *loadUrl = [NSURL URLWithString:svcUrl];
    if([[UIApplication sharedApplication] canOpenURL:loadUrl]) {
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:loadUrl];
        [self.fileWv loadRequest:request];
    }
}

- (IBAction)onClose:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:Nil];
}

#pragma mark - UIViewController

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:NSStringFromSelector(@selector(estimatedProgress))]) {
        [self.wkProgV setAlpha:1.0f];
        [self.wkProgV setProgress:self.fileWv.estimatedProgress animated:YES];
        
        if(self.fileWv.estimatedProgress >= 1.0f) {
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

@end

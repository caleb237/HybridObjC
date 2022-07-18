//
//  ZoomOnlyImgVC
//  ods
//
//  Created by Mac on 2018. 8. 24..
//  Copyright © 2018년 Mac. All rights reserved.
//

#import "ZoomOnlyImgVC.h"
#import "UIImageView+WebCache.h"

@interface ZoomOnlyImgVC () <UIScrollViewDelegate>

@property (nonatomic,weak) IBOutlet UIScrollView *picSV;
@property (nonatomic,retain) UIImageView *picV;

@end

@implementation ZoomOnlyImgVC

- (void)viewDidLoad {
    [super viewDidLoad];
 
    // 이미지뷰 셋팅
    self.picV = [[UIImageView alloc] initWithFrame:CGRectZero];
    self.picV.contentMode = UIViewContentModeScaleAspectFit;
    self.picV.clipsToBounds = YES;
    
    // 스크롤뷰 셋팅
    [self.picSV sizeToFit];
    [self.picSV addSubview:self.picV];
    [self.picV fill_parent];
    self.picSV.bounces = NO;
    self.picSV.showsVerticalScrollIndicator = NO;
    self.picSV.showsHorizontalScrollIndicator = NO;
    self.picSV.delegate = self;
    self.picSV.minimumZoomScale = 1.0;
    self.picSV.maximumZoomScale = 3.0;
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    // center 맞추기
    CGPoint centerPoint = CGPointMake(CGRectGetMidX(self.picSV.bounds),CGRectGetMidY(self.picSV.bounds));
    [self view:self.picV setCenter:centerPoint];
    self.picSV.contentSize = self.picV.frame.size;
    
    // 이미지 로드
    if(self.imgUrl.length>0) {
        NSURL *imgNsUrl = [NSURL URLWithString:self.imgUrl];
        if([[UIApplication sharedApplication] canOpenURL:imgNsUrl]) {
            [self.picV sd_setImageWithURL:imgNsUrl completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            }];
        }
    }
}

// 화면 닫기
-(IBAction)onClose:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^{
    }];
}

- (void)view:(UIView*)view setCenter:(CGPoint)centerPoint
{
    CGRect vf = view.frame;
    CGPoint co = self.picSV.contentOffset;
    
    CGFloat x = centerPoint.x - vf.size.width / 2.0;
    CGFloat y = centerPoint.y - vf.size.height / 2.0;
    
    if(x < 0)
    {
        co.x = -x;
        vf.origin.x = 0.0;
    }
    else
    {
        vf.origin.x = x;
    }
    if(y < 0)
    {
        co.y = -y;
        vf.origin.y = 0.0;
    }
    else
    {
        vf.origin.y = y;
    }
    
    view.frame = vf;
    self.picSV.contentOffset = co;
}

- (UIView*)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.picV;
}

- (void)scrollViewDidZoom:(UIScrollView *)sv
{
    UIView *zoomView = [sv.delegate viewForZoomingInScrollView:sv];
    CGRect zvf = zoomView.frame;
    if(zvf.size.width < sv.bounds.size.width)
    {
        zvf.origin.x = (sv.bounds.size.width - zvf.size.width) / 2.0;
    }
    else
    {
        zvf.origin.x = 0.0;
    }
    if(zvf.size.height < sv.bounds.size.height)
    {
        zvf.origin.y = (sv.bounds.size.height - zvf.size.height) / 2.0;
    }
    else
    {
        zvf.origin.y = 0.0;
    }
    zoomView.frame = zvf;
}

@end

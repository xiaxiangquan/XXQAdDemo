//
//  WJLaunchAdMonitor.m
//  WJRenovationB
//
//  Created by 夏祥全 on 16/6/2.
//  Copyright © 2016年 网家科技. All rights reserved.
//

#import "WJLaunchAdMonitor.h"
#import "UIImage+WJLaunchImage.h"
#import "WJAdServiceManager.h"

@import UIKit.UIScreen;
@import UIKit.UIImage;
@import UIKit.UIImageView;
@import UIKit.UIButton;
@import UIKit.UILabel;
@import UIKit.UIColor;
@import UIKit.UIFont;
@import QuartzCore.CALayer;

typedef NS_ENUM(NSInteger, WJLaunchAdProcess) {
    WJLaunchAdProcessFailed = -1,
    WJLaunchAdProcessNone,
    WJLaunchAdProcessLoading,
    WJLaunchAdProcessSuccess,
};

#define AD_BUTTONSKIP_FONTSIZE      14
#define AD_BUTTONSKIP_WIDTH         roundf(AD_BUTTONSKIP_FONTSIZE * 4)
#define AD_BUTTONSKIP_HEIGHT        roundf(AD_BUTTONSKIP_FONTSIZE * 2.5)

#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height

NSString *WJLaunchAdDetailDisplayNotification = @"WJShowLaunchAdDetailDisplayNotification";

static WJLaunchAdMonitor *monitor = nil;

@interface WJLaunchAdMonitor ()<UIWebViewDelegate>
{
    dispatch_source_t _timer;
    NSTimeInterval _delayTimer;
}
@property (nonatomic, strong) UIWebView *webView;
@property (nonatomic, strong) UIImageView *launchImageView;
@property (nonatomic, strong) NSMutableData *imgData;
@property (nonatomic, assign) WJLaunchAdProcess process;
@property (nonatomic, strong) NSURL *detailUrl;
@property (nonatomic, assign) NSTimeInterval delayTimer;

@end

@implementation WJLaunchAdMonitor

+ (void)showAtView:(UIView *)container {
    
    [[self defaultMonitor] loadImageAtPath];
    
    monitor.detailUrl = nil;
    if (monitor.process == WJLaunchAdProcessFailed) {
        return;
    }
    [self showImageOnView:container];
}

+ (void)showImageOnView:(UIView *)container {
    
    CGRect f = [UIScreen mainScreen].bounds;
    f.size.height -= 0;
    [monitor.webView setFrame:f];
    monitor.process = WJLaunchAdProcessLoading;
    
    monitor.webView.contentMode = UIViewContentModeScaleAspectFill;
    monitor.webView.clipsToBounds = YES;
    [container addSubview:monitor.webView];
    [container bringSubviewToFront:monitor.webView];
    
    const CGFloat btnWidth = AD_BUTTONSKIP_WIDTH;
    const CGFloat btnHeight = AD_BUTTONSKIP_HEIGHT;
    const CGSize btnSize = CGSizeMake(btnWidth, btnHeight);
    const CGFloat radius = 5;

    UIButton *detailBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [detailBtn setFrame:CGRectMake(SCREEN_WIDTH - (btnWidth+20), 35, btnWidth, btnHeight)];
    [detailBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    detailBtn.alpha = 0.0f;
    [detailBtn addTarget:self action:@selector(passAdDetail:) forControlEvents:UIControlEventTouchUpInside];
    [monitor.webView addSubview:detailBtn];
    [monitor.webView bringSubviewToFront:detailBtn];
    
    [container addSubview:monitor.launchImageView];
    [container bringSubviewToFront:monitor.launchImageView];
    [monitor.launchImageView setFrame:container.frame];
}

+ (instancetype)defaultMonitor {
    @synchronized (self) {
        if (!monitor) {
            monitor = [[WJLaunchAdMonitor alloc] init];
            monitor.webView = [[UIWebView alloc] init];
            [monitor.webView setBackgroundColor:[UIColor clearColor]];
            monitor.webView.scrollView.scrollEnabled = NO;
            monitor.webView.opaque = NO;
            monitor.webView.delegate = monitor;
            
            monitor.launchImageView = [[UIImageView alloc] initWithImage:[UIImage wjGetLaunchImage]];
        }
        return monitor;
    }
}

+ (BOOL)validatePath:(NSString *)path {
    NSURL *url = [NSURL URLWithString:path];
    return url != nil;
}


+ (void)passAdDetail:(UIButton *)sender {

    [UIView animateWithDuration:0.3 animations:^{
        [monitor.webView setAlpha:0.0];
    } completion:^(BOOL finished) {
        [monitor.webView removeFromSuperview];
    }];
}

- (void)loadImageAtPath {
    
    NSDictionary *adDataInfo = [WJAdServiceManager adInfo];
    if (!adDataInfo) {
        WJAdServiceManager *service = [[WJAdServiceManager alloc] init];
        [service loadAdWithSuccess:^(NSDictionary *success) {
            
            if (![[success allKeys] containsObject:@"data"]
                || [success[@"data"] count] == 0
                || [success[@"code"] integerValue] != 1000) {
                [service removeAdData];
            } else {
                [service saveAdData:success];
                [self loadWebViewWithData:success[@"data"]];
            }
            
        } failure:^(NSInteger errorCode, NSString *errorDes) {
            self.process = WJLaunchAdProcessFailed;
            [self removeLaunchImageWithWebView];
        }];
    } else {
        NSDictionary *info = adDataInfo[@"data"];
        [self loadWebViewWithData:info];
    }
}

- (void)loadWebViewWithData:(NSDictionary *)adInfo {
    monitor.delayTimer = [adInfo[@"flash_time"] integerValue];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:adInfo[@"url"]]
                                                  cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                              timeoutInterval:2];
    [monitor.webView loadRequest:request];
}

- (void)removeLaunchImageWithWebView {
    [UIView animateWithDuration:0.2 animations:^{
        [monitor.launchImageView setAlpha:0.0f];
    } completion:^(BOOL finished) {
        [monitor.launchImageView removeFromSuperview];
        [monitor.webView removeFromSuperview];
    }];
}

#pragma mark - UIWebViewDelegate
- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [monitor.launchImageView setAlpha:1.0f];
    [UIView animateWithDuration:0.4 animations:^{
        [monitor.launchImageView setAlpha:0.0f];
    } completion:^(BOOL finished) {
        [monitor.launchImageView removeFromSuperview];
        [self onTimer];
    }];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(nullable NSError *)error {
    [self removeLaunchImageWithWebView];
}

// 倒计时
- (void)onTimer {
    
    UIButton *btn;
    for (UIView *view in monitor.webView.subviews) {
        if ([view isKindOfClass:[UIButton class]]) {
            btn = (UIButton *)view;
            btn.alpha = 1.0;
        }
    }
    NSString *btnTitle = [NSString stringWithFormat:@"跳过 %.f",_delayTimer];
    [btn setTitle:btnTitle forState:UIControlStateNormal];
    __block CGFloat sec = _delayTimer;
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_queue_t mainQueue = dispatch_get_main_queue();
    _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    dispatch_source_set_timer(_timer, DISPATCH_TIME_NOW, 1.0 * NSEC_PER_SEC, 0 * NSEC_PER_SEC);
    
    dispatch_source_set_event_handler(_timer, ^{
        
        dispatch_async(mainQueue, ^{
            NSString *btnTitle = [NSString stringWithFormat:@"跳过 %.f",_delayTimer--];
            [btn setTitle:btnTitle forState:UIControlStateNormal];
            
            if (sec == 0) {
                [UIView animateWithDuration:0.4 animations:^{
                    [monitor.webView setAlpha:0.0];
                } completion:^(BOOL finished) {
                    [monitor.webView removeFromSuperview];
                }];
                dispatch_source_cancel(_timer);
            }
            sec--;
            dispatch_source_set_cancel_handler(_timer, ^{

            });
        });
    });
    dispatch_resume(_timer);
}


- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    
    if (UIWebViewNavigationTypeOther == navigationType) {
        
    } else {
        [[NSNotificationCenter defaultCenter] postNotificationName:WJLaunchAdDetailDisplayNotification object:request.URL];
        [UIView animateWithDuration:0.3 animations:^{
            [monitor.webView setAlpha:0.0];
        } completion:^(BOOL finished) {
            [monitor.webView removeFromSuperview];
        }];
    }
    return YES;
}

@end

















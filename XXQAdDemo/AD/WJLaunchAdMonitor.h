//
//  WJLaunchAdMonitor.h
//  WJRenovationB
//
//  Created by 夏祥全 on 16/6/2.
//  Copyright © 2016年 网家科技. All rights reserved.
//

#import <Foundation/Foundation.h>
@import UIKit.UIView;
@import UIKit.UIWebView;

extern NSString *WJLaunchAdDetailDisplayNotification;

@interface WJLaunchAdMonitor : NSObject<UIWebViewDelegate>

@property (nonatomic, strong) void(^clickAdDetailBtnBlock)(void);

+ (void)showAtView:(UIView *)container;


@end

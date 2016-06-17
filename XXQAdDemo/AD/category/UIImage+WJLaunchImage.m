//
//  UIImage+WJLaunchImage.m
//  WJBuildingMaterialsB
//
//  Created by 夏祥全 on 16/6/16.
//  Copyright © 2016年 xiaxiangquan. All rights reserved.
//

#import "UIImage+WJLaunchImage.h"

@implementation UIImage (WJLaunchImage)

+ (NSString *)wjGetLaunchImageName {
    NSString *viewOrientation = @"Portrait";
    if (UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation])) {
        viewOrientation = @"Landscape";
    }
    NSString *launchImageName = nil;
    NSArray *imagesDict = [[[NSBundle mainBundle] infoDictionary] valueForKey:@"UILaunchImages"];
    CGSize viewSize = [[UIApplication sharedApplication] keyWindow].bounds.size;
    for (NSDictionary *dict in imagesDict) {
        CGSize imageSize = CGSizeFromString(dict[@"UILaunchImageSize"]);
        if (CGSizeEqualToSize(imageSize, viewSize) && [viewOrientation isEqualToString:dict[@"UILaunchImageOrientation"]]) {
            launchImageName = dict[@"UILaunchImageName"];
        }
    }
    return launchImageName;
}

+ (UIImage *)wjGetLaunchImage {
    return [UIImage imageNamed:[UIImage wjGetLaunchImageName]];
}

@end

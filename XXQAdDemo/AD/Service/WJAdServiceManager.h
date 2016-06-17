//
//  WJAdServiceManager.h
//  WJBuildingMaterialsB
//
//  Created by 夏祥全 on 16/6/16.
//  Copyright © 2016年 xiaxiangquan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WJAdServiceManager : NSObject

- (void)loadAdWithSuccess:(void(^)(NSDictionary *))success
                  failure:(void(^)(NSInteger errorCode, NSString *errorDes))failure;
- (void)saveAdData:(NSDictionary *)data;
- (void)removeAdData;
+ (NSDictionary *)adInfo;

@end

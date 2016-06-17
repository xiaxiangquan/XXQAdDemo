//
//  WJAdServiceManager.m
//  WJBuildingMaterialsB
//
//  Created by 夏祥全 on 16/6/16.
//  Copyright © 2016年 xiaxiangquan. All rights reserved.
//

#import "WJAdServiceManager.h"
#import "AFHTTPSessionManager.h"
#import "JSONKit.h"

@interface WJAdServiceManager()

@property (nonatomic, strong) AFHTTPSessionManager *httpSession;

@end


@implementation WJAdServiceManager

#pragma mark - life cycle
- (instancetype)init {
    self = [super init];
    if (self) {
        
    }
    return self;
}

#pragma mark - setter or getter
- (AFHTTPSessionManager *)httpSession {
    if (!_httpSession) {
        _httpSession = [[AFHTTPSessionManager alloc] initWithBaseURL:nil];
        // 安全策略
        _httpSession.securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];
        // 响应序列化
        _httpSession.responseSerializer = [AFHTTPResponseSerializer serializer];
        // 设置超时时间
        // 设置超时 时长
        [_httpSession.responseSerializer willChangeValueForKey:@"timeoutInterval"];
        _httpSession.requestSerializer.timeoutInterval = 2;
        [_httpSession.requestSerializer didChangeValueForKey:@"timeoutInterval"];
    }
    return _httpSession;
}

#pragma mark - pubilc method
- (void)loadAdWithSuccess:(void(^)(NSDictionary *))success
                  failure:(void(^)(NSInteger errorCode, NSString *errorDes))failure {
    NSString *url = @"http://pic.jiajuol.com/api/iphone/0700/pic_photo.php?act=get_first_html&app=pic_photo&v=7.0";
    [self.httpSession GET:url parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {
        
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *dictInfo = [responseObject objectFromJSONData];
        if (success) {
            success(dictInfo);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (failure) {
            failure(error.code, error.localizedDescription);
        }
    }];
}

#pragma mark - pubilc method
- (void)saveAdData:(NSDictionary *)data {
    [data writeToFile:[WJAdServiceManager launchPagePath] atomically:YES];
}

- (void)removeAdData {
    [[NSFileManager defaultManager] removeItemAtPath:[WJAdServiceManager launchPagePath] error:nil];
}

+ (NSDictionary *)adInfo {
    return [NSDictionary dictionaryWithContentsOfFile:[WJAdServiceManager launchPagePath]];
}

+ (NSString *)launchPagePath {
    NSString *path = [WJAdServiceManager libAppSupportPath];
    return [path stringByAppendingPathComponent:@"LaunchPage.plist"];
}

+ (NSString *)libAppSupportPath {
    static NSString *appSupportPath = nil;
    if (!appSupportPath) {
        appSupportPath = [NSSearchPathForDirectoriesInDomains(NSApplicationDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        if (![WJAdServiceManager checkAndCreatePath:appSupportPath]) {
            return nil;
        }
    }
    return appSupportPath;
}

+ (BOOL)checkAndCreatePath:(NSString *)path {
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    if ([fileMgr fileExistsAtPath:path]) {
        return YES;
    }
    return [fileMgr createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:NULL];
}

@end




















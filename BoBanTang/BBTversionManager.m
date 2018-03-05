//
//  BBTversionManager.m
//  波板糖
//
//  Created by zzddn on 2018/3/5.
//  Copyright © 2018年 100steps. All rights reserved.
//

#import "BBTversionManager.h"
#import <AFHTTPSessionManager.h>

/*
 type : normal|critical|info
 */

//app的url
NSString *appStoreURL = @"https://itunes.apple.com/lookup?id=625954338";
NSString *URLForVersionOnServer = @"http://apiv2.100steps.net/update/ios/latest";
static NSString *versionUpdateNotificationName = @"versionUpdateNotification";

@interface BBTversionManager ()

@property (readonly,nonatomic,strong) NSDictionary<NSString *, NSNumber *> *versionUpdateDictionary;

@end

@implementation BBTversionManager

+(instancetype)sharedManager{
    static BBTversionManager *versionManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        versionManager = [BBTversionManager new];
    });
    return versionManager;
}

- (NSDictionary *)versionUpdateDictionary{
    return @{
             @"normal":[NSNumber numberWithInteger:BBTNormal],
             @"critical":[NSNumber numberWithInteger:BBTCritical],
             @"info":[NSNumber numberWithInteger:BBTInfo]
             };
}

- (void)checkCurrentVersion{
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json",@"text/json",nil];
    
    [manager GET:URLForVersionOnServer parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (responseObject[@"version"]){
            
            //获取本地的app版本
            NSDictionary *infoDic = [[NSBundle mainBundle]infoDictionary];
            NSString *currentVersion = [infoDic objectForKey:@"CFBundleShortVersionString"];
            self.currentVersion = currentVersion;
            
            //获取服务器的app版本
            self.serverVersion = responseObject[@"version"];
            
            //获取升级type
            self.versionUpdateType = self.versionUpdateDictionary[responseObject[@"type"]].integerValue;
            
            //配置属性
            self.bbtAppURL = responseObject[@"url"];
            self.title = responseObject[@"title"];
            self.content = responseObject[@"content"];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:versionUpdateNotificationName object:nil];
        }
    } failure:nil];
    
}

@end

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
NSString *userHasReadName = @"userHasRead";

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
/*
- (BOOL)userHasRead{
    if ([[NSUserDefaults standardUserDefaults] valueForKey:userHasReadName]){
        NSNumber *hasRead = [[NSUserDefaults standardUserDefaults] valueForKey:userHasReadName];
        _userHasRead = hasRead.boolValue;
    }else{
        _userHasRead = NO;
    }
    return _userHasRead;
}
 */

- (void)checkCurrentVersion{
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json",@"text/json",nil];
    
    [manager GET:URLForVersionOnServer parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (responseObject[@"version"]){
            
            //获取本地的app版本
            NSDictionary *infoDic = [[NSBundle mainBundle]infoDictionary];
            NSString *currentVersion = [infoDic objectForKey:@"CFBundleShortVersionString"];
            self.currentVersion = currentVersion;
            
            //获取服务器的信息
            self.serverVersion = responseObject[@"version"];
            self.versionUpdateType = self.versionUpdateDictionary[responseObject[@"type"]].integerValue;
            self.bbtAppURL = responseObject[@"url"];
            self.title = responseObject[@"title"];
            self.content = responseObject[@"content"];
            
            //对比版本信息，看看有无发通知的必要
            NSArray<NSString *> *currentVersionNumber = [self.currentVersion componentsSeparatedByString:@"."];
            NSArray<NSString *> *serverVersionNumber = [self.serverVersion componentsSeparatedByString:@"."];
            
            int currentVersionInt = 0,serverVersionInt = 0;
            
            unsigned long numberCount = currentVersionNumber.count;
            for (int i = 0; i < numberCount; i++){
                currentVersionInt += pow(10,numberCount-i-1)*currentVersionNumber[i].intValue;
                serverVersionInt += pow(10, numberCount-i-1)*serverVersionNumber[i].intValue;
            }
           
            if (serverVersionInt > currentVersionInt){
                [[NSNotificationCenter defaultCenter] postNotificationName:versionUpdateNotificationName object:nil];
            }
        }
    } failure:nil];
    
}

- (void)userAlreadyReadNoti{
    [[NSUserDefaults standardUserDefaults] setValue:@1 forKey:userHasReadName];
}

@end

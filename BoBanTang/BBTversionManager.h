//
//  BBTversionManager.h
//  波板糖
//
//  Created by zzddn on 2018/3/5.
//  Copyright © 2018年 100steps. All rights reserved.
//

#import <Foundation/Foundation.h>

static NSString *versionUpdateNotificationName = @"versionUpdateNotification";

@interface BBTversionManager : NSObject


typedef enum: NSInteger{
    BBTNormal = 0,
    BBTCritical = 1,
    BBTInfo = 2
} BBTVersionUpdateType;

@property (nonatomic,strong) NSString *currentVersion;
@property (nonatomic,strong) NSString *serverVersion;
@property (nonatomic,strong) NSString *bbtAppURL;
//@property (nonatomic) BOOL userHasRead;


@property (nonatomic) BBTVersionUpdateType versionUpdateType;
@property (nonatomic,strong) NSString *title;
@property (nonatomic,strong) NSString *content;

+ (instancetype)sharedManager;
- (void)checkCurrentVersion;
//- (void)userAlreadyReadNoti;

@end

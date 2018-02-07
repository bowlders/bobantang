//
//  BBTCurrentUserManager.h
//  BoBanTang
//
//  Created by Caesar on 16/2/5.
//  Copyright © 2016年 100steps. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BBTUser.h"

@interface BBTCurrentUserManager : NSObject

@property (strong, nonatomic) BBTUser  * currentUser;

//Set to 1 if a user is currently active.
@property (nonatomic)         BOOL       userIsActive;
@property (nonatomic)         BOOL       clubUserIsActive;

+ (instancetype) sharedCurrentUserManager;


/**
 登录验证
 */
- (void)currentUserAuthentication;

/**
 防止cookie过期的轮询
 */
- (void)performRegularLoginTask;

- (void)clubLogin;

/**
 登出。登出时会将staySignedIn从用户默认设置集中移除掉，但仍保有用户各项数据在本地
 */
- (void)logOut;


/**
 该方法用于更新用户数据，通过patch的方式

 @param parameters 字典，具体要求请见接口文档，更新方式为patch增量更新，且有cookies来标示当前用户
 */
- (void)updateUserInformationThroughPathMethodWith:(NSDictionary *) parameters;

//Keychain methods
- (void)saveCurrentUserInfo;
- (void)deleteCurrentUserInfo;
- (NSString *)loadCurrentUserName;
- (NSString *)loadCurrentUserPassWord;

@end

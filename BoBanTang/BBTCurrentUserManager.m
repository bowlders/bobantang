//
//  BBTCurrentUserManager.m
//  BoBanTang
//
//  Created by Caesar on 16/2/5.
//  refactored by Zekang on 18/2/7.
//  Copyright © 2016年 100steps. All rights reserved.
//

#import "BBTCurrentUserManager.h"
#import <AFNetworking.h>
#import <JNKeychain.h>
#import <objc/runtime.h>

@implementation BBTCurrentUserManager

//校园账号登录验证
static NSString * const checkAccountURL = @"http://apiv2.100steps.net/login";
static NSString * const updateMeURL = @"http://apiv2.100steps.net/me";

//社团管理登录验证
static NSString * const fetchUserProfileBaseURL = @"http://community.100steps.net/current/user/";
static NSString * const clubLoginBaseURL = @"http://community.100steps.net/login";

//验证的key
static NSString * const userNameKey = @"userName";
static NSString * const passWordKey = @"passWord";

NSString * kUserAuthentificationFinishNotifName = @"authenticationFinish";
NSString * kUserClubLoginFinishNotifName = @"clubLoginFinish";
NSString * finishUpdateCurrentUserInformationName = @"UpdateCurrentUserInformationFinish";

- (BBTUser *)currentUser{
    if (_currentUser == nil){
        _currentUser = [BBTUser new];
    }
    return _currentUser;
}

+ (instancetype)sharedCurrentUserManager
{
    static BBTCurrentUserManager *_manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _manager = [[BBTCurrentUserManager alloc] init];
    });
    return _manager;
}

- (void)copyToNewUserWithDic:(NSMutableDictionary *)dic{
    dic[@"password"] = self.currentUser.password;
    self.currentUser = [[BBTUser alloc] initWithDictionary:dic];
}

- (void)currentUserAuthentication
{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/html",@"application/json",nil];
    
    NSDictionary *parameters = @{@"account" : self.currentUser.account,
                                 @"password" : self.currentUser.password};
    
    [manager POST:checkAccountURL parameters:parameters progress:nil success:^(NSURLSessionTask *task, id responseObject) {
        
        if (![[responseObject allKeys] containsObject:@"status"]){
            NSMutableDictionary *responseDictionary = [[NSMutableDictionary alloc]initWithDictionary:(NSDictionary *)responseObject];
            [self copyToNewUserWithDic:responseDictionary];
            self.userIsActive = YES;
        }else{
            self.userIsActive = NO;
            
        }
        [self postUserAuthenticationFinishNotification];
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        self.userIsActive = NO;
        [self postUserAuthenticationFinishNotification];
    }];
    
    if (self.clubUserIsActive == false){
        [self clubLogin];
    }
    
    [manager invalidateSessionCancelingTasks:NO];
}

- (void)updateUserInformationThroughPathMethodWith:(NSDictionary *) parameters{
    if (parameters.count < 1){
        //也算是成功的一种
        [[NSNotificationCenter defaultCenter] postNotificationName:finishUpdateCurrentUserInformationName object:self userInfo:@{
                                                                                                                                 @"status":@"succeed"
                                                                                                                                 }];
        return;
    }
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/html",@"application/json",nil];
    [manager PATCH:updateMeURL parameters:parameters success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        //NSLog(@"PATCH--updateUserInformationSuccess!:  %@",responseObject);
        
        //如果返回status为error，也不行
        if ([[(NSDictionary *)responseObject allKeys] containsObject:@"status"]&&[responseObject[@"status"]isEqual:@"error"]){
            [[NSNotificationCenter defaultCenter] postNotificationName:finishUpdateCurrentUserInformationName object:self userInfo:@{
                                                                                                                                     @"status":@"fail"
                                                                                                                                     }];
            return;
        }
        
        //确认了服务器上的用户信息更新好了后，才进行本地信息的覆写
        //进行覆写
        [self copyToNewUserWithDic:[NSMutableDictionary dictionaryWithDictionary:responseObject]];
        [self writeToLocalDatabase];
        
        //广播
        [[NSNotificationCenter defaultCenter] postNotificationName:finishUpdateCurrentUserInformationName object:self userInfo:@{
                                                                                                                                 @"status":@"succeed"
                                                                                                                                 }];
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"PATCH--updateUserInformationError!:  %@",error);
        [[NSNotificationCenter defaultCenter] postNotificationName:finishUpdateCurrentUserInformationName object:self userInfo:@{
                                                                                                                                 @"status":@"fail"
                                                                                                                                 }];
    }];
    
}

- (void)performRegularLoginTask{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/html",@"application/json",nil];
    
    NSDictionary *parameters = @{@"account" : self.currentUser.account,
                                 @"password" : self.currentUser.password};
    [manager POST:checkAccountURL parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, NSDictionary *  _Nullable responseObject) {
        //此处的账号密码必须为正确的
        if (![[responseObject allKeys]containsObject:@"status"] || ![responseObject[@"status"] isEqual:@"error"]){
            [self copyToNewUserWithDic:[NSMutableDictionary dictionaryWithDictionary:responseObject]];
            [self writeToLocalDatabase];
        }
    } failure:nil];
}


- (void)clubLogin{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"application/json"];
    
    NSDictionary *parameters = @{@"login_name" : self.currentUser.account,
                                 @"password" : self.currentUser.password};
    
    [manager POST:clubLoginBaseURL parameters:parameters progress:nil success:^(NSURLSessionTask *task, id responseObject) {
        //NSLog(@"checkResult: %@", responseObject);
        self.clubUserIsActive = true;
        [self postUserClubLoginFinishNotification];
        //[self fetchCurrentUserProfile];
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        self.clubUserIsActive = false;
        [self postUserClubLoginFinishNotification];
    }];
    
    [manager invalidateSessionCancelingTasks:NO];
}

- (void)fetchCurrentUserProfile{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    
    NSString * fetchUserProfileURL = [NSString stringWithFormat:@"%@%ld",fetchUserProfileBaseURL,(long)self.currentUser.ID];
    [manager GET:fetchUserProfileURL parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"JSON: %@", responseObject);
        
    }failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"Error: %@", error);
    }];
}


- (void)logOut
{
    BBTUser *emptyUser = [BBTUser new];
    self.currentUser = emptyUser;
    self.userIsActive = NO;
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"staySignedIn"];
    self.clubUserIsActive = false;
}

- (void)postUserAuthenticationFinishNotification
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kUserAuthentificationFinishNotifName
                                                        object:self];
}

- (void)postUserClubLoginFinishNotification{
    [[NSNotificationCenter defaultCenter] postNotificationName:kUserClubLoginFinishNotifName object:self];
}

- (void)saveCurrentUserInfo
{
    //保存账户密码的同时，也进行登录维持的确认
    [JNKeychain saveValue:self.currentUser.account forKey:userNameKey];
    [JNKeychain saveValue:self.currentUser.password forKey:passWordKey];
    [[NSUserDefaults standardUserDefaults] setValue:@1 forKey:@"staySignedIn"];
    [self writeToLocalDatabase];
}

- (NSString *)loadCurrentUserName
{
    return [JNKeychain loadValueForKey:userNameKey];
}

- (NSString *)loadCurrentUserPassWord
{
    return [JNKeychain loadValueForKey:passWordKey];
}

- (void)deleteCurrentUserInfo
{
    //删除保存的用户信息，同时也将登录维持给移除掉
    [JNKeychain deleteValueForKey:userNameKey];
    [JNKeychain deleteValueForKey:passWordKey];
    [JNKeychain deleteValueForKey:@"accountName"];
    [JNKeychain deleteValueForKey:@"accountNick"];
    [JNKeychain deleteValueForKey:@"accountSex"];
    [JNKeychain deleteValueForKey:@"accountGrade"];
    [JNKeychain deleteValueForKey:@"accountCollege"];
    [JNKeychain deleteValueForKey:@"accountPhone"];
    [JNKeychain deleteValueForKey:@"accountDormitory"];
    [JNKeychain deleteValueForKey:@"accountQq"];
    [JNKeychain deleteValueForKey:@"accountAvatar"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"staySignedIn"];
    
}

- (void)writeToLocalDatabase{
    
    //如果发现有nsnull，就修改掉
    unsigned int outCount;
    objc_property_t *properties = class_copyPropertyList([BBTUser class], &outCount);
    for (int i = 0; i<outCount; i++)
    {
        objc_property_t property = properties[i];
        const char* char_f =property_getName(property);
        NSString *propertyName = [NSString stringWithUTF8String:char_f];
        id propertyValue = [self.currentUser valueForKey:(NSString *)propertyName];
        if ([propertyValue isKindOfClass:[NSNull class]]){
            if (![propertyName isEqualToString:@"sex"]){
                [self.currentUser setValue:@"" forKey:propertyName];
            }else{
                //暂时@个0
                [self.currentUser setValue:@0 forKey:@"sex"];
            }
        }
    }
    
    [JNKeychain saveValue:self.currentUser.name forKey:@"accountName"];
    [JNKeychain saveValue:self.currentUser.nick forKey:@"accountNick"];
    [JNKeychain saveValue:self.currentUser.sex forKey:@"accountSex"];
    [JNKeychain saveValue:self.currentUser.grade forKey:@"accountGrade"];
    [JNKeychain saveValue:self.currentUser.college forKey:@"accountCollege"];
    [JNKeychain saveValue:self.currentUser.phone forKey:@"accountPhone"];
    [JNKeychain saveValue:self.currentUser.dormitory forKey:@"accountDormitory"];
    [JNKeychain saveValue:self.currentUser.qq forKey:@"accountQq"];
    [JNKeychain saveValue:self.currentUser.avatar forKey:@"accountAvatar"];
    
}
@end

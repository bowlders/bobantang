//
//  BBTCurrentUserManager.m
//  BoBanTang
//
//  Created by Caesar on 16/2/5.
//  Copyright © 2016年 100steps. All rights reserved.
//

#import "BBTCurrentUserManager.h"
#import <AFNetworking.h>
#import <JNKeychain.h>

@implementation BBTCurrentUserManager

static NSString * const checkAccountURL = @"http://218.192.166.167/api/jw2005/checkAccount.php";
static NSString * const fetchUserDataBaseURL = @"http://218.192.166.167/api/protype.php?table=users&method=get&data=";
static NSString * const insertNewUserBaseURL = @"http://218.192.166.167/api/protype.php?table=users&method=save&data=";
static NSString * const modifyNickNameBaseURL = @"http://218.192.166.167/api/protype.php?table=users&method=modify&data=";

static NSString * const userNameKey = @"userName";
static NSString * const passWordKey = @"passWord";

NSString * didUploadNickNameNotifName = @"nickNameSucceed";
NSString * failUploadNickNameNotifName = @"nickNameFail";
NSString * didUploadUserLogoURLNotifName = @"logoSucceed";
NSString * failUploadUserLogoURLNotifName = @"logoFail";
NSString * kUserAuthentificationFinishNotifName = @"authenticationFinish";

+ (instancetype)sharedCurrentUserManager
{
    static BBTCurrentUserManager *_manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _manager = [[BBTCurrentUserManager alloc] init];
    });
    return _manager;
}

- (void)currentUserAuthentication
{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    
    NSDictionary *parameters = @{@"account" : self.currentUser.account,
                                 @"password" : self.currentUser.password};
    [manager POST:checkAccountURL parameters:parameters progress:nil success:^(NSURLSessionTask *task, id responseObject) {
        NSLog(@"checkResult: %@", responseObject);
        for (NSString *key in [(NSDictionary *)responseObject allKeys])
        {
            if ([key isEqualToString:@"name"])
            {
                self.userIsActive = YES;
                self.currentUser.userName = responseObject[@"name"];
                [self fetchCurrentUserData];
            }
            else if ([key isEqualToString:@"err"])
            {
                self.userIsActive = NO;
                [self postUserAuthenticationFinishNotification];
            }
        }
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        self.userIsActive = NO;
        [self postUserAuthenticationFinishNotification];
    }];

    [manager invalidateSessionCancelingTasks:NO];
}

- (void)fetchCurrentUserData
{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];

    NSError *error;
    NSDictionary *parameters = @{@"account" : self.currentUser.account};
    NSData *data = [NSJSONSerialization dataWithJSONObject:parameters options:NSJSONWritingPrettyPrinted error:&error];
    NSString *jsonString = [[NSString alloc] initWithData:data
                                                 encoding:NSUTF8StringEncoding];
    NSString *stringCleanPath = [jsonString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString *url = [fetchUserDataBaseURL stringByAppendingString:stringCleanPath];
    
    [manager POST:url parameters:nil progress:nil success:^(NSURLSessionTask *task, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
        if ([(NSArray *)responseObject count])                          //This user already exists in database
        {
            BBTUser *user = [[BBTUser alloc] initWithDictionary:responseObject[0]];
            
            self.currentUser = user;
            [self postUserAuthenticationFinishNotification];
        }
        else                                                            //This is a new user, add him to database
        {
            [self insertNewUserToDataBase];
            [self postUserAuthenticationFinishNotification];
        }
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        self.userIsActive = NO;
        [self postUserAuthenticationFinishNotification];
    }];
    
    [manager invalidateSessionCancelingTasks:NO];
}

- (void)insertNewUserToDataBase
{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    
    NSError *error;
    NSDictionary *parameters = @{@"account" : self.currentUser.account,
                                 @"password" : self.currentUser.password,
                                 @"userName" : self.currentUser.userName};
    NSData *data = [NSJSONSerialization dataWithJSONObject:parameters options:NSJSONWritingPrettyPrinted error:&error];
    NSString *jsonString = [[NSString alloc] initWithData:data
                                                 encoding:NSUTF8StringEncoding];

    NSString *stringCleanPath = [jsonString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString *url = [insertNewUserBaseURL stringByAppendingString:stringCleanPath];

    [manager POST:url parameters:nil progress:nil success:^(NSURLSessionTask *task, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
        //[self fetchCurrentUserData];
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        self.userIsActive = NO;
    }];
    
    [manager invalidateSessionCancelingTasks:NO];
}

- (void)logOut
{
    BBTUser *emptyUser = [BBTUser new];
    self.currentUser = emptyUser;
    self.userIsActive = NO;
}

- (void)postUserAuthenticationFinishNotification
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kUserAuthentificationFinishNotifName
                                                        object:self];
}

- (void)saveCurrentUserInfo
{
    [JNKeychain saveValue:self.currentUser.account forKey:userNameKey];
    [JNKeychain saveValue:self.currentUser.password forKey:passWordKey];
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
    [JNKeychain deleteValueForKey:userNameKey];
    [JNKeychain deleteValueForKey:passWordKey];
}

- (void)uploadNewNickName:(NSString *)nickName
{
    //String appended after "data=", but
    NSString *dataString = [NSString stringWithFormat:@"{\"account\":%@}", self.currentUser.account];
    NSString *URLString1 = [modifyNickNameBaseURL stringByAppendingString:dataString];
    //String appended after URL1, %@ of the nickName must be added "", like \"%@\"
    NSString *setString = [NSString stringWithFormat:@"&set={\"nickName\":\"%@\"}", nickName];
    NSString *intactURLString = [URLString1 stringByAppendingString:setString];
    NSString *stringCleanPath = [intactURLString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"cleanpath - %@", stringCleanPath);
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    
    [manager POST:stringCleanPath parameters:nil progress:nil success:^(NSURLSessionTask *task, id responseObject) {
        //NSLog(@"JSON: %@", responseObject);
        if (responseObject)
        {
            NSLog(@"response - %@", responseObject);
            NSLog(@"class - %@", [(id)((NSDictionary *)responseObject[@"status"]) className]);
            if ([(NSNumber *)((NSDictionary *)responseObject[@"status"]) intValue] == 1)
            {
                [self pushDidUploadNickNameNotification];
                //Change current user's nickName.
                self.currentUser.nickName = nickName;
            }
            else
            {
                [self pushUploadNickNameFailNotification];
            }
        }
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        [self pushUploadNickNameFailNotification];
    }];
    [manager invalidateSessionCancelingTasks:NO];
}

- (void)uploadNewLogoURL:(NSString *)url
{
    //TODO: upload new logo url to database and change current user's logo, and post notification
    //If success    self.currentuser.userlogo = url; post succeed notif
    //else post fail notif
}

- (void)pushDidUploadNickNameNotification
{
    [[NSNotificationCenter defaultCenter] postNotificationName:didUploadNickNameNotifName object:self];
}

- (void)pushUploadNickNameFailNotification
{
    [[NSNotificationCenter defaultCenter] postNotificationName:failUploadNickNameNotifName object:self];
}

@end

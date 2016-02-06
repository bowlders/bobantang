//
//  BBTCurrentUserManager.m
//  BoBanTang
//
//  Created by Caesar on 16/2/5.
//  Copyright © 2016年 100steps. All rights reserved.
//

#import "BBTCurrentUserManager.h"
#import <AFNetworking.h>

@implementation BBTCurrentUserManager

static NSString * const checkAccountURL = @"http://218.192.166.167/api/jw2005/checkAccount.php";
static NSString * const fetchUserDataBaseURL = @"http://218.192.166.167/api/protype.php?table=users&method=get&data=";
static NSString * const insertNewUserBaseURL = @"http://218.192.166.167/api/protype.php?table=users&method=save&data=";

+ (instancetype)sharedCurrentUserManager
{
    static BBTCurrentUserManager *_manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _manager = [[BBTCurrentUserManager alloc] init];
    });
    return _manager;
}

- (BOOL)currentUserAuthentication
{
    //__block BOOL requestSucceed = 0;                                //Set to 1 if succeed
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    
    NSDictionary *parameters = @{@"account" : self.currentUser.account,
                                 @"password" : self.currentUser.password};
    NSLog(@"account - %@", self.currentUser.account);
    [manager POST:checkAccountURL parameters:parameters progress:nil success:^(NSURLSessionTask *task, id responseObject) {
        NSLog(@"account - %@", self.currentUser.account);
        NSLog(@"checkResult: %@", responseObject);
        for (NSString *key in [(NSDictionary *)responseObject allKeys])
        {
            if ([key isEqualToString:@"name"])
            {
                //requestSucceed = 1;
                self.userIsActive = YES;
                [self fetchCurrentUserData];
            }
            else if ([key isEqualToString:@"err"])
            {
                //requestSucceed = 0;
            }
        }
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        //requestSucceed = 0;
    }];
    
    return YES;
}

- (void)fetchCurrentUserData
{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];

    NSError *error;
    //NSLog(@"account - %@", self.currentUser.account);
    NSDictionary *parameters = @{@"account" : self.currentUser.account}; //@{@"account" : @"20143058207"};
    NSData *data = [NSJSONSerialization dataWithJSONObject:parameters options:NSJSONWritingPrettyPrinted error:&error];
    NSString *jsonString = [[NSString alloc] initWithData:data
                                                 encoding:NSUTF8StringEncoding];
    NSLog(@"json - %@", jsonString);
    NSString *stringCleanPath = [jsonString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString *url = [fetchUserDataBaseURL stringByAppendingString:stringCleanPath];
    NSLog(@"url - %@", url);
    
    [manager POST:url parameters:nil progress:nil success:^(NSURLSessionTask *task, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
        if ([(NSDictionary *)responseObject count])                     //This user already exists in database
        {
            BBTUser *user = responseObject[0];
            self.currentUser = user;
        }
        else                                                            //This is a new user, add him to database
        {
            [self insertNewUserToDataBase];
        }
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}

- (void)insertNewUserToDataBase
{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    
    NSError *error;
    NSDictionary *parameters = @{@"account" : @"201430581112", @"password" : @"12341234"};//self.account};
    NSData *data = [NSJSONSerialization dataWithJSONObject:parameters options:NSJSONWritingPrettyPrinted error:&error];
    NSString *jsonString = [[NSString alloc] initWithData:data
                                                 encoding:NSUTF8StringEncoding];
    NSLog(@"json - %@", jsonString);
    NSString *stringCleanPath = [jsonString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString *url = [insertNewUserBaseURL stringByAppendingString:stringCleanPath];
    NSLog(@"url - %@", url);
    
    [manager POST:url parameters:nil progress:nil success:^(NSURLSessionTask *task, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}

- (void)logOut
{
    BBTUser *emptyUser = [BBTUser new];
    self.currentUser = emptyUser;
    self.userIsActive = NO;
}

@end

//
//  BBTCollectedCampusInfoManager.m
//  BoBanTang
//
//  Created by Caesar on 16/2/23.
//  Copyright © 2016年 100steps. All rights reserved.
//

#import "BBTCollectedCampusInfoManager.h"
#import "BBTCurrentUserManager.h"
#import "BBTCollectedCampusInfo.h"
#import <AFNetworking.h>

static NSString * const fetchCollectedInfoBaseURL = @"http://218.192.166.167/api/protype.php?table=favouritedInformation&method=get&data=";
static NSString * const deleteCollectedInfoBaseURL = @"http://218.192.166.167/api/protype.php?table=favouritedInformation&method=delete&data=";
static NSString * const insertNewCollectedInfoBaseURL = @"http://218.192.166.167/api/protype.php?table=favouritedInformation&method=save&data=";

NSString * insertNewCollectedInfoSucceedNotifName = @"infoInsertionSucceed";
NSString * insertNewCollectedInfoFailNotifName = @"infoInsertionFail";
NSString * deleteCollectedInfoSucceedNotifName = @"infoDeletionSucceed";
NSString * deleteCollectedInfoFailNotifName = @"infoDeletionFail";
NSString * fetchCollectedInfoSucceedNotifName = @"infoFetchSucceed";
NSString * fetchCollectedInfoFailNotifName = @"infoFetchFail";
NSString * checkCurrentUserHasCollectedGivenInfoNotifName = @"hasCollectedInfo";
NSString * checkCurrentUserHasNotCollectedGivenInfoNotifName = @"hasNotCollectedInfo";
NSString * checkIfHasCollectedGivenInfoFailNotifName = @"checkInfoFail";

@implementation BBTCollectedCampusInfoManager

- (void)currentUserCollectInfoWithArticleID:(int)articleID
{
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    ((AFHTTPResponseSerializer *)manager.responseSerializer).acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    
    NSError *error;
    NSDictionary *parameters = @{@"account" : [BBTCurrentUserManager sharedCurrentUserManager].currentUser.account,
                                 @"articleID" : [NSString stringWithFormat:@"%d",articleID]};
    
    NSData *data = [NSJSONSerialization dataWithJSONObject:parameters options:NSJSONWritingPrettyPrinted error:&error];
    NSString *jsonString = [[NSString alloc] initWithData:data
                                                 encoding:NSUTF8StringEncoding];
    NSString *stringCleanPath = [jsonString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString *urlString = [insertNewCollectedInfoBaseURL stringByAppendingString:stringCleanPath];
    
    NSURL *URL = [NSURL URLWithString:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    
    NSURLSessionDataTask *dataTask = [manager dataTaskWithRequest:request completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
        if (error) {
            NSLog(@"Error: %@", error);
            [self postCollectedCampusInfoNotifOfNotifName:insertNewCollectedInfoFailNotifName];
        } else {
            NSLog(@"%@ %@", response, responseObject);
            [self postCollectedCampusInfoNotifOfNotifName:insertNewCollectedInfoSucceedNotifName];
        }
    }];
    [dataTask resume];
    
    /*
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    
    NSError *error;
    NSDictionary *parameters = @{@"account" : [BBTCurrentUserManager sharedCurrentUserManager].currentUser.account,
                                 @"articleID" : [NSString stringWithFormat:@"%d",articleID]};
    
    NSData *data = [NSJSONSerialization dataWithJSONObject:parameters options:NSJSONWritingPrettyPrinted error:&error];
    NSString *jsonString = [[NSString alloc] initWithData:data
                                                 encoding:NSUTF8StringEncoding];
    NSString *stringCleanPath = [jsonString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString *url = [insertNewCollectedInfoBaseURL stringByAppendingString:stringCleanPath];
    
    [manager POST:url parameters:nil progress:nil success:^(NSURLSessionTask *task, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
        [self postCollectedCampusInfoNotifOfNotifName:insertNewCollectedInfoSucceedNotifName];
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        [self postCollectedCampusInfoNotifOfNotifName:insertNewCollectedInfoFailNotifName];
    }];
     */
}

- (void)currentUserCancelCollectInfoWithArticleID:(int)articleID
{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    
    NSError *error;
    NSDictionary *parameters = @{@"account" : [BBTCurrentUserManager sharedCurrentUserManager].currentUser.account,
                                 @"articleID" : [NSString stringWithFormat:@"%d",articleID]};
    
    NSData *data = [NSJSONSerialization dataWithJSONObject:parameters options:NSJSONWritingPrettyPrinted error:&error];
    NSString *jsonString = [[NSString alloc] initWithData:data
                                                 encoding:NSUTF8StringEncoding];
    NSString *stringCleanPath = [jsonString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString *url = [deleteCollectedInfoBaseURL stringByAppendingString:stringCleanPath];
    
    [manager POST:url parameters:nil progress:nil success:^(NSURLSessionTask *task, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
        if ((int)responseObject)
        {
            [self postCollectedCampusInfoNotifOfNotifName:deleteCollectedInfoSucceedNotifName];
        }
        else
        {
            [self postCollectedCampusInfoNotifOfNotifName:deleteCollectedInfoFailNotifName];
        }
    } failure:^(NSURLSessionTask *operation, NSError *error){
        NSLog(@"Error: %@", error);
        [self postCollectedCampusInfoNotifOfNotifName:deleteCollectedInfoFailNotifName];
    }];
}

- (void)fetchCurrentUserCollectedCampusInfoIntoArray
{
    self.currentUserCollectedCampusInfoArray = [NSMutableArray array];
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    
    NSError *error;
    NSDictionary *parameters = @{@"account" : [BBTCurrentUserManager sharedCurrentUserManager].currentUser.account};
    
    NSData *data = [NSJSONSerialization dataWithJSONObject:parameters options:NSJSONWritingPrettyPrinted error:&error];
    NSString *jsonString = [[NSString alloc] initWithData:data
                                                 encoding:NSUTF8StringEncoding];
    NSString *stringCleanPath = [jsonString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString *url = [fetchCollectedInfoBaseURL stringByAppendingString:stringCleanPath];
    
    [manager POST:url parameters:nil progress:nil success:^(NSURLSessionTask *task, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
        for (int i = 0;i < [(NSArray *)responseObject count];i++)
        {
            BBTCollectedCampusInfo *newCollectedInfo = [[BBTCollectedCampusInfo alloc] initWithDictionary:responseObject[i] error:nil];
            [self.currentUserCollectedCampusInfoArray addObject:newCollectedInfo];
        }
        [self postCollectedCampusInfoNotifOfNotifName:fetchCollectedInfoSucceedNotifName];
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        [self postCollectedCampusInfoNotifOfNotifName:fetchCollectedInfoFailNotifName];
    }];
}

- (void)checkIfCurrentUserHasCollectedArticleWithArticleID:(int)articleID
{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    
    NSError *error;
    NSDictionary *parameters = @{@"account" : [BBTCurrentUserManager sharedCurrentUserManager].currentUser.account,
                                 @"articleID" : [NSString stringWithFormat:@"%d",articleID]};
    
    NSData *data = [NSJSONSerialization dataWithJSONObject:parameters options:NSJSONWritingPrettyPrinted error:&error];
    NSString *jsonString = [[NSString alloc] initWithData:data
                                                 encoding:NSUTF8StringEncoding];
    NSString *stringCleanPath = [jsonString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString *url = [fetchCollectedInfoBaseURL stringByAppendingString:stringCleanPath];
    
    [manager POST:url parameters:nil progress:nil success:^(NSURLSessionTask *task, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
        if ([(NSArray *)responseObject count])
        {
            [self postCollectedCampusInfoNotifOfNotifName:checkCurrentUserHasCollectedGivenInfoNotifName];
        }
        else
        {
            [self postCollectedCampusInfoNotifOfNotifName:checkCurrentUserHasNotCollectedGivenInfoNotifName];
        }
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        [self postCollectedCampusInfoNotifOfNotifName:checkIfHasCollectedGivenInfoFailNotifName];
    }];
}

- (void)postCollectedCampusInfoNotifOfNotifName:(NSString *)notifName
{
    [[NSNotificationCenter defaultCenter] postNotificationName:notifName object:self];
}

@end

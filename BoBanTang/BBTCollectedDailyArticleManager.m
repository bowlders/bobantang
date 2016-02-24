//
//  BBTCollectedDailyArticleManager.m
//  BoBanTang
//
//  Created by Caesar on 16/2/24.
//  Copyright © 2016年 100steps. All rights reserved.
//

#import "BBTCollectedDailyArticleManager.h"
#import "BBTCurrentUserManager.h"
#import "BBTCollectedDailyArticle.h"
#import <AFNetworking.h>

static NSString * const fetchCollectedArticleBaseURL = @"http://218.192.166.167/api/protype.php?table=favouritedSoup&method=get&data=";
static NSString * const deleteCollectedArticleBaseURL = @"http://218.192.166.167/api/protype.php?table=favouritedSoup&method=delete&data=";
static NSString * const insertNewCollectedArticleBaseURL = @"http://218.192.166.167/api/protype.php?table=favouritedSoup&method=save&data=";

NSString * insertNewCollectedArticleSucceedNotifName = @"articleInsertionSucceed";
NSString * insertNewCollectedArticleFailNotifName = @"articleInsertionFail";
NSString * deleteCollectedArticleSucceedNotifName = @"articleDeletionSucceed";
NSString * deleteCollectedArticleFailNotifName = @"articleDeletionFail";
NSString * fetchCollectedArticleSucceedNotifName = @"articleFetchSucceed";
NSString * fetchCollectedArticleFailNotifName = @"articleFetchFail";
NSString * checkCurrentUserHasCollectedGivenArticleNotifName = @"hasCollectedArticle";
NSString * checkCurrentUserHasNotCollectedGivenArticleNotifName = @"hasNotCollectedArticle";
NSString * checkIfHasCollectedGivenArticleFailNotifName = @"checkArticleFail";

@implementation BBTCollectedDailyArticleManager

- (void)currentUserCollectInfoWithArticleID:(int)articleID
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
    NSString *url = [insertNewCollectedArticleBaseURL stringByAppendingString:stringCleanPath];
    
    [manager POST:url parameters:nil progress:nil success:^(NSURLSessionTask *task, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
        [self postCollectedCampusInfoNotifOfNotifName:insertNewCollectedArticleSucceedNotifName];
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        [self postCollectedCampusInfoNotifOfNotifName:insertNewCollectedArticleFailNotifName];
    }];
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
    NSString *url = [deleteCollectedArticleBaseURL stringByAppendingString:stringCleanPath];
    
    [manager POST:url parameters:nil progress:nil success:^(NSURLSessionTask *task, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
        if ((int)responseObject)
        {
            [self postCollectedCampusInfoNotifOfNotifName:deleteCollectedArticleSucceedNotifName];
        }
        else
        {
            [self postCollectedCampusInfoNotifOfNotifName:deleteCollectedArticleFailNotifName];
        }
    } failure:^(NSURLSessionTask *operation, NSError *error){
        NSLog(@"Error: %@", error);
        [self postCollectedCampusInfoNotifOfNotifName:deleteCollectedArticleFailNotifName];
    }];
}

- (void)fetchCurrentUserCollectedCampusInfoIntoArray
{
    self.currentUserCollectedDailyArticleArray = [NSMutableArray array];
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    
    NSError *error;
    NSDictionary *parameters = @{@"account" : [BBTCurrentUserManager sharedCurrentUserManager].currentUser.account};
    
    NSData *data = [NSJSONSerialization dataWithJSONObject:parameters options:NSJSONWritingPrettyPrinted error:&error];
    NSString *jsonString = [[NSString alloc] initWithData:data
                                                 encoding:NSUTF8StringEncoding];
    NSString *stringCleanPath = [jsonString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString *url = [fetchCollectedArticleBaseURL stringByAppendingString:stringCleanPath];
    
    [manager POST:url parameters:nil progress:nil success:^(NSURLSessionTask *task, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
        for (int i = 0;i < [(NSArray *)responseObject count];i++)
        {
            BBTCollectedDailyArticle *newCollectedArticle = [[BBTCollectedDailyArticle alloc] initWithDictionary:responseObject[i] error:nil];
            [self.currentUserCollectedDailyArticleArray addObject:newCollectedArticle];
        }
        [self postCollectedCampusInfoNotifOfNotifName:fetchCollectedArticleSucceedNotifName];
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        [self postCollectedCampusInfoNotifOfNotifName:fetchCollectedArticleFailNotifName];
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
    NSString *url = [fetchCollectedArticleBaseURL stringByAppendingString:stringCleanPath];
    
    [manager POST:url parameters:nil progress:nil success:^(NSURLSessionTask *task, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
        if ([(NSArray *)responseObject count])
        {
            [self postCollectedCampusInfoNotifOfNotifName:checkCurrentUserHasCollectedGivenArticleNotifName];
        }
        else
        {
            [self postCollectedCampusInfoNotifOfNotifName:checkCurrentUserHasNotCollectedGivenArticleNotifName];
        }
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        [self postCollectedCampusInfoNotifOfNotifName:checkIfHasCollectedGivenArticleFailNotifName];
    }];
}

- (void)postCollectedCampusInfoNotifOfNotifName:(NSString *)notifName
{
    [[NSNotificationCenter defaultCenter] postNotificationName:notifName object:self];
}

@end

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
#import "BBTDailyArticle.h"
#import <AFNetworking.h>

static NSString * const fetchCollectedArticleBaseURL = @"http://218.192.166.167/api/protype.php?table=favouritedSoup&method=get&data=";
static NSString * const deleteCollectedArticleBaseURL = @"http://218.192.166.167/api/protype.php?table=favouritedSoup&method=delete&data=";
static NSString * const insertNewCollectedArticleBaseURL = @"http://218.192.166.167/api/protype.php?table=favouritedSoup&method=save&data=";
static NSString * const frontGetDailyArticleURL = @"http://218.192.166.167/api/protype.php?table=dailySoup&method=get&data=";

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

+ (instancetype)sharedCollectedArticleManager
{
    static BBTCollectedDailyArticleManager *_manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _manager = [[BBTCollectedDailyArticleManager alloc] init];
    });
    return _manager;
}

- (void)currentUserCollectArticleWithArticleID:(int)articleID
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
        //NSLog(@"JSON: %@", responseObject);
        [self postCollectedDailyArticleNotifOfNotifName:insertNewCollectedArticleSucceedNotifName];
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        [self postCollectedDailyArticleNotifOfNotifName:insertNewCollectedArticleFailNotifName];
    }];
    
    [manager invalidateSessionCancelingTasks:NO];
}

- (void)currentUserCancelCollectArticleWithArticleID:(int)articleID
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
        //NSLog(@"JSON: %@", responseObject);
        if ((int)responseObject)
        {
            [self postCollectedDailyArticleNotifOfNotifName:deleteCollectedArticleSucceedNotifName];
        }
        else
        {
            [self postCollectedDailyArticleNotifOfNotifName:deleteCollectedArticleFailNotifName];
        }
    } failure:^(NSURLSessionTask *operation, NSError *error){
        NSLog(@"Error: %@", error);
        [self postCollectedDailyArticleNotifOfNotifName:deleteCollectedArticleFailNotifName];
    }];
    
    [manager invalidateSessionCancelingTasks:NO];
}

- (void)fetchCurrentUserCollectedDailyArticleIntoArray
{
    //First fetch collected articles into currentUserCollectedDailyArticleArray.
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
        //NSLog(@"JSON: %@", responseObject);
        if (responseObject)
        {
            for (int i = 0;i < [(NSArray *)responseObject count];i++)
            {
                BBTCollectedDailyArticle *newCollectedArticle = [[BBTCollectedDailyArticle alloc] initWithDictionary:responseObject[i] error:nil];
                [self.currentUserCollectedDailyArticleArray addObject:newCollectedArticle];
            }
            [self fetchIntactDailyArticleWithCollectedArticle];
        }

    } failure:^(NSURLSessionTask *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        [self postCollectedDailyArticleNotifOfNotifName:fetchCollectedArticleFailNotifName];
    }];
    
    [manager invalidateSessionCancelingTasks:NO];
}

- (void)fetchIntactDailyArticleWithCollectedArticle
{
    //Then fetch intact daily articles with given collected articles into currentUserIntactCollectedDailyArticleArray.
    self.currentUserIntactCollectedDailyArticleArray = [NSMutableArray array];
    NSMutableArray *tempArray = [NSMutableArray array];
    
    if (self.currentUserCollectedDailyArticleArray && [self.currentUserCollectedDailyArticleArray count])
    {
        for (BBTCollectedDailyArticle *collectedArticle in self.currentUserCollectedDailyArticleArray)
        {
            //Add articleIDs into tempArray.
            [tempArray addObject:[NSNumber numberWithInt:collectedArticle.articleID]];
        }
        
        //Convert tempArray to a string.
        NSString *resultString = [[tempArray valueForKey:@"description"] componentsJoinedByString:@","];
        NSString *dataString = [NSString stringWithFormat:@"{\"ID\":[%@]}", resultString];
        NSString *urlString = [frontGetDailyArticleURL stringByAppendingString:dataString];
        NSString *stringCleanPath = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        
        AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
        manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
        
        [manager POST:stringCleanPath parameters:nil progress:nil success:^(NSURLSessionTask *task, id responseObject) {
            //NSLog(@"JSON: %@", responseObject);
            for (int i = 0;i < [(NSArray *)responseObject count];i++)
            {
                BBTDailyArticle *intactDailyArticle = [[BBTDailyArticle alloc] initWithDictionary:responseObject[i] error:nil];
                [self.currentUserIntactCollectedDailyArticleArray addObject:intactDailyArticle];
            }
            [self postCollectedDailyArticleNotifOfNotifName:fetchCollectedArticleSucceedNotifName];
        } failure:^(NSURLSessionTask *operation, NSError *error) {
            NSLog(@"Error: %@", error);
            [self postCollectedDailyArticleNotifOfNotifName:fetchCollectedArticleFailNotifName];
        }];
        
        [manager invalidateSessionCancelingTasks:NO];
    }
    //If user hasn't collected any daily article
    else if(self.currentUserCollectedDailyArticleArray && ![self.currentUserCollectedDailyArticleArray count])
    {
        [self postCollectedDailyArticleNotifOfNotifName:fetchCollectedArticleSucceedNotifName];
    }
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
        //NSLog(@"JSON: %@", responseObject);
        if ([(NSArray *)responseObject count])
        {
            [self postCollectedDailyArticleNotifOfNotifName:checkCurrentUserHasCollectedGivenArticleNotifName];
        }
        else
        {
            [self postCollectedDailyArticleNotifOfNotifName:checkCurrentUserHasNotCollectedGivenArticleNotifName];
        }
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        [self postCollectedDailyArticleNotifOfNotifName:checkIfHasCollectedGivenArticleFailNotifName];
    }];
    
    [manager invalidateSessionCancelingTasks:NO];
}

- (void)postCollectedDailyArticleNotifOfNotifName:(NSString *)notifName
{
    [[NSNotificationCenter defaultCenter] postNotificationName:notifName object:self];
}

@end

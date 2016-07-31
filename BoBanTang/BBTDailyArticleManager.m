//
//  BBTDailyArticleManager.m
//  BoBanTang
//
//  Created by Caesar on 16/1/25.
//  Copyright © 2016年 100steps. All rights reserved.
//

#import "BBTDailyArticleManager.h"
#import "BBTCollectedDailyArticle.h"
#import "BBTDailyArticle.h"
#import <AFNetworking.h>

static NSString * baseGetDailyArticleUrl = @"http://218.192.166.167/api/protype.php?table=dailySoup&method=get&option={\"limit\":";
static NSString * baseInsertDailyArticleUrl = @"";
static NSString * getLatestArticleURL = @"http://218.192.166.167/api/protype.php?table=dailySoup&method=get&option={\"limit\":[0,1]}";

NSString * dailyArticleNotificationName = @"articleNotification";
NSString * noMoreArticleNotifName = @"noMoreArticle";
NSString * getArticleTodaySucceedNotifName = @"getArticleTodaySucceed";

@implementation BBTDailyArticleManager

+ (instancetype)sharedArticleManager
{
    static BBTDailyArticleManager *_manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _manager = [[BBTDailyArticleManager alloc] init];
    });
    return _manager;
}

- (void)loadMoreData
{
    if ((!_articleArray) || (!_articleCount))
    {
        _articleArray = [NSMutableArray array];
    }
    
    int __block noMoreArticleCount = 0;                       //Record whether there are new articles loaded in.
    int beginningarticle = self.articleCount;                 //Load from this article, or the a in [a, b]; b is always 5, which means one pull-up loads 5 more articles.
    NSString *appendingURLString = [NSString stringWithFormat:@"[%d,5]}", beginningarticle];
    NSString *intactURLString = [baseGetDailyArticleUrl stringByAppendingString:appendingURLString];
    NSString *stringCleanPath = [intactURLString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    [manager POST:stringCleanPath parameters:nil progress:nil success:^(NSURLSessionTask *task, id responseObject) {
        //NSLog(@"JSON: %@", responseObject);
        if (responseObject)
        {
            for (int i = 0;i < [(NSArray *)responseObject count];i++)
            {
                BBTDailyArticle *newArticle = [[BBTDailyArticle alloc] initWithDictionary:((NSArray *)responseObject)[i] error:nil];
                [self.articleArray addObject:newArticle];
                noMoreArticleCount++;
            }
            self.articleCount += [(NSArray *)responseObject count];
            [self pushDailyArticleNotification];
            
            //No new articles loaded in, push notification. This line of code must be placed after [self pushDailyArticleNotification].
            if (!noMoreArticleCount)   [self pushNoMoreArticleNotification];
        }
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
    [manager invalidateSessionCancelingTasks:NO];
}

- (void)getArticleToday
{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    _articleToday = [BBTDailyArticle new];
    NSString *stringCleanPath = [getLatestArticleURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    [manager POST:stringCleanPath parameters:nil progress:nil success:^(NSURLSessionTask *task, id responseObject) {
        //NSLog(@"JSON: %@", responseObject);
        if (responseObject)
        {
            _articleToday = [[BBTDailyArticle alloc] initWithDictionary:((NSArray *)responseObject)[0] error:nil];
            [[NSNotificationCenter defaultCenter] postNotificationName:getArticleTodaySucceedNotifName object:self];
        }
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
    
    [manager invalidateSessionCancelingTasks:NO];
}

- (void)pushDailyArticleNotification
{
    [[NSNotificationCenter defaultCenter] postNotificationName:dailyArticleNotificationName object:self];
}

- (void)pushNoMoreArticleNotification
{
    [[NSNotificationCenter defaultCenter] postNotificationName:noMoreArticleNotifName object:self];
}

@end

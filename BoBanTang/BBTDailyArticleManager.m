//
//  BBTDailyArticleManager.m
//  BoBanTang
//
//  Created by Caesar on 16/1/25.
//  Copyright © 2016年 100steps. All rights reserved.
//

#import "BBTDailyArticleManager.h"
#import "BBTDailyArticle.h"
#import "BBTCollectedDailyArticle.h"
#import <AFNetworking.h>

static NSString * baseGetDailyArticleUrl = @"http://218.192.166.167/api/protype.php?table=dailySoup&method=get";
static NSString * baseInsertDailyArticleUrl = @"";
NSString * dailyArticleNotificationName = @"articleNotification";

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

- (void)retriveData:(NSString *)appendingUrl
{
    self.articleArray = [NSMutableArray array];
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    NSString *url = [baseGetDailyArticleUrl stringByAppendingString:appendingUrl];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    [manager POST:url parameters:nil progress:nil success:^(NSURLSessionTask *task, id responseObject) {
        //NSLog(@"JSON: %@", responseObject);
        if (responseObject)
        {
            for (int i = 0;i < [(NSArray *)responseObject count];i++)
            {
                BBTDailyArticle *newInfo = [[BBTDailyArticle alloc] initWithDictionary:((NSArray *)responseObject)[i] error:nil];
                [self.articleArray insertObject:newInfo atIndex:i];
                //NSLog(@"%d - %@", i, [[BBTCampusInfoManager sharedInfoManager] infoArray][i]);
            }
            [self pushDailyArticleNotification];
        }
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
    
    [manager invalidateSessionCancelingTasks:NO];
}

- (void)fetchCollectedArticleArrayWithGivenSimplifiedArray:(NSArray *)simplifiedArticleArray
{
    self.collectedArticleArray = [NSMutableArray array];
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    
    for (int i = 0;i < [simplifiedArticleArray count];i++)
    {
        BBTCollectedDailyArticle *simplifiedCollectedInfo = simplifiedArticleArray[i];
        
        NSError *error;
        NSDictionary *parameters = @{@"articleID" : [NSString stringWithFormat:@"%d",simplifiedCollectedInfo.articleID]};
        NSData *data = [NSJSONSerialization dataWithJSONObject:parameters options:NSJSONWritingPrettyPrinted error:&error];
        NSString *jsonString = [[NSString alloc] initWithData:data
                                                     encoding:NSUTF8StringEncoding];
        NSString *stringCleanPath = [jsonString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSString *url = [baseGetDailyArticleUrl stringByAppendingString:stringCleanPath];
        
        [manager POST:url parameters:nil progress:nil success:^(NSURLSessionTask *task, id responseObject) {
            NSLog(@"JSON: %@", responseObject);
            if (responseObject)
            {
                BBTDailyArticle *integratedArticle = [[BBTDailyArticle alloc] initWithDictionary:responseObject error:nil];
                [self.collectedArticleArray addObject:integratedArticle];
            }
        } failure:^(NSURLSessionTask *operation, NSError *error) {
            NSLog(@"Error: %@", error);
        }];
    }
    
    [manager invalidateSessionCancelingTasks:NO];
}

- (void)pushDailyArticleNotification
{
    [[NSNotificationCenter defaultCenter] postNotificationName:dailyArticleNotificationName object:self];
}

@end

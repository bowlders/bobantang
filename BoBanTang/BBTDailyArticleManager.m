//
//  BBTDailyArticleManager.m
//  BoBanTang
//
//  Created by Caesar on 16/1/25.
//  Copyright © 2016年 100steps. All rights reserved.
//

#import "BBTDailyArticleManager.h"
#import "BBTDailyArticle.h"
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
    [manager GET:url parameters:nil progress:nil success:^(NSURLSessionTask *task, id responseObject) {
        //NSLog(@"JSON: %@", responseObject);
        if (responseObject)
        {
            for (int i = 0;i < [(NSArray *)responseObject count];i++)
            {
                BBTDailyArticle *newInfo = ((NSArray *)responseObject)[i];
                [[[BBTDailyArticleManager sharedArticleManager] articleArray] insertObject:newInfo atIndex:i];
                //NSLog(@"%d - %@", i, [[BBTCampusInfoManager sharedInfoManager] infoArray][i]);
            }
            [self pushDailyArticleNotification];
        }
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}

- (void)pushDailyArticleNotification
{
    [[NSNotificationCenter defaultCenter] postNotificationName:dailyArticleNotificationName object:self];
}

- (void)addReadNumber:(NSUInteger)infoIndex
{

}

- (void)addCollectionNumber:(NSUInteger)infoIndex
{

}

@end

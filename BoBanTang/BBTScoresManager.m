//
//  BBTScoresManager.m
//  BoBanTang
//
//  Created by Hsu Tung Hui on 16/2/16.
//  Copyright © 2016年 100steps. All rights reserved.
//

#import "BBTScoresManager.h"
#import "BBTScores.h"
#import <AFNetworking/AFNetworking.h>

static NSString *getScoresUrl = @"http://218.192.166.167/api/jw2005/getScore.php";
NSString * kGetScoresNotificaionName = @"getScoresNotificaion";
NSString * kFailGetNotificaionName = @"failGetNotificaion";

@implementation BBTScoresManager

+ (instancetype)sharedScoresManager
{
    static BBTScoresManager *_manager = nil;
    static dispatch_once_t onecToken;
    dispatch_once(&onecToken, ^{
        _manager = [[BBTScoresManager alloc] init];
    });
    return _manager;
}

- (void)retriveScores:(NSMutableDictionary *)userInfo WithConditions:(NSDictionary *)conditons
{
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] initWithDictionary:userInfo];
    if ([conditons objectForKey:@"year"])[parameters setObject:[conditons objectForKey:@"year"] forKey:@"year"];
    if ([conditons objectForKey:@"term"] && [[conditons objectForKey:@"term"] integerValue] != 0)[parameters setObject:[conditons objectForKey:@"term"] forKey:@"term"];
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    [manager POST:getScoresUrl parameters:parameters progress:nil success:^(NSURLSessionTask *task, id  responseObject) {
        if (responseObject)
        {
            NSString *error = responseObject[@"err"];
            if ([error isEqualToString:@"no score"]) {
                self.errorType = @(0);
                [self pushFailGetNotification];
                return;
            }
            
            NSDictionary *scoresDic = responseObject[@"score"];
            NSArray *passedArray = [[NSArray alloc] initWithArray:scoresDic[@"passed"]];
            if ([passedArray class] == [NSNull class]) {
                self.errorType = @(0);
                [self pushFailGetNotification];
                return;
            }
            
           self.scoresArray = [[NSMutableArray alloc] init];
            
            BBTScores *resultTitle = [[BBTScores alloc] init];
            resultTitle.courseName = @"科目";
            resultTitle.score = @"分数";
            resultTitle.gradepoint = @"绩点";
            resultTitle.ranking = @"排名";
            [self.scoresArray addObject:resultTitle];
            
            for (NSDictionary *resultDic in passedArray)
            {
                BBTScores *result = [[BBTScores alloc] init];
                
                result.courseName = resultDic[@"subject"];
                result.score = [NSString stringWithFormat:@"%@", resultDic[@"grade"]];
                
                NSString *isRankingExist = [NSString stringWithFormat:@"%@", resultDic[@"ranking"]];
                if ([isRankingExist isEqualToString:@"&nbsp;"]) {
                    result.ranking = @"";
                } else {
                    result.ranking = [NSString stringWithFormat:@"%@", resultDic[@"ranking"]];
                }
                
                result.gradepoint = [NSString stringWithFormat:@"%@", resultDic[@"GPA"]];
                
                [self.scoresArray addObject:result];
            }
            [self pushDidGetNotification];
        }
    } failure:^(NSURLSessionTask *task, NSError *error) {
        NSLog(@"Error: %@",error);
        self.errorType = @(1);
        [self pushFailGetNotification];
    }];
}

- (void)pushDidGetNotification
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kGetScoresNotificaionName object:nil];
}

- (void)pushFailGetNotification
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kFailGetNotificaionName object:self.errorType];
}

@end

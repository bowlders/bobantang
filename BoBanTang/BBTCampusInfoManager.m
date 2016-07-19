//
//  BBTCampusInfoManager.m
//  BoBanTang
//
//  Created by Caesar on 15/11/29.
//  Copyright © 2015年 100steps. All rights reserved.
//

#import "BBTCampusInfoManager.h"
#import "BBTCollectedCampusInfo.h"
#import <AFNetworking.h>
#import "BBTCampusInfo.h"

static NSString * baseGetCampusInfoUrl = @"http://218.192.166.167/api/protype.php?table=schoolInformation&method=get&option={\"limit\":[0,5]}";  //Url used to get data
static NSString * baseInsertCampusInfoUrl = @"";                                  //Url used to insert data
NSString * campusInfoNotificationName = @"infoNotification";

@implementation BBTCampusInfoManager

+ (instancetype)sharedInfoManager
{
    static BBTCampusInfoManager *_manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _manager = [[BBTCampusInfoManager alloc] init];
    });
    return _manager;
}

- (void)retriveData:(NSString *)appendingUrl
{
    int __block infoCount = 0;                              //Record the number of infos added to infoArray
    self.infoArray = [NSMutableArray array];
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    NSString *url = [baseGetCampusInfoUrl stringByAppendingString:appendingUrl];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    [manager POST:url parameters:nil progress:nil success:^(NSURLSessionTask *task, id responseObject) {
        //NSLog(@"JSON: %@", responseObject);
        if (responseObject)
        {
            for (int i = 0;i < [(NSArray *)responseObject count];i++)
            {
                BBTCampusInfo *newInfo = [[BBTCampusInfo alloc] initWithDictionary:((NSArray *)responseObject)[i] error:nil];
                [self.infoArray insertObject:newInfo atIndex:i];
                infoCount++;
            }
            [self pushCampusInfoNotification];
        }
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
    [manager invalidateSessionCancelingTasks:NO];
}

- (void)fetchCollectedInfoArrayWithGivenSimplifiedArray:(NSArray *)simplifiedInfoArray
{
    self.collectedInfoArray = [NSMutableArray array];
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    
    for (int i = 0;i < [simplifiedInfoArray count];i++)
    {
        BBTCollectedCampusInfo *simplifiedCollectedInfo = simplifiedInfoArray[i];
        
        NSError *error;
        NSDictionary *parameters = @{@"articleID" : [NSString stringWithFormat:@"%d",simplifiedCollectedInfo.articleID]};
        NSData *data = [NSJSONSerialization dataWithJSONObject:parameters options:NSJSONWritingPrettyPrinted error:&error];
        NSString *jsonString = [[NSString alloc] initWithData:data
                                                     encoding:NSUTF8StringEncoding];
        NSString *stringCleanPath = [jsonString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSString *url = [baseGetCampusInfoUrl stringByAppendingString:stringCleanPath];
        
        [manager POST:url parameters:nil progress:nil success:^(NSURLSessionTask *task, id responseObject) {
            NSLog(@"JSON: %@", responseObject);
            if (responseObject)
            {
                BBTCampusInfo *integratedInfo = [[BBTCampusInfo alloc] initWithDictionary:responseObject error:nil];
                [self.collectedInfoArray addObject:integratedInfo];
            }
        } failure:^(NSURLSessionTask *operation, NSError *error) {
            NSLog(@"Error: %@", error);
        }];
    }
    [manager invalidateSessionCancelingTasks:NO];
}

-(void)pushCampusInfoNotification
{
    [[NSNotificationCenter defaultCenter] postNotificationName:campusInfoNotificationName object:self];
}

@end

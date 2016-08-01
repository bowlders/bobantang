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

static NSString * baseGetCampusInfoUrl = @"http://218.192.166.167/api/protype.php?table=schoolInformation&method=get&option={\"limit\":";  //Base Url used to get data
static NSString * baseInsertCampusInfoUrl = @"";                                  //Url used to insert data

NSString * campusInfoNotificationName = @"infoNotification";
NSString * noNewInfoNotifName = @"noMoreInfo";

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

- (void)loadMoreData
{
    //if _infoArray hasn't been instantiated, instantiate it
    //or if _infoCount == 0, which means that user is currently refreshing(pull-down), then empty _infoArray
    if ((!self.infoArray) || (!self.infoCount))
    {
        self.infoArray = [NSMutableArray array];
    }
    
    int __block noMoreInfoCount = 0;                        //Record whether there are new infos loaded in.
    int beginningInfo = self.infoCount;                     //Load from this info, or the a in [a, b]; b is always 5, which means one pull-up loads 5 more infos.
    NSString *appendingURLString = [NSString stringWithFormat:@"[%d,5]}", beginningInfo];
    NSString *intactURLString = [baseGetCampusInfoUrl stringByAppendingString:appendingURLString];
    NSString *stringCleanPath = [intactURLString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
 
    [manager POST:stringCleanPath parameters:nil progress:nil success:^(NSURLSessionTask *task, id responseObject) {
        //NSLog(@"JSON: %@", responseObject);
        if (responseObject)
        {
            for (int i = 0;i < [(NSArray *)responseObject count];i++)
            {
                BBTCampusInfo *newInfo = [[BBTCampusInfo alloc] initWithDictionary:((NSArray *)responseObject)[i] error:nil];
                [self.infoArray addObject:newInfo];
                noMoreInfoCount++;
            }
            
            self.infoCount += [(NSArray *)responseObject count];
            [self pushCampusInfoNotification];
            
            //No new infos loaded in, push notification. This line of code must be placed after [self pushCampusInfoNotification].
            if (!noMoreInfoCount)   [self pushNoNewInfoNotification];
        }
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
    [manager invalidateSessionCancelingTasks:NO];
}

-(void)pushCampusInfoNotification
{
    [[NSNotificationCenter defaultCenter] postNotificationName:campusInfoNotificationName object:self];
}

- (void)pushNoNewInfoNotification
{
    [[NSNotificationCenter defaultCenter] postNotificationName:noNewInfoNotifName object:self];
}

@end

//
//  BBTCampusInfoManager.m
//  BoBanTang
//
//  Created by Caesar on 15/11/29.
//  Copyright © 2015年 100steps. All rights reserved.
//

#import "BBTCampusInfoManager.h"
#import <AFNetworking.h>
#import "BBTCampusInfo.h"

static NSString * getUrl = @"http://218.192.166.167/api/protype.php?table=schoolInformation&method=get";                                     //Url used to get data
static NSString * insertUrl = @"";                                  //Url used to insert data

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

- (void)retriveData : (NSString *)appendingUrl
{
    self.infoArray = [NSMutableArray array];
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    NSString *url = [getUrl stringByAppendingString:appendingUrl];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    [manager GET:url parameters:nil progress:nil success:^(NSURLSessionTask *task, id responseObject) {
        //NSLog(@"JSON: %@", responseObject);
        if (responseObject)
        {
            for (int i = 0;i < [(NSArray *)responseObject count];i++)
            {
                BBTCampusInfo *newInfo = ((NSArray *)responseObject)[i];
                [[[BBTCampusInfoManager sharedInfoManager] infoArray] insertObject:newInfo atIndex:i];
                NSLog(@"%d - %@", i, [[BBTCampusInfoManager sharedInfoManager] infoArray][i]);
            }
        }
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}

- (void)addReadNumber:(NSUInteger)infoIndex
{

}

- (void)addCollectionNumber:(NSUInteger)infoIndex
{
    
}

@end

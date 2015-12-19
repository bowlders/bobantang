//
//  BBTCampusInfoManager.m
//  BoBanTang
//
//  Created by Caesar on 15/11/29.
//  Copyright © 2015年 100steps. All rights reserved.
//

#import "BBTCampusInfoManager.h"
#import <AFNetworking.h>

static NSString * getBaseUrl = @"http://218.192.166.167/api/protype.php?table=schoolInformation&method=get&data=";                                  //Url used to get data
static NSString * insertBaseUrl = @"http://218.192.166.167/api/protype.php?table=schoolInformation&method=save&data=";                              //Url used to insert data

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

- (void)retriveData:(NSString *)appendingString
{
    NSString *getUrlString = [getBaseUrl stringByAppendingString:appendingString];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager POST:getUrlString parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}

- (void)addReadNumber:(NSUInteger)infoID
{
    
}

- (void)addCollectionNumber:(NSUInteger)infoID
{
    
}

@end

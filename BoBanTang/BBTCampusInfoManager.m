//
//  BBTCampusInfoManager.m
//  BoBanTang
//
//  Created by Caesar on 15/11/29.
//  Copyright © 2015年 100steps. All rights reserved.
//

#import "BBTCampusInfoManager.h"

static NSString * getUrl = @"";                                     //Url used to get data
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

- (void)retriveData
{
    
}

- (void)addReadNumber:(NSUInteger)infoIndex
{

}

- (void)addCollectionNumber:(NSUInteger)infoIndex
{
    
}

@end

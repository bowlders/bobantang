//
//  BBTSpecRailway2BusManager.m
//  BoBanTang
//
//  Created by Caesar on 15/11/19.
//  Copyright © 2015年 100steps. All rights reserved.
//

#import "BBTSpecRailway2BusManager.h"
#import "BBTSpecRailway2Bus.h"
#import "NSDictionary+BBTDictionary.h"
#import <AFNetworking.h>

@implementation BBTSpecRailway2BusManager

static NSString * directionSouthURLString = @"http://api.100steps.net/bus.php?dir=0";
static NSString * directionNorthURLString = @"http://api.100steps.net/bus.php?dir=1";
extern NSString * busDataNotificationName;                                                  //The name of the notification when retriving bus data
static float dataRequestInterval = 5.0;                                                     //The time interval between two data requests

+ (instancetype)sharedBusManager
{
    static BBTSpecRailway2BusManager *_manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _manager = [[BBTSpecRailway2BusManager alloc] init];
    });
    return _manager;
}

- (id)init
{
    self  = [super init];
    if (!self) return nil;
    
    [self retriveData];
    [NSTimer scheduledTimerWithTimeInterval:dataRequestInterval
                                     target:self
                                   selector:@selector(retriveData)
                                   userInfo:nil
                                    repeats:YES];
    
    return self;
}

- (NSMutableArray *)directionSouthBuses
{
    if (!_directionSouthBuses)
    {
        _directionSouthBuses = [NSMutableArray array];
    }
    return _directionSouthBuses;
}

- (NSMutableArray *)directionNorthBuses
{
    if (!_directionNorthBuses)
    {
        _directionNorthBuses = [NSMutableArray array];
    }
    return _directionNorthBuses;
}

- (NSArray *)directionSouthStationNames
{
    if (!_directionSouthStationNames)
    {
        _directionSouthStationNames = @[
                                        @"华工大总站", @"消防总队站", @"广元天寿路口东站", @"农科院站", @"省农干科干院站", @"科学院地化所站", @"科韵路棠安路口站",
                                        @"琶洲大桥北站", @"北山站", @"星海学院站", @"华师站", @"档案馆路（中部枢纽）站", @"市国家档案馆南（大学城）站", @"美术学院站",
                                        @"中环西路站", @"广工站", @"综合商业南区站", @"华工站", @"华工生活区站", @"广药路站", @"大学城（广中医）总站"
                                        ];
    }
    return _directionSouthStationNames;
}

- (NSArray *)directionNorthStationNames
{
    if (!_directionNorthStationNames)
    {
        _directionNorthStationNames = @[
                                        @"大学城（广中医）总站", @"广药路站", @"华工生活区站", @"华工站", @"综合商业南区站", @"广工站", @"中环西路站",
                                        @"美术学院站", @"市国家档案馆南（大学城）站", @"档案馆路（中部枢纽）站", @"华师站", @"星海学院站", @"地铁大学城北站", @"仑头立交站",
                                        @"琶洲大桥北站", @"科韵路站", @"科韵路棠安路口站", @"科韵立交西站", @"科学院地化所站", @"省农干科干院站", @"农科院站", @"华工大总站"
                                        ];
    }
    return _directionNorthStationNames;
}

- (void)retriveData
{
    self.directionSouthBuses = [NSMutableArray array];
    self.directionNorthBuses = [NSMutableArray array];
    
    //Retrive buses whose direction is south
    AFHTTPRequestOperationManager *southManager = [AFHTTPRequestOperationManager manager];
    southManager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    [southManager GET:directionSouthURLString parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if ([responseObject currentSpecRailwayBusArray])
        {
            for (int i = 0;i < [[responseObject currentSpecRailwayBusArray] count];i++)
            {
                BBTSpecRailway2Bus *currentBus = [[BBTSpecRailway2Bus alloc] initWithDictionary:[responseObject currentSpecRailwayBusArray][i] error:nil];
                NSLog(@"%@",[responseObject currentSpecRailwayBusArray][i]);
                NSLog(@"busIndex - %lu", (unsigned long)currentBus.stationSeq);
                [self.directionSouthBuses addObject:currentBus];
            }
            [self postBusDataNotification];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
    
    //Retrive buses whose direction is north
    AFHTTPRequestOperationManager *northManager = [AFHTTPRequestOperationManager manager];
    northManager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    [northManager GET:directionNorthURLString parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if ([responseObject currentSpecRailwayBusArray])
        {
            for (int i = 0;i < [[responseObject currentSpecRailwayBusArray] count];i++)
            {
                BBTSpecRailway2Bus *currentBus = [[BBTSpecRailway2Bus alloc] initWithDictionary:[responseObject currentSpecRailwayBusArray][i] error:nil];
                [self.directionNorthBuses addObject:currentBus];
            }
            [self postBusDataNotification];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}

- (void)postBusDataNotification
{
    [[NSNotificationCenter defaultCenter] postNotificationName:busDataNotificationName object:self userInfo:nil];
}

@end

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

NSString * const busDataNotificationName = @"specBusNotification";
NSString * const retriveDirectionSouthFailNotifName = @"southSpecBusFailNotif";
NSString * const retriveDirectionNorthFailNotifName = @"northSpecBusFailNotif";

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
    AFHTTPSessionManager *southManager = [AFHTTPSessionManager manager];
    southManager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    [southManager POST:directionSouthURLString parameters:nil progress:nil success:^(NSURLSessionTask *task, id responseObject) {
        //NSLog(@"South Buses: %@", responseObject);
        //NSLog(@"%lu",[responseObject[@"d"] count]);
        if(responseObject[@"d"]){
            if (![[responseObject currentSpecRailwayBusArray] isEqual:[NSNull null]])    //The property of value whose key is "d" can become NSNull under some conditions
            {
                for (int i = 0;i < [[responseObject currentSpecRailwayBusArray] count];i++)
                {
                    BBTSpecRailway2Bus *currentBus = [[BBTSpecRailway2Bus alloc] initWithDictionary:[responseObject currentSpecRailwayBusArray][i] error:nil];
                    [self.directionSouthBuses addObject:currentBus];
                }
                [self postBusDataNotification];
            }
        }
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        [self pushRetriveDirectionSouthFailNotification];
        NSLog(@"Error: %@", error);
    }];
    
    [southManager invalidateSessionCancelingTasks:NO];
    
    //Retrive buses whose direction is north
    AFHTTPSessionManager *northManager = [AFHTTPSessionManager manager];
    northManager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    [northManager POST:directionNorthURLString parameters:nil progress:nil success:^(NSURLSessionTask *task, id responseObject) {
        //NSLog(@"JSON: %@", responseObject);
        //NSLog(@"%@",responseObject[@"d"]);
        if(responseObject[@"d"]){
            if (![[responseObject currentSpecRailwayBusArray] isEqual:[NSNull null]])
            {
                for (int i = 0;i < [[responseObject currentSpecRailwayBusArray] count];i++)
                {
                    BBTSpecRailway2Bus *currentBus = [[BBTSpecRailway2Bus alloc] initWithDictionary:[responseObject currentSpecRailwayBusArray][i] error:nil];
                    [self.directionNorthBuses addObject:currentBus];
                }
                [self postBusDataNotification];
            }
        }
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        [self pushRetriveDirectionNorthFailNotification];
        NSLog(@"Error: %@", error);
    }];
    
    [northManager invalidateSessionCancelingTasks:NO];
}

- (void)postBusDataNotification
{
    [[NSNotificationCenter defaultCenter] postNotificationName:busDataNotificationName object:self userInfo:nil];
}

- (void)pushRetriveDirectionSouthFailNotification
{
    [[NSNotificationCenter defaultCenter] postNotificationName:retriveDirectionSouthFailNotifName object:self];
}

- (void)pushRetriveDirectionNorthFailNotification
{
    [[NSNotificationCenter defaultCenter] postNotificationName:retriveDirectionNorthFailNotifName object:self];
}

- (BOOL)noBusInBusArray:(NSArray *)array RunningAtStationSeq:(NSInteger)stationSeq
{
    int numberOfBusesCurrentlyAtThisStation = 0;
    
    for (int i = 0;i < [array count];i++)
    {
        if (((BBTSpecRailway2Bus *)array[i]).stationSeq == stationSeq)
        {
            numberOfBusesCurrentlyAtThisStation++;
        }
    }
    
    return numberOfBusesCurrentlyAtThisStation == 0;
}

- (void)refresh
{
    [self retriveData];
}

@end

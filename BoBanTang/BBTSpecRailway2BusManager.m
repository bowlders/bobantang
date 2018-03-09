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

static NSString * directionSouthURLString = @"http://apiv2.100steps.net/bus/line2/0";
static NSString * directionNorthURLString = @"http://apiv2.100steps.net/bus/line2/1";

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
                                        @"琶洲大桥北站", @"北山站", @"星海学院站", @"华师站", @"档案路（中部枢纽）站", @"市国家档案馆南（大学城）站", @"美术学院站",
                                        @"中环西路站", @"广工站", @"综合商业南区站", @"华工站", @"华工生活区站", @"广药路站", @"大学城(广中医)总站"
                                        ];
    }
    return _directionSouthStationNames;
}

- (NSArray *)directionNorthStationNames
{
    if (!_directionNorthStationNames)
    {
        _directionNorthStationNames = @[
                                        @"大学城(广中医)总站", @"广药路站", @"华工生活区站", @"华工站", @"综合商业南区站", @"广工站", @"中环西路站",
                                        @"美术学院站", @"市国家档案馆南站", @"档案路（中部枢纽）站", @"华师站", @"星海学院站", @"地铁大学城北站", @"仑头立交站",
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
    southManager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/html",@"application/json",nil];
    [southManager GET:directionSouthURLString parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (responseObject[@"station_list"] && responseObject[@"bus_list"]){
            
            NSArray *stationArray = responseObject[@"station_list"];
            NSArray *busArray = responseObject[@"bus_list"];
            
            for (NSDictionary *busInfoDictionary in busArray) {
                BBTSpecRailway2Bus *currentBus = [[BBTSpecRailway2Bus alloc]init];
                
                for (NSDictionary *stationInfoDictionary in stationArray){
                    if ([busInfoDictionary[@"station_id"] isEqual:stationInfoDictionary[@"station_id"]]){
                        
                        NSUInteger stationIndex = [stationArray indexOfObject:stationInfoDictionary]+1;
                        currentBus.stationSeq = stationIndex;
                        
                    }
                }
                [self.directionSouthBuses addObject:currentBus];
            }
            
            [self postBusDataNotification];
            
        }else{
            
            [self pushRetriveDirectionSouthFailNotification];
        
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"专线二往大学城方向获取失败，原因为:%@",error);
        [self pushRetriveDirectionSouthFailNotification];
    }];
    
    [southManager invalidateSessionCancelingTasks:NO];
    
    //Retrive buses whose direction is north
    AFHTTPSessionManager *northManager = [AFHTTPSessionManager manager];
    northManager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/html",@"application/json",nil];
    [northManager GET:directionNorthURLString parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        if (responseObject[@"station_list"] && responseObject[@"bus_list"]){
            
            NSArray *stationArray = responseObject[@"station_list"];
            NSArray *busArray = responseObject[@"bus_list"];
            
            for (NSDictionary *busInfoDictionary in busArray) {
                BBTSpecRailway2Bus *currentBus = [[BBTSpecRailway2Bus alloc]init];
                
                for (NSDictionary *stationInfoDictionary in stationArray){
                    if ([busInfoDictionary[@"station_id"] isEqual:stationInfoDictionary[@"station_id"]]){
                        
                        NSUInteger stationIndex = [stationArray indexOfObject:stationInfoDictionary]+1;
                        currentBus.stationSeq = stationIndex;
                        
                    }
                }
                [self.directionNorthBuses addObject:currentBus];
            }
            
            [self postBusDataNotification];
        }else{
            [self pushRetriveDirectionNorthFailNotification];
        }
       
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [self pushRetriveDirectionNorthFailNotification];
        NSLog(@"专线二往北校方向获取失败，原因为:%@",error);
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

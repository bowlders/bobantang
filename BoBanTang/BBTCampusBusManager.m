//
//  BBTCampusBusManager.m
//  BoBanTang
//
//  Created by Caesar on 16/1/28.
//  Copyright © 2016年 100steps. All rights reserved.
//

#import "BBTCampusBusManager.h"
#import "BBTCampusBus.h"
#import <AFNetworking.h>

@interface BBTCampusBusManager ()

@end

@implementation BBTCampusBusManager

//NSString * baseURLString = @"http://bbt.100steps.net/go/data/";
NSString * baseURLString = @"http://127.0.0.1:6767";
static const float dataRequestInterval = 6.6;               //Seconds
NSString * campusBusNotificationName = @"campusBusNotification";

+ (instancetype)sharedCampusBusManager
{
    static BBTCampusBusManager *_manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _manager = [[BBTCampusBusManager alloc] init];
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

- (NSArray *)stationNameArray
{
    if (!_stationNameArray)
    {
        _stationNameArray = @[@"北二总站", @"卫生所站", @"北湖站", @"北门站",
                             @"修理厂站", @"西秀村站", @"西五站", @"人文馆站",
                             @"27号楼站",@"百步梯站", @"中山像站",@"南门总站"];
    }
    return _stationNameArray;
}

- (void)retriveData
{
    self.campusBusArray = [NSMutableArray array];
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"application/json"];
    [manager POST:baseURLString parameters:nil progress:nil success:^(NSURLSessionTask *task, id responseObject) {
        //NSLog(@"JSON: %@", responseObject);
        if (responseObject)
        {
            for (NSString *key in [(NSDictionary *)responseObject allKeys])
            {
                BBTCampusBus *bus = responseObject[key];
                
                [self.campusBusArray addObject:bus];
                //NSLog(@"bus - %@",bus);
            }
            [self postCampusBusNotification];
        }
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}

- (void)refresh
{
    [self retriveData];
}

- (void)postCampusBusNotification
{
    [[NSNotificationCenter defaultCenter] postNotificationName:campusBusNotificationName object:self userInfo:nil];
}

- (BOOL)noBusRunningAtStartingStation
{
    int numberOfBusesCurrentlyAtStartingStation = 0;                //The total number of the buses currently at station 1.
    int numberofBusesCurrentlyStoppingAtStartingStation = 0;        //The number of the buses currently stopping at station 1.
    
    for (int i = 0;i < [self.campusBusArray count];i++)
    {
        if ([self.campusBusArray[i][@"StationIndex"] intValue] == 1)
        {
            numberOfBusesCurrentlyAtStartingStation++;
            
            if ([self.campusBusArray[i][@"Stop"] boolValue] == 1)
            {
                numberofBusesCurrentlyStoppingAtStartingStation++;
            }
        }
    }
    
    return numberOfBusesCurrentlyAtStartingStation == numberofBusesCurrentlyStoppingAtStartingStation;
}


- (BOOL)noBusRunningAtStationAtIndex:(NSUInteger)index
{
    int numberOfBusesCurrentlyAtThisStation = 0;
    
    for (int i = 0;i < [self.campusBusArray count];i++)
    {
        NSLog(@"index - %d", [self.campusBusArray[i][@"StationIndex"] intValue]);
        //NSLog(@"index - %lu", index);
        NSLog(@"direction - %d", [self.campusBusArray[i][@"Direction"] boolValue]);
        if ([self.campusBusArray[i][@"StationIndex"] intValue] == index)
        {
            numberOfBusesCurrentlyAtThisStation++;
        }
    }
    
    return numberOfBusesCurrentlyAtThisStation == 0;
}

- (BOOL)oneOrMoreBusRunningAtStationAtIndex:(NSUInteger)index
{
    for (int i = 0;i < [self.campusBusArray count];i++)
    {
        if ([self.campusBusArray[i][@"StationIndex"] intValue] == index)
        {
            return YES;
        }
    }
    
    return NO;
}

- (int)directionOfTheBusAtStationIndex:(NSUInteger)index
{
    int directionSouthCount = 0;                                //Record the number of the buses at the given station whose direction is south.
    int directionNorthCount = 0;
    
    for (int i = 0;i < [self.campusBusArray count];i++)
    {
        if ([self.campusBusArray[i][@"StationIndex"] intValue] == index)
        {
            if ([self.campusBusArray[i][@"Direction"] boolValue] == 1)
            {
                directionSouthCount++;
            }
            else
            {
                directionNorthCount++;
            }
        }
    }
    
    if ((directionSouthCount > 0) && (directionNorthCount > 0))
    {
        return 2;
    }
    else if ((directionSouthCount > 0) && (directionNorthCount == 0))
    {
        return 1;
    }
    else if ((directionSouthCount == 0) && (directionNorthCount > 0))
    {
        return 0;
    }

    //If no bus is currently running at this station
    return 4;
}

@end

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

NSString * baseURLString = @"http://bbtwechat.100steps.net:8001/";
//NSString * baseURLString = @"http://127.0.0.1:6767";
static const float dataRequestInterval = 5.0;               //Seconds

NSString * const campusBusNotificationName = @"campusBusNotification";
NSString * const retriveCampusBusDataFailNotifName = @"campusBusFailNotification";

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
    self = [super init];
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
    [manager GET:baseURLString parameters:nil progress:nil success:^(NSURLSessionTask *task, id responseObject) {
        //NSLog(@"JSON: %@", responseObject);
        if (responseObject)
        {
            //NSLog(@"%@",[(NSDictionary *)responseObject allKeys]);
            for (int i=0;i<4;i=i+1/*NSString *key in [(NSDictionary *)responseObject allKeys]*/)
            {
                //NSLog(@"obj - %@", responseObject[key]);
                NSError *error = nil;
                BBTCampusBus *bus = [[BBTCampusBus alloc] initWithDictionary:responseObject[i] error:&error];
                //NSLog(@"bus - %@",bus);
                [self.campusBusArray addObject:bus];
            }
            [self postCampusBusNotification];
        }
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        [self postRetriveCampusBusDataFailNotification];
    }];
    
    //To solve memory leak.
    [manager invalidateSessionCancelingTasks:NO];
}

- (void)refresh
{
    [self retriveData];
}

- (void)postCampusBusNotification
{
    [[NSNotificationCenter defaultCenter] postNotificationName:campusBusNotificationName object:self];
}

- (void)postRetriveCampusBusDataFailNotification
{
    [[NSNotificationCenter defaultCenter] postNotificationName:retriveCampusBusDataFailNotifName object:self];
}

- (BOOL)noBusRunningAtStartingStation
{
    int numberOfBusesCurrentlyAtStartingStation = 0;                //The total number of the buses currently at station 1.
    int numberofBusesCurrentlyStoppingAtStartingStation = 0;        //The number of the buses currently stopping at station 1.
    
    for (int i = 0;i < [self.campusBusArray count];i++)
    {
        if (((BBTCampusBus *)self.campusBusArray[i]).StationIndex == 1)
        {
            numberOfBusesCurrentlyAtStartingStation++;
            
            //If any bus is stopping or flying at the starting station, then this bus will not be displayed.
            if ((((BBTCampusBus *)self.campusBusArray[i]).Stop == 1) || (((BBTCampusBus *)self.campusBusArray[i]).Fly == 1))
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
        //If any bus is currently at a normal station(which means it's not the starting station) and it's not flying, then display it.
        if ((((BBTCampusBus *)self.campusBusArray[i]).StationIndex == index) && (((BBTCampusBus *)self.campusBusArray[i]).Fly == 0))
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
        //If any bus is currently at a normal station(which means it's not the starting station) and it's not flying, then display it.
        if ((((BBTCampusBus *)self.campusBusArray[i]).StationIndex == index) && (((BBTCampusBus *)self.campusBusArray[i]).Fly == 0))
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
        if ((((BBTCampusBus *)self.campusBusArray[i]).StationIndex == index) && (((BBTCampusBus *)self.campusBusArray[i]).Stop == 0) && (((BBTCampusBus *)self.campusBusArray[i]).Fly == 0))
        {
                if (((BBTCampusBus *)self.campusBusArray[i]).Direction == 1)
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

- (NSMutableArray *)getRunningBuses
{
    NSMutableArray * runningBusArray = [NSMutableArray array];
    for (BBTCampusBus * campusBus in self.campusBusArray)
    {
        if ((campusBus.Stop == false) && (campusBus.Fly == false))
        {
            [runningBusArray addObject:campusBus];
        }
    }
    return runningBusArray;
}

- (id)getBusInDirection:(BOOL)direction
{
    NSMutableArray * runningBusArray = [self getRunningBuses];
    for (BBTCampusBus * campusBus in runningBusArray) {
        if (campusBus.Direction == direction) {
            return campusBus;
        }
    }
    return nil;
}

@end

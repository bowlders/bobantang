//
//  BBTCampusBusManager.h
//  BoBanTang
//
//  Created by Caesar on 16/1/28.
//  Copyright © 2016年 100steps. All rights reserved.
//
#import "BBTCampusBus.h"
#import <Foundation/Foundation.h>

extern NSString * const campusBusNotificationName;
extern NSString * const retriveCampusBusDataFailNotifName;

@interface BBTCampusBusManager : NSObject

@property (strong, nonatomic) NSArray        * stationNameArray;
@property (strong, nonatomic) NSMutableArray * campusBusArray;

+ (instancetype)sharedCampusBusManager;
- (void)retriveData;
- (void)refresh;

- (BOOL)noBusRunningAtStartingStation;                          //Returns yes if no bus is running at station 1(南门总站), whether all buses staying at station 1 are stopped or no bus is currently at station 1.
- (BOOL)noBusRunningAtStationAtIndex:(NSUInteger)index;         //Returns yes if no bus is running at station of given index.
- (BOOL)oneOrMoreBusRunningAtStationAtIndex:(NSUInteger)index;  //Returns yes if one or more buses are running at the station of the given index.
- (int)directionOfTheBusAtStationIndex:(NSUInteger)index;       //Returns the direction of a running bus, 1 for (toward) south, 0 for (toward) north, 2 for both(which means currently there're at least 2 buses at this station), 4 for invalid state(no bus is currently running at this station).
- (NSMutableArray *)getRunningBuses;                                           //Returns the running buses, if there isn't any running bus, return Null
- (id)getBusInDirection:(BOOL)direction; //direction == false, drive to north, direction == true, dirve to south
@end

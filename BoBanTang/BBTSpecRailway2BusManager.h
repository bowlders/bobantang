//
//  BBTSpecRailway2BusManager.h
//  BoBanTang
//
//  Created by Caesar on 15/11/19.
//  Copyright © 2015年 100steps. All rights reserved.
//

#import <Foundation/Foundation.h>

//Singleton Bus Manager
@interface BBTSpecRailway2BusManager : NSObject

@property (strong, nonatomic) NSMutableArray * directionSouthBuses;              //Store buses whose direction is south
@property (strong, nonatomic) NSMutableArray * directionNorthBuses;              //Store buses whose direction is north
@property (strong, nonatomic) NSArray        * directionSouthStationNames;       //Store station names of the bus whose direction is north
@property (strong, nonatomic) NSArray        * directionNorthStationNames;       //Store station names of the bus whose direction is south

+ (instancetype)sharedBusManager;                                                //Singleton method
- (void)retriveData;                                                             //Retrive bus data／
- (BOOL)noBusInBusArray:(NSArray *)array RunningAtStationSeq:(NSInteger)stationSeq;

@end

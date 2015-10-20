//
//  BBTPreferences1.h
//  bobantang
//
//  Created by skyline on 14/11/30.
//  Copyright (c) 2014年 Bill Bai. All rights reserved.
//

#import "PAPreferences.h"

@interface BBTPreferences : PAPreferences

@property (assign, nonatomic) NSString *firstVersionInstalled;
@property (assign, nonatomic) NSString *lastVersionInstalled;

@property (assign, nonatomic) BOOL hasSeenIntro;
@property (assign, nonatomic) BOOL hasSeenBusHelp;
@property (assign, nonatomic) BOOL hasSeenFlatMapHelp;
@property (assign, nonatomic) BOOL hasSeen3DMapHelp;

@property (assign, nonatomic) BOOL northCampus;
@property (assign, nonatomic) BOOL flatMap;

@property (assign, nonatomic) BOOL busNotifActive;
@property (assign, nonatomic) NSInteger busNotifStationIndex;
@property (assign, nonatomic) BOOL busNotifDirectionNorth;

@end

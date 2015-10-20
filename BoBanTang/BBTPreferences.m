//
//  BBTPreferences1.m
//  bobantang
//
//  Created by skyline on 14/11/30.
//  Copyright (c) 2014年 Bill Bai. All rights reserved.
//

#import "BBTPreferences.h"

@implementation BBTPreferences

@dynamic firstVersionInstalled;
@dynamic lastVersionInstalled;
@dynamic hasSeenBusHelp;
@dynamic hasSeenIntro;
@dynamic hasSeenFlatMapHelp;
@dynamic busNotifStationIndex;
@dynamic busNotifDirectionNorth;
@dynamic busNotifActive;
@dynamic northCampus;
@dynamic flatMap;


- (id)init
{
    if (self = [super init]) {
        NSString *version = [NSBundle mainBundle].infoDictionary[@"CFBundleShortVersionString"];
        NSLog(@"App current version is %@", version);
        if (self.firstVersionInstalled == nil) {
            self.firstVersionInstalled = version;
            NSLog(@"app first launch since installed");
            // Set defaults for new users
            self.hasSeenIntro = NO;
            self.hasSeenFlatMapHelp = NO;
            self.hasSeen3DMapHelp = NO;
            self.hasSeenBusHelp = NO;
            
            self.busNotifActive = NO;
            self.busNotifDirectionNorth = YES;
            self.busNotifStationIndex = 0;
            
            self.northCampus = YES;
            self.flatMap = YES;
        }
        self.lastVersionInstalled = version;
    }
    return self;
}

@end

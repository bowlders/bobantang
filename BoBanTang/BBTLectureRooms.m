//
//  BBTLectureRooms.m
//  BoBanTang
//
//  Created by Hsu Tung Hui on 7/11/15.
//  Copyright © 2015年 BBT. All rights reserved.
//

#import "BBTLectureRooms.h"

@implementation BBTLectureRooms

- (id)init
{
    if ((self = [super init])) {
        self.date = [[NSString alloc] init];
        self.time = [[NSArray alloc] init];
        self.campus = [[NSString alloc] init];
        self.buildings = [[NSString alloc] init];
        self.seletedBulidings = [[NSArray alloc] init];
        self.lectureRooms = [[NSString alloc] init];
    }
    return self;
}

- (NSArray *)filterLectureRooms:(NSMutableArray *)parseResults withFilterConditions:(BBTLectureRooms *)filterConditions
{
    //Filter date
    NSMutableArray *dateFiltered = [[NSMutableArray alloc] init];
    for (NSDictionary *resultsDic in parseResults) {
        NSString *dateFilter = [resultsDic objectForKey:@"date"];
        
        if ([dateFilter isEqualToString:filterConditions.date]) {
            [dateFiltered addObject:resultsDic];
        }
    }
    
    //Campus filter
    NSMutableArray *campusFiltered = [[NSMutableArray alloc] init];
    for (NSDictionary *resultsDic in dateFiltered) {
        NSString *campusFilter = [resultsDic objectForKey:@"campus"];
        
        if ([campusFilter isEqualToString:filterConditions.campus]) {
            [campusFiltered addObject:resultsDic];
        }
    }
    
    //Period Filter
    NSMutableArray *periodFiltered = [[NSMutableArray alloc] init];
    NSArray *selectedPeriods = [[NSArray alloc] initWithArray:[self configurePeriod:filterConditions]];
    
    for (NSDictionary *resultsDic in campusFiltered) {
        NSString *periodFilter = [resultsDic objectForKey:@"period"];
        
        if ([selectedPeriods containsObject:periodFilter]) {
            [periodFiltered addObject:resultsDic];
        }
    }
    
    return periodFiltered;
}

- (NSArray *)configurePeriod:(BBTLectureRooms *)filterConditions
{
    NSMutableArray *seletedPeriod = [[NSMutableArray alloc] init];
    
    for (NSString *timeString in filterConditions.time) {
        if ([timeString isEqualToString:@"上午"]) {
            [seletedPeriod addObject:@"0"];
            [seletedPeriod addObject:@"1"];
        }
        
        if ([timeString isEqualToString:@"下午"]) {
            [seletedPeriod addObject:@"2"];
            [seletedPeriod addObject:@"3"];
        }
        
        if ([timeString isEqualToString:@"晚上"]) {
            [seletedPeriod addObject:@"4"];
        }
    }
    
    return seletedPeriod;
}

@end

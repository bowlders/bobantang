//
//  BBTCampusBus.h
//  BoBanTang
//
//  Created by Caesar on 16/1/28.
//  Copyright © 2016年 100steps. All rights reserved.
//

#import <JSONModel/JSONModel.h>

@interface BBTCampusBus : JSONModel

@property (strong, nonatomic) NSString * Name;
@property (assign, nonatomic) NSUInteger Latitude;
@property (assign, nonatomic) NSUInteger Longitude;
@property (nonatomic)         BOOL       Direction;
@property (assign, nonatomic) NSUInteger Time;
@property (nonatomic)         BOOL       Stop;
@property (strong, nonatomic) NSString * Station;
@property (assign, nonatomic) NSInteger  StationIndex;
@property (assign, nonatomic) NSUInteger Percent;
@property (nonatomic)         BOOL       Fly;

@end

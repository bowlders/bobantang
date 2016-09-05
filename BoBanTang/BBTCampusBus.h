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
@property (assign, nonatomic) NSInteger  Latitude;
@property (assign, nonatomic) NSInteger  Longitude;
@property (nonatomic)         BOOL       Direction;
@property (assign, nonatomic) NSInteger  Time;
@property (nonatomic)         BOOL       Stop;
@property (strong, nonatomic) NSString * Station;
@property (assign, nonatomic) NSInteger  StationIndex;
@property (assign, nonatomic) NSInteger  Percent;
@property (nonatomic)         BOOL       Fly;

@end

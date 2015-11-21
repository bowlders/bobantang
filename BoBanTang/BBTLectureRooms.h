//
//  BBTLectureRooms.h
//  BoBanTang
//
//  Created by Hsu Tung Hui on 7/11/15.
//  Copyright © 2015年 BBT. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BBTLectureRooms : NSObject

@property (nonatomic, copy) NSString *date;
@property (nonatomic, copy) NSArray *time;
@property (nonatomic, copy) NSString *campus;
@property (nonatomic, copy) NSArray *buildings;
@property (nonatomic, copy) NSArray *lectureRooms;

@end

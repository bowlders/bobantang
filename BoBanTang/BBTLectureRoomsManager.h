//
//  BBTLectureRoomsManager.h
//  BoBanTang
//
//  Created by Hsu Tung Hui on 16/2/21.
//  Copyright © 2016年 100steps. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BBTLectureRooms.h"

@interface BBTLectureRoomsManager : NSObject

+ (instancetype)sharedLectureRoomsManager;

- (void)retriveEmptyRoomsWithConditions:(NSDictionary *)conditions;

@property (strong, nonatomic) NSMutableArray *rooms;

@end

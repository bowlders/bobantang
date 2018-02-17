//
//  BBTScheduleDateLocalManager.h
//  波板糖
//
//  Created by zzddn on 2018/2/16.
//  Copyright © 2018年 100steps. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BBTScheduleDate.h"

@interface BBTScheduleDateLocalManager : NSObject
@property(strong,nonatomic) NSNumber *currentWeek;
@property(strong,nonatomic) NSMutableArray<BBTScheduleDate *> *mutCourses;
@property (nonatomic,copy)NSString *whichDay;

//单例
+ (instancetype)shardLocalManager;

- (void)getTheScheduleWithAccount:(NSString *)account andPassword:(NSString *)password andType:(NSString *)type;
- (void)updateLocalScheduleWithNoti:(NSString *)noti;
- (void)fetchCurrentWeek;
- (void)writeToDatabase;
- (void)updateThePrivateScheduleToServer;
- (void)insertOnePieceWithDic:(NSDictionary *)dic;
- (NSArray *)getTheCurrentAndNextCoursesWithAccount:(NSString *)account;
- (NSMutableArray<BBTScheduleDate *> *)fetchThePrivateScheduleFromDatabase;

@end

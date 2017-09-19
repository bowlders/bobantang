//
//  ScheduleDateManager.h
//  timeTable1
//
//  Created by zzddn on 2017/8/26.
//  Copyright © 2017年 嘿嘿的客人. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ScheduleDateManager : NSObject
typedef void(^ScheduleBlo)(ScheduleDateManager *current, ScheduleDateManager * next);
@property(nonatomic,copy)NSString *location;
@property(nonatomic,copy)NSString *day;
@property(nonatomic,copy)NSString *week;
@property(nonatomic,copy)NSString *teacherName;
@property(nonatomic,copy)NSString *dayTime;
@property(nonatomic,copy)NSString *weekStatus;
@property(nonatomic,copy)NSString *courseName;
@property (nonatomic,strong)NSMutableArray *mutCourseArray;

@property (nonatomic,copy)NSString *currentWeek;
@property (nonatomic,copy)NSString *whichDay;

@property (nonatomic,copy)NSString *account;

@property (nonatomic,copy)ScheduleBlo block;

- (void)fetchCurrentWeek;
- (void)getTheScheduleWithAccount:(NSString *)account andPassword:(NSString *)password andType:(NSString *)type;
- (void)updateLocalScheduleWithNoti:(NSString *)noti;
- (void)createLocalTable;
+ (instancetype)sharedManager;
- (void)insertOnePieceWithDic:(NSDictionary *)dic;
- (BOOL)fetchThePrivateScheduleFromDatabase;
- (void)updateThePrivateScheduleToServerWithAccount:(NSString *)account;
- (void)writeToDatabase;

- (void)getTheCurrentAndNextCoursesWithAccount:(NSString *)account;
@end

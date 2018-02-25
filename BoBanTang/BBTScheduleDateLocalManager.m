//
//  BBTScheduleDateLocalManager.m
//  波板糖
//
//  Created by zzddn on 2018/2/16.
//  Copyright © 2018年 100steps. All rights reserved.
//

#import "BBTScheduleDateLocalManager.h"
#import <sqlite3.h>
#import "BBTCurrentUserManager.h"
#import <AFHTTPSessionManager.h>
static NSString *tableURL = @"http://apiv2.100steps.net/schedule";
@interface BBTScheduleDateLocalManager()
/**
 获取本地记录中的周数

 @return 返回周数
 */
- (NSNumber *)fetchCurrentLocalRecordOfWeek;

@end

@implementation BBTScheduleDateLocalManager
static sqlite3 *_db;
static BBTScheduleDateLocalManager *manager = nil;

+ (instancetype)shardLocalManager{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (manager == nil){
            manager = [BBTScheduleDateLocalManager new];
        }
    });
    return manager;
}

- (NSNumber *)currentWeek{
    if (_currentWeek == nil){
        _currentWeek = [self fetchCurrentLocalRecordOfWeek];
    }
    return _currentWeek;
}

- (void)fetchCurrentWeek{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json",@"text/json",@"text/javascript",@"text/plain",@"text/html",nil];
    NSDictionary *dic = @{
                          @"method":@"week"
                          };
    NSString *path = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)lastObject]stringByAppendingPathComponent:@"week.plist"];
    
    NSString *account = [BBTCurrentUserManager sharedCurrentUserManager].currentUser.account;
    NSString *password = [BBTCurrentUserManager sharedCurrentUserManager].currentUser.password;
    
    [manager POST:tableURL parameters:dic progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        //写入本地
        NSString *tmp = responseObject[@"week"];
        self.currentWeek = [NSNumber numberWithInteger:tmp.integerValue];
        NSDictionary *dic = @{
                               @"current":self.currentWeek
                               };
        [dic writeToFile:path atomically:NO];
        
        //接着发送获取课表的请求
        [self getTheScheduleWithAccount:account andPassword:password andType:@"get"];

    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        [self getTheScheduleWithAccount:account andPassword:password andType:@"get"];
    }];
}

- (void)getTheScheduleWithAccount:(NSString *)account andPassword:(NSString *)password andType:(NSString *)type{
    NSDictionary *dic;
    
    if (account&&password){
        dic = @{
                @"method":type,
                @"account":account,
                @"password":password
                };
    }else{
        dic = @{
                @"method":type,
                @"account":[BBTCurrentUserManager sharedCurrentUserManager].currentUser.account,
                @"password":[BBTCurrentUserManager sharedCurrentUserManager].currentUser.password
                };
    }
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json",@"text/json",@"text/javascript",@"text/plain",@"text/html",nil];
    [manager POST:tableURL parameters:dic progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        //防止服务器崩掉时，把本地数据给清空
        NSString *errorString = [responseObject valueForKey:@"error"];
        if (errorString != nil) {
            //发送失败通知
            [[NSNotificationCenter defaultCenter] postNotificationName:[NSString stringWithFormat:@"The%@ScheduleFailed",type] object:nil];
            return;
        }
        
        NSArray *courses2 = [[responseObject valueForKey:@"timetable"] valueForKey:@"content"];
        //NSLog(@"%@",responseObject);
        NSMutableArray<BBTScheduleDate *> *tmpCouses = [NSMutableArray arrayWithCapacity:10];
        int i=0;
        for (NSArray *courses in courses2) {
            for (NSDictionary *course in courses)
            {
                BBTScheduleDate *scheduleDate = [BBTScheduleDate new];
                [scheduleDate setValuesForKeysWithDictionary:course];
                
                //把英文换成中文
                NSArray *chineseDayArr = [NSArray arrayWithObjects:@"周一",@"周二",@"周三",@"周四",@"周五",@"周六",@"周日",nil];
                NSArray *EngDayArr = @[@"Monday",@"Tuesday",@"Wednesday",@"Thursday",@"Friday",@"Saturday",@"Sunday"];
                if ([EngDayArr containsObject:scheduleDate.day]){
                    scheduleDate.day = chineseDayArr[[EngDayArr indexOfObject:scheduleDate.day]];
                }
                
                //把单双周筛选出来
                if ([scheduleDate.weekStatus isEqual:@"1"]){
                    scheduleDate.weekStatus = @"0";
                    scheduleDate.week = [self changeTypeWithOdd:YES andWeek:scheduleDate.week];
                }else if ([scheduleDate.weekStatus isEqual:@"2"]){
                    scheduleDate.week = [self changeTypeWithOdd:NO andWeek:scheduleDate.week];
                    scheduleDate.weekStatus = @"0";
                }
                
                if(i){
                    BBTScheduleDate *before = [tmpCouses objectAtIndex:i-1];
                    if([before.courseName isEqualToString:scheduleDate.courseName]&&[before.teacherName isEqualToString:scheduleDate.teacherName]&&[before.dayTime isEqualToString:scheduleDate.dayTime]&&[before.day isEqualToString:scheduleDate.day])
                    {
                        NSString *beforeNum = [before.week componentsSeparatedByString:@"-"][0];
                        NSString *nowNum = [scheduleDate.week componentsSeparatedByString:@"-"][0];
                        if (beforeNum.integerValue > nowNum.integerValue){
                            before.week = [scheduleDate.week stringByAppendingString:[NSString stringWithFormat:@" %@",before.week]];
                        }else{
                            before.week = [[before.week stringByAppendingString:@" "] stringByAppendingString:scheduleDate.week];
                        }
                        continue;
                    }
                    
                }
                [tmpCouses addObject:scheduleDate];
                i++;
            }
        }
        self.mutCourses = tmpCouses;
        [[NSNotificationCenter defaultCenter] postNotificationName:[NSString stringWithFormat:@"The%@ScheduleGet",type] object:nil];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [[NSNotificationCenter defaultCenter] postNotificationName:[NSString stringWithFormat:@"The%@ScheduleFailed",type] object:nil];
    }];
}

- (NSString *)changeTypeWithOdd:(BOOL)isOdd andWeek:(NSString *)rawWeek{
    NSString *returnStr = @"";
    NSArray *tmpArr = [rawWeek componentsSeparatedByString:@" "];
    for (NSString *tmpStr in tmpArr) {
        NSArray<NSString *> *beginAndEnd = [tmpStr componentsSeparatedByString:@"-"];
        for (NSInteger i=beginAndEnd[0].integerValue; i<=beginAndEnd[1].integerValue;i++){
            if (!isOdd){
                if (i%2 == 0){
                    returnStr = [returnStr stringByAppendingString:[NSString stringWithFormat:@"%ld ",(long)i]];
                }
            }else{
                if (i%2 != 0){
                    returnStr = [returnStr stringByAppendingString:[NSString stringWithFormat:@"%ld ",(long)i]];
                }
            }
        }
    }
    returnStr = [returnStr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    return returnStr;
}

- (void)updateThePrivateScheduleToServer{
    
    NSString *account = [BBTCurrentUserManager sharedCurrentUserManager].currentUser.account;
    NSString *password = [BBTCurrentUserManager sharedCurrentUserManager].currentUser.password;
    
    NSDictionary *dic;
    NSMutableArray *bigArr = [NSMutableArray arrayWithCapacity:self.mutCourses.count];
    for (int i=0; i<self.mutCourses.count; i++){
        BBTScheduleDate *tmpManager = self.mutCourses[i];
        NSDictionary *tmpDic = @{
                                 @"courseName":tmpManager.courseName,
                                 @"day":tmpManager.day,
                                 @"teacherName":tmpManager.teacherName,
                                 @"location":tmpManager.location,
                                 @"dayTime":tmpManager.dayTime,
                                 @"week":tmpManager.week,
                                 @"weekStatus":tmpManager.weekStatus
                                 };
        [bigArr addObject:tmpDic];
    }
    
    NSArray *array = [NSArray arrayWithObject:bigArr];
    NSDictionary *contentDic = @{
                                 @"content":array,
                                 @"timetable_time":@"",
                                 };
    
    NSData *data = [NSJSONSerialization dataWithJSONObject:contentDic options:0 error:nil];
    NSString *string = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    
    dic = @{
            @"method":@"set",
            @"password":account,
            @"account":password,
            @"timetable":string
            };
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json",@"text/json",@"text/javascript",@"text/plain",@"text/html",nil];
    [manager POST:tableURL parameters:dic progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        //NSLog(@"%@",responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        //NSLog(@"%@",error);
    }];
}

//----------------------------------------------------------------------------------------------------------------------------//

- (void)writeToDatabase{
    [self get_db];
    [self dropTablewithTableName:[BBTCurrentUserManager sharedCurrentUserManager].currentUser.name];
    [self createLocalTable];
    [self insertTable];
}

- (void)insertOnePieceWithDic:(NSDictionary *)dic{
    NSString *name = [BBTCurrentUserManager sharedCurrentUserManager].currentUser.name;
    NSString *NSsql = [NSString stringWithFormat:@"insert into %@(courseName, day, teacherName, location, dayTime, week, weekStatus) values('%@', '%@', '%@', '%@', '%@', '%@', '%@');",name,dic[@"courseName"],dic[@"day"],dic[@"teacherName"],dic[@"location"],dic[@"dayTime"],dic[@"week"],dic[@"weekStatus"]];
    char *error = NULL;
    int result = sqlite3_exec(_db, NSsql.UTF8String, NULL, NULL, &error);
    if (result != SQLITE_OK){
        NSLog(@"写入失败，失败理由为:%s",error);
    }
}

- (NSString *)whichDay{
    NSDate *date = [NSDate date];
    NSDateFormatter *dateformatter = [[NSDateFormatter alloc]init];
    [dateformatter setDateFormat:@"EEEE"];
    NSString *engDay = [dateformatter stringFromDate:date];
    NSArray *chineseDayArr = [NSArray arrayWithObjects:@"周一",@"周二",@"周三",@"周四",@"周五",@"周六",@"周日",nil];
    NSArray *EngDayArr = @[@"Monday",@"Tuesday",@"Wednesday",@"Thursday",@"Friday",@"Saturday",@"Sunday"];
    _whichDay = chineseDayArr[[EngDayArr indexOfObject:engDay]];
    return _whichDay;
}

- (void)updateLocalScheduleWithNoti:(NSString *)noti{
    [self get_db];
    if ([noti isEqualToString:@"ThegetScheduleGet"]){
        [self dropTablewithTableName:[BBTCurrentUserManager sharedCurrentUserManager].currentUser.name];
        [self createLocalTable];
        [self insertTable];
    }else if ([noti isEqualToString:@"ThegetScheduleFailed"]){
        //如果获取失败了就只建立一个空表
        [self createLocalTable];
    }else if ([noti isEqualToString:@"ThefindTJScheduleGet"]){
        [self dropTablewithTableName:[BBTCurrentUserManager sharedCurrentUserManager].currentUser.name];
        [self createLocalTable];
        [self insertTable];
        [self updateThePrivateScheduleToServer];
    }
}

- (void)insertTable{
    NSString *name = [BBTCurrentUserManager sharedCurrentUserManager].currentUser.name;
    for (BBTScheduleDate *manager in self.mutCourses) {
        NSString *NSsql = [NSString stringWithFormat:@"insert into %@(courseName, day, teacherName, location, dayTime, week, weekStatus) values('%@', '%@', '%@', '%@', '%@', '%@', '%@');",name,manager.courseName,manager.day,manager.teacherName,manager.location,manager.dayTime,manager.week,manager.weekStatus];
        char *err = NULL;
        int result = sqlite3_exec(_db, NSsql.UTF8String, NULL, NULL, &err);
        if (result != SQLITE_OK){
            NSLog(@"写入表格失败，失败理由:%s",err);
        }
    }
}

- (void)dropTablewithTableName:(NSString *)tableName{
    NSString *NSsql = [NSString stringWithFormat:@"DROP TABLE if exists %@",tableName];
    char *err;
    if(sqlite3_exec(_db, NSsql.UTF8String, NULL, NULL, &err) != SQLITE_OK){
        NSLog(@"删除表失败，理由是：%s",err);
    }
}

- (NSMutableArray<BBTScheduleDate *> *)fetchThePrivateScheduleFromDatabase{
    [self get_db];
    
    NSMutableArray<BBTScheduleDate *> *tmpCourses;
    
    NSString *NSsql = [NSString stringWithFormat:@"select * from %@",([BBTCurrentUserManager sharedCurrentUserManager]).currentUser.name];
    sqlite3_stmt *stmt = NULL;
    int result = sqlite3_prepare(_db, NSsql.UTF8String, -1, &stmt, NULL);
    if (result == SQLITE_OK){
        tmpCourses = [NSMutableArray arrayWithCapacity:10];
        while (sqlite3_step(stmt) == SQLITE_ROW){
            BBTScheduleDate *tmpScheduleDate = [BBTScheduleDate new];
            tmpScheduleDate.courseName = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 0)];
            tmpScheduleDate.day = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 1)];
            tmpScheduleDate.teacherName = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 2)];
            tmpScheduleDate.location = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 3)];
            tmpScheduleDate.dayTime = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 4)];
            tmpScheduleDate.week = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 5)];
            tmpScheduleDate.weekStatus = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 6)];
            [tmpCourses addObject:tmpScheduleDate];
        }
    }else{
        NSLog(@"出数据库中取出本地课表时出错！");
        //第一次打开没有本地表，就新创建一个出来
        [self createLocalTable];
        sqlite3_finalize(stmt);
        return nil;
    }
    sqlite3_finalize(stmt);
    if (tmpCourses.count == 0){
        return nil;
    }
    return tmpCourses;
}

- (int)get_db{
    if (_db != nil){
        return SQLITE_OK;
    }
    //获取数据库文件
    NSString *fileName = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)lastObject]stringByAppendingPathComponent:@"schedule.sqlite"];
    //(创建)打开数据库
    int result = sqlite3_open(fileName.UTF8String, &_db);
    if (result != SQLITE_OK){
        NSLog(@"打开bbt课表的数据库失败，记录出在课表的Model文件中");
    }
    //NSLog(@"%@",fileName);
    return result;
}

- (void)createLocalTable{
    BBTCurrentUserManager *userManager = [BBTCurrentUserManager sharedCurrentUserManager];
    NSString *sqlString = [NSString stringWithFormat:@"create table if not exists %@(courseName text,day text,teacherName text,location text,dayTime text,week text,weekStatus text);",userManager.currentUser.name];
    //NSLog(@"%@",sqlString);
    const char *sql = [sqlString UTF8String];
    char *errorMesg = NULL;
    int result = sqlite3_exec(_db, sql, NULL, NULL, &errorMesg);
    if (result != SQLITE_OK){
        NSLog(@"建BBT课程表失败,错误信息%s",errorMesg);
        return;
    }
}

- (NSNumber *)fetchCurrentLocalRecordOfWeek{
    NSString *path = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)lastObject]stringByAppendingPathComponent:@"week.plist"];
    NSDictionary *dic = [NSDictionary dictionaryWithContentsOfFile:path];
    if (dic[@"current"]){
        return dic[@"current"];
    }
    return @1;
}

- (NSArray *)getTheCurrentAndNextCoursesWithAccount:(NSString *)account{
    self.mutCourses = [self fetchThePrivateScheduleFromDatabase];
    if (self.mutCourses != nil && self.currentWeek != nil){
        NSInteger num = 0;
        if ([self isBetweenFromStart:@"0:00" andEnd:@"8:45"]){
            num = 1;
        }else if ([self isBetweenFromStart:@"8:46" andEnd:@"9:40"]){
            num = 2;
        }else if ([self isBetweenFromStart:@"9:41" andEnd:@"10:45"]){
            num = 3;
        }else if ([self isBetweenFromStart:@"10:46" andEnd:@"11:40"]){
            num = 4;
        }else if ([self isBetweenFromStart:@"11:41" andEnd:@"15:15"]){
            num = 5;
        }else if ([self isBetweenFromStart:@"15:16" andEnd:@"16:10"]){
            num = 6;
        }else if ([self isBetweenFromStart:@"16:11" andEnd:@"17:05"]){
            num = 7;
        }else if ([self isBetweenFromStart:@"17:06" andEnd:@"18:00"]){
            num = 8;
        }else if ([self isBetweenFromStart:@"18:01" andEnd:@"19:45"]){
            num = 9;
        }else if ([self isBetweenFromStart:@"19:46" andEnd:@"20:40"]){
            num = 10;
        }else if ([self isBetweenFromStart:@"20:41" andEnd:@"21:35"]){
            num = 11;
        }
        NSArray<BBTScheduleDate *> *CurrentWeekCourses = [self isInCurrentWeek];
        NSMutableArray<BBTScheduleDate *> *currentDayCourses = [NSMutableArray array];
        
        //首先根据周数进行一次课表筛选，如星期一，就只留下星期一的课表
        for (BBTScheduleDate *mana in CurrentWeekCourses){
            if ([mana.day isEqual:self.whichDay]){
                [currentDayCourses addObject:mana];
            }
        }
        
        [currentDayCourses sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
            BBTScheduleDate *manager1 = obj1;
            BBTScheduleDate *manager2 = obj2;
            if ([manager1.dayTime componentsSeparatedByString:@"."][0].integerValue >[manager2.dayTime componentsSeparatedByString:@"."][0].integerValue){
                return NSOrderedDescending;
            }
            if([manager1.dayTime componentsSeparatedByString:@"."][0].integerValue <[manager2.dayTime componentsSeparatedByString:@"."][0].integerValue){
                return NSOrderedAscending;
            }
            return NSOrderedDescending;
        }];
        
        NSMutableArray *tmpArr2 = [NSMutableArray arrayWithCapacity:2];
        NSInteger returnCourseCount = 0;
        for (BBTScheduleDate *mana in currentDayCourses) {
            NSArray<NSString *> *beginAndEnd = [mana.dayTime componentsSeparatedByString:@"-"];
            if (num!=0 && beginAndEnd[1].integerValue >= num){
                [tmpArr2 addObject:mana];
                returnCourseCount++;
                if ([currentDayCourses indexOfObject:mana] != currentDayCourses.count-1){
                    [tmpArr2 addObject: currentDayCourses[[currentDayCourses indexOfObject:mana]+1]];
                }
                break;
            }
        }
        if (returnCourseCount >= 2){
            //self.block(tmpArr2[0],tmpArr2[1]);
        }else if (returnCourseCount == 1){
            //self.block(tmpArr2[0],nil);
        }else if (returnCourseCount == 0){
            //self.block(nil,nil);
        }
        return tmpArr2;
    }
    return nil;
}

-(BOOL)isBetweenFromStart:(NSString *)startTime andEnd:(NSString *)endTime{
    //获取当前时间
    NSDate *today = [NSDate date];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    
    // 时间格式,建议大写    HH 使用 24 小时制；hh 12小时制
    [dateFormat setDateFormat:@"HH:mm"];
    
    NSString *todayStr = [dateFormat stringFromDate:today];//将日期转换成字符串
    today = [dateFormat dateFromString:todayStr];//转换成NSDate类型。日期置为方法默认日期
    // strar 格式 "5:30"  end: "19:08"
    NSDate *start = [dateFormat dateFromString:startTime];
    NSDate *expire = [dateFormat dateFromString:endTime];
    
    if ([today compare:start] == NSOrderedDescending && [today compare:expire] == NSOrderedAscending) {
        return YES;
    }
    return NO;
}
- (NSArray *)isInCurrentWeek{
    NSMutableArray *isOnArr = [NSMutableArray array];
    for (BBTScheduleDate *singleData in self.mutCourses) {
        NSArray *timeArr = [singleData.week componentsSeparatedByString:@" "];
        BOOL isON = NO;
        for (NSString *string in timeArr) {
            if ([string containsString:@"-"]){
                NSArray<NSString *> *tmp = [string componentsSeparatedByString:@"-"];
                if(tmp[1].integerValue >= self.currentWeek.integerValue && tmp[0].integerValue <= self.currentWeek.integerValue){
                    isON = YES;
                    [isOnArr addObject:singleData];
                }
            }else{
                if (self.currentWeek.integerValue == string.integerValue){
                    isON = YES;
                    [isOnArr addObject:singleData];
                }
            }
        }
    }
    return isOnArr.copy;
}

- (void)deleteAllCourses{
    [self get_db];
    [self dropTablewithTableName:[BBTCurrentUserManager sharedCurrentUserManager].currentUser.name];
    [self createLocalTable];
    [self.mutCourses removeAllObjects];
    [self updateThePrivateScheduleToServer];
}
@end

//
//  ScheduleDateManager.m
//  timeTable1
//
//  Created by zzddn on 2017/8/26.
//  Copyright © 2017年 嘿嘿的客人. All rights reserved.
//

#import "ScheduleDateManager.h"
#import <AFHTTPSessionManager.h>
#import <sqlite3.h>
#import "BBTCurrentUserManager.h"
@interface ScheduleDateManager()
@end

@implementation ScheduleDateManager

static sqlite3 *_db;
static ScheduleDateManager *manager;

+ (instancetype)sharedManager{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (manager == nil){
            manager = [ScheduleDateManager new];
        }
    });
    return manager;
}
- (void)fetchCurrentWeek{
    NSString *targetURL = @"http://babel.100steps.net/timetable/";
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json",@"text/json",@"text/javascript",@"text/plain",@"text/html",nil];
    NSDictionary *dic = @{
                          @"method":@"week"
                          };
    NSString *path = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)lastObject]stringByAppendingPathComponent:@"week.plist"];
    [manager POST:targetURL parameters:dic progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSString *tmp = responseObject[@"week"];
        self.currentWeek = [NSString stringWithFormat:@"%d",tmp.intValue];
        NSDictionary *dic2 = @{
                              @"current":self.currentWeek
                              };
        [dic2 writeToFile:path atomically:NO];
        NSString *account = [BBTCurrentUserManager sharedCurrentUserManager].currentUser.account;
        if (account != nil){
        [self getTheScheduleWithAccount:account andPassword:nil andType:@"get"];
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSString *account = [BBTCurrentUserManager sharedCurrentUserManager].currentUser.account;
        if (account != nil){
        [self getTheScheduleWithAccount:account andPassword:nil andType:@"get"];
        }
    }];
}
- (BOOL)fetchThePrivateScheduleFromDatabase{
    [self get_db];
    NSString *NSsql = @"select * from schedule";
    sqlite3_stmt *stmt = NULL;
    int result = sqlite3_prepare(_db, NSsql.UTF8String, -1, &stmt, NULL);
    if (result == SQLITE_OK){
        if(self.mutCourseArray!= nil){
            [self.mutCourseArray removeAllObjects];
        }else{
            self.mutCourseArray = [NSMutableArray arrayWithCapacity:10];
        }
        while(sqlite3_step(stmt)== SQLITE_ROW){
            ScheduleDateManager *tmpManager = [[ScheduleDateManager alloc]init];
            tmpManager.courseName = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 0)];
            tmpManager.day = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 1)];
            tmpManager.teacherName = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 2)];
            tmpManager.location = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 3)];
            tmpManager.dayTime = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 4)];
            tmpManager.week = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 5)];
            tmpManager.weekStatus = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 6)];
            [self.mutCourseArray addObject:tmpManager];
        }
    }else{
        NSLog(@"从数据库中取出课表时出错!");
        sqlite3_finalize(stmt);
        return NO;
    }
    sqlite3_finalize(stmt);
    return YES;
}
- (void)updateThePrivateScheduleToServerWithAccount:(NSString *)account{
    NSDictionary *dic;
    NSMutableArray *bigArr = [NSMutableArray arrayWithCapacity:self.mutCourseArray.count];
    for (int i=0; i<self.mutCourseArray.count; i++){
        ScheduleDateManager *tmpManager = self.mutCourseArray[i];
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
            @"account":account,
            @"timetable":string
            };
    
    NSString *targetURL = @"http://babel.100steps.net/timetable/";
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json",@"text/json",@"text/javascript",@"text/plain",@"text/html",nil];
    [manager POST:targetURL parameters:dic progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"%@",responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"%@",error);
    }];
}

- (void)getTheScheduleWithAccount:(nonnull NSString *)account andPassword:(NSString *)password andType:(NSString *)type{
    NSDictionary *dic;
    if(password){
        dic = @{
                @"method":type,
                @"account":account,
                @"password":password
                };
    }else{
        dic = @{
                @"method":type,
                @"account":account
                };
    }
    
    NSString *targetURL = @"http://babel.100steps.net/timetable/";
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json",@"text/json",@"text/javascript",@"text/plain",@"text/html",nil];
    [manager POST:targetURL parameters:dic progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSArray *courses2 = [[responseObject valueForKey:@"timetable"] valueForKey:@"content"];
        NSLog(@"%@",responseObject);
        self.mutCourseArray = [NSMutableArray arrayWithCapacity:10];
        int i=0;
        for (NSArray *courses in courses2) {
            for (NSDictionary *course in courses)
            {
                ScheduleDateManager *manager = [ScheduleDateManager new];
                [manager setValuesForKeysWithDictionary:course];
                
                //把英文换成中文
                NSArray *chineseDayArr = [NSArray arrayWithObjects:@"周一",@"周二",@"周三",@"周四",@"周五",@"周六",@"周日",nil];
                NSArray *EngDayArr = @[@"Monday",@"Tuesday",@"Wednesday",@"Thursday",@"Friday",@"Saturday",@"Sunday"];
                if ([EngDayArr containsObject:manager.day]){
                    manager.day = chineseDayArr[[EngDayArr indexOfObject:manager.day]];
                }
                
                //把单双周筛选出来
                if ([manager.weekStatus isEqual:@"1"]){
                    manager.weekStatus = @"0";
                    manager.week = [self changeTypeWithOdd:YES andWeek:manager.week];
                }else if ([manager.weekStatus isEqual:@"2"]){
                    manager.week = [self changeTypeWithOdd:NO andWeek:manager.week];
                    manager.weekStatus = @"0";
                }
                
                if(i){
                    ScheduleDateManager *before = [_mutCourseArray objectAtIndex:i-1];
                    if([before.courseName isEqualToString:manager.courseName]&&[before.teacherName isEqualToString:manager.teacherName]&&[before.dayTime isEqualToString:manager.dayTime]&&[before.day isEqualToString:manager.day])
                    {
                        NSString *beforeNum = [before.week componentsSeparatedByString:@"-"][0];
                        NSString *nowNum = [manager.week componentsSeparatedByString:@"-"][0];
                        if (beforeNum.integerValue > nowNum.integerValue){
                            before.week = [manager.week stringByAppendingString:[NSString stringWithFormat:@" %@",before.week]];
                        }else{
                        before.week = [[before.week stringByAppendingString:@" "] stringByAppendingString:manager.week];
                        }
                        continue;
                    }
                    
                }
                [_mutCourseArray addObject:manager];
                i++;
            }
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:[NSString stringWithFormat:@"The%@ScheduleGet",type] object:nil];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [[NSNotificationCenter defaultCenter] postNotificationName:[NSString stringWithFormat:@"The%@ScheduleFailed",type] object:nil];
    }];
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
        NSLog(@"打开数据库失败");
    }
    NSLog(@"%@",fileName);
    return result;
}
- (void)createLocalTable{
        const char *sql = "create table if not exists schedule(courseName text,day text,teacherName text,location text,dayTime text,week text,weekStatus text);";
        char *errorMesg = NULL;
        int result = sqlite3_exec(_db, sql, NULL, NULL, &errorMesg);
        if (result != SQLITE_OK){
            NSLog(@"建表失败,错误信息%s",errorMesg);
        }
}
- (void)writeToDatabase{
    [self get_db];
    [self dropTablewithTableName:@"schedule"];
    [self createLocalTable];
    [self insertTable];
}
- (void)updateLocalScheduleWithNoti:(NSString *)noti{
        [self get_db];
    if ([noti isEqualToString:@"ThegetScheduleGet"]){
        [self dropTablewithTableName:@"schedule"];
        [self createLocalTable];
        [self insertTable];
    }else if ([noti isEqualToString:@"ThegetScheduleFailed"]){
       
    }else if ([noti isEqualToString:@"ThefindTJScheduleGet"]){
        [self dropTablewithTableName:@"schedule"];
        [self createLocalTable];
        [self insertTable];
        NSString *account = [BBTCurrentUserManager sharedCurrentUserManager].currentUser.account;
        if (account != nil){
        [self updateThePrivateScheduleToServerWithAccount:account];
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

- (void)insertTable{
    for (ScheduleDateManager *manager in self.mutCourseArray) {
        NSString *NSsql = [NSString stringWithFormat:@"insert into schedule(courseName, day, teacherName, location, dayTime, week, weekStatus) values('%@', '%@', '%@', '%@', '%@', '%@', '%@');",manager.courseName,manager.day,manager.teacherName,manager.location,manager.dayTime,manager.week,manager.weekStatus];
        char *err = NULL;
        int result = sqlite3_exec(_db, NSsql.UTF8String, NULL, NULL, &err);
        if (result != SQLITE_OK){
            NSLog(@"写入表格失败，失败理由:%s",err);
        }
    }
}
- (void)insertOnePieceWithDic:(NSDictionary *)dic{
    NSString *NSsql = [NSString stringWithFormat:@"insert into schedule(courseName, day, teacherName, location, dayTime, week, weekStatus) values('%@', '%@', '%@', '%@', '%@', '%@', '%@');",dic[@"courseName"],dic[@"day"],dic[@"teacherName"],dic[@"location"],dic[@"dayTime"],dic[@"week"],dic[@"weekStatus"]];
    char *error = NULL;
    int result = sqlite3_exec(_db, NSsql.UTF8String, NULL, NULL, &error);
    if (result != SQLITE_OK){
        NSLog(@"写入失败，失败理由为:%s",error);
    }
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
- (NSString *)account{
    if (_account == nil){
        _account = [BBTCurrentUserManager sharedCurrentUserManager].currentUser.account;
    }
    return _account;
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
- (NSString *)currentWeek{
    if (_currentWeek == nil){
        //获取当前周
        NSString *path = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)lastObject]stringByAppendingPathComponent:@"week.plist"];
        NSDictionary *dic2 = [NSDictionary dictionaryWithContentsOfFile:path];
        if (dic2[@"current"]){
            _currentWeek = (NSString *)dic2[@"current"];
        }
    }
    return _currentWeek;
}
- (void)getTheCurrentAndNextCoursesWithAccount:(NSString *)account{
    [self fetchThePrivateScheduleFromDatabase];
    if (self.mutCourseArray != nil){
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
        NSMutableArray *tmpArr = [NSMutableArray array];
        for (ScheduleDateManager *mana in self.mutCourseArray){
            if ([mana.day isEqual:self.whichDay]){
                [tmpArr addObject:mana];
            }
        }
        [tmpArr sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
            ScheduleDateManager *manager1 = obj1;
            ScheduleDateManager *manager2 = obj2;
            if ([manager1.dayTime componentsSeparatedByString:@"."][0].integerValue >[manager2.dayTime componentsSeparatedByString:@"."][0].integerValue){
                return NSOrderedAscending;
            }
            if([manager1.dayTime componentsSeparatedByString:@"."][0].integerValue <[manager2.dayTime componentsSeparatedByString:@"."][0].integerValue){
                return NSOrderedDescending;
            }
            return NSOrderedDescending;
        }];
        
        NSMutableArray *tmpArr2 = [NSMutableArray arrayWithCapacity:2];
        for (ScheduleDateManager *mana in tmpArr) {
            NSArray<NSString *> *beginAndEnd = [mana.dayTime componentsSeparatedByString:@"-"];
            if (beginAndEnd[0].integerValue <= num && beginAndEnd[1].integerValue >= num){
                    [tmpArr2 addObject:mana];
                if ([tmpArr indexOfObject:mana] != tmpArr.count-1){
                    [tmpArr2 addObject: tmpArr[[tmpArr indexOfObject:mana]+1]];
                }
                break;
            }
        }
        if (tmpArr2.count >= 2){
            self.block(tmpArr2[0],tmpArr2[1]);
        }else if (tmpArr2.count == 1){
            self.block(tmpArr2[0],nil);
        }else if (tmpArr2.count == 0){
            self.block(nil,nil);
        }
    }
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
@end

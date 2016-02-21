//
//  BBTLectureRoomsManager.m
//  BoBanTang
//
//  Created by Hsu Tung Hui on 16/2/21.
//  Copyright © 2016年 100steps. All rights reserved.
//

#import "BBTLectureRoomsManager.h"
#import <AFNetworking/AFNetworking.h>

static NSString * emptyRoomURL = @"http://218.192.166.167/api/protype.php?table=emptyroom&method=get&data=";
NSString * kDidGetEmptyRoomsNotificaionName = @"didGetEmptyRoomsNotificaionName";
NSString * kFailGetEmptyRoomsNotificaionName = @"failGetEmptyRoomsNotificaionName";

@implementation BBTLectureRoomsManager

+ (instancetype)sharedLectureRoomsManager
{
    static BBTLectureRoomsManager *_manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _manager = [[BBTLectureRoomsManager alloc] init];
    });
    return _manager;
}

- (void)retriveEmptyRoomsWithConditions:(NSDictionary *)conditions
{
    NSError *error;
    NSData *data = [NSJSONSerialization dataWithJSONObject:conditions options:NSJSONWritingPrettyPrinted error:&error];
    NSString *jsonString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSString *stringCleanPath = [jsonString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    NSString *completeUrl = [emptyRoomURL stringByAppendingString:stringCleanPath];
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    [manager GET:completeUrl parameters:nil progress:nil success:^(NSURLSessionTask *task, id responseObject) {
        if (responseObject)
        {
            BBTLectureRooms *lectureRooms = [[BBTLectureRooms alloc] init];
            self.rooms = [[NSMutableArray alloc] init
                                     ];
            for (NSDictionary *resultDic in responseObject) {
                lectureRooms.date = resultDic[@"date"];
                lectureRooms.period = resultDic[@"period"];
                lectureRooms.campus = resultDic[@"campus"];
                lectureRooms.buildings = resultDic[@"building"];
                lectureRooms.lectureRooms = resultDic[@"room"];
                
                [self.rooms addObject:resultDic];
            }
            [self didGetEmptyRoomsNotificaion];
        } else {
            [self failGetEmptyRoomNotification];
        }
    } failure:^(NSURLSessionTask *task, NSError *error) {
        NSLog(@"Error: %@",error);
        [self failGetEmptyRoomNotification];
    }];
}

- (void)didGetEmptyRoomsNotificaion
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kDidGetEmptyRoomsNotificaionName object:nil];
}

- (void)failGetEmptyRoomNotification
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kFailGetEmptyRoomsNotificaionName object:nil];
}

@end

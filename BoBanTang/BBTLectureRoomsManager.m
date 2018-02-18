//
//  BBTLectureRoomsManager.m
//  BoBanTang
//
//  Created by Hsu Tung Hui on 16/2/21.
//  Copyright © 2016年 100steps. All rights reserved.
//

#import "BBTLectureRoomsManager.h"
#import <AFNetworking/AFNetworking.h>

static NSString * emptyRoomURL = @"http://apiv2.100steps.net/emptyroom";
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
    NSMutableString *completeUrl = [NSMutableString stringWithString:[emptyRoomURL stringByAppendingString:@"?"]];
    
    for (NSString *key in [conditions allKeys]) {
        if ([conditions[key] isKindOfClass:[NSArray class]]){
            NSMutableString *tmpString = [NSMutableString string];
            for (int i =0; i< [(conditions[key]) count]; i++){
                [tmpString appendString:conditions[key][i]];
                if (i != [conditions[key] count]-1){
                    [tmpString appendString:@"."];
                }
            }
            [completeUrl appendString:[NSString stringWithFormat:@"%@=%@&",key,tmpString]];
        }else{
            [completeUrl appendString:[NSString stringWithFormat:@"%@=%@&",key,conditions[key]]];
        }
    }
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/html",@"application/json",nil];
    
    [manager GET:completeUrl parameters:nil progress:nil success:^(NSURLSessionTask *task, id responseObject) {
        NSLog(@"Rooms are %@", responseObject);
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
    
    [manager invalidateSessionCancelingTasks:NO];
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

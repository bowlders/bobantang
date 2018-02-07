//
//  BBTCurrentUser.m
//  BoBanTang
//
//  Created by Caesar on 16/2/4.
//  Copyright © 2016年 100steps. All rights reserved.
//

#import "BBTUser.h"
#import <AFNetworking.h>

@implementation BBTUser

- (instancetype)initWithDictionary:(NSDictionary *)dictionary
{
    self.ID = (NSNumber *)dictionary[@"id"];
    self.account = (NSString *)dictionary[@"account"];
    self.nick = (NSString *)dictionary[@"nick"];
    self.name = (NSString *)dictionary[@"name"];
    self.sex = (NSNumber *)dictionary[@"sex"];
    self.grade = (NSString *)dictionary[@"grade"];
    self.college = (NSString *)dictionary[@"college"];
    self.phone = (NSString *)dictionary[@"phone"];
    self.qq = (NSString *)dictionary[@"qq"];
    self.password = (NSString *)dictionary[@"password"];
    self.dormitory = (NSString *)dictionary[@"dormitory"];
    self.avatar = dictionary[@"avatar"];
    return self;
}

@end

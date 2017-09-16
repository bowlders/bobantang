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
    self.ID = (NSInteger)dictionary[@"ID"];
    self.account = (NSString *)dictionary[@"account"];
    self.userName = (NSString *)dictionary[@"userName"];
    self.sex = (NSInteger)dictionary[@"sex"];
    self.college = (NSString *)dictionary[@"college"];
    self.className = (NSString *)dictionary[@"className"];
    self.password = (NSString *)dictionary[@"password"];
    self.userLogo = (NSString *)dictionary[@"userLogo"];
    self.nickName = (NSString *)dictionary[@"nickName"];
    self.qq = (NSString *)dictionary[@"qq"];
    self.phone = (NSString *)dictionary[@"phone"];
    self.grade = (NSString *)dictionary[@"grade"];
    
    return self;
}

@end

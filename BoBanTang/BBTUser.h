//
//  BBTCurrentUser.h
//  BoBanTang
//
//  Created by Caesar on 16/2/4.
//  Copyright © 2016年 100steps. All rights reserved.
//

#import <JSONModel/JSONModel.h>

@interface BBTUser : JSONModel

//In version 3.0, userName and password are from 教务系统, sex, institution, className and nickName can temporarily be ignored.
@property (strong, nonatomic)NSNumber * ID;
@property (copy, nonatomic) NSString  * account;
@property (copy, nonatomic) NSString  * password;
@property (copy, nonatomic) NSString  * nick;
@property (copy, nonatomic) NSString  * name;
@property (strong, nonatomic)NSNumber * sex;
@property (copy, nonatomic) NSString  * grade;
@property (copy, nonatomic) NSString  * college;
@property (copy, nonatomic) NSString  * phone;
@property (copy, nonatomic) NSString  * dormitory;
@property (copy, nonatomic) NSString  * qq;
@property (copy, nonatomic) NSString  * avatar;


- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

@end

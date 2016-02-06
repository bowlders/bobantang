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
@property (assign, nonatomic) NSInteger  ID;
@property (assign, nonatomic) NSString * account;
@property (strong, nonatomic) NSString * userName;
@property (assign, nonatomic) NSInteger  sex;
@property (strong, nonatomic) NSString * institution;
@property (strong, nonatomic) NSString * className;
@property (strong, nonatomic) NSString * password;
@property (strong, nonatomic) NSString * userLogo;
@property (strong, nonatomic) NSString * nickName;

@end

//
//  BBTCurrentUserManager.h
//  BoBanTang
//
//  Created by Caesar on 16/2/5.
//  Copyright © 2016年 100steps. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BBTUser.h"

@interface BBTCurrentUserManager : NSObject

@property (strong, nonatomic) BBTUser  * currentUser;
@property (nonatomic)         BOOL       userIsActive;      //Set to 1 if a user is currently active.

+ (instancetype) sharedCurrentUserManager;
- (void)currentUserAuthentication;                          //Return 1 if succeed.
- (void)fetchCurrentUserData;
- (void)logOut;

//Keychain methods
- (void)saveCurrentUserInfo;
- (NSString *)loadCurrentUserName;
- (NSString *)loadCurrentUserPassWord;
- (void)deleteCurrentUserInfo;

//NickName
- (void)uploadNewNickName:(NSString *)nickName;             //Upload a new nickname, if succeed then change current user's nickname

//Logo
- (void)uploadNewLogoURL:(NSString *)url;                   //Upload a new logo url, if succeed then change current user's logo url

@end

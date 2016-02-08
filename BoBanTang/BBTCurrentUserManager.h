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

typedef void (^voidBlock)(void);

+ (instancetype) sharedCurrentUserManager;
- (void)currentUserAuthentication;                          //Return 1 if succeed.
- (void)fetchCurrentUserData;
- (void)logOut;

@end

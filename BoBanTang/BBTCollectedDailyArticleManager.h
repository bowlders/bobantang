//
//  BBTCollectedDailyArticleManager.h
//  BoBanTang
//
//  Created by Caesar on 16/2/24.
//  Copyright © 2016年 100steps. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BBTCollectedDailyArticleManager : NSObject

@property (strong, nonatomic) NSMutableArray * currentUserCollectedDailyArticleArray;

- (void)currentUserCollectArticleWithArticleID:(int)articleID;
- (void)currentUserCancelCollectArticleWithArticleID:(int)articleID;
- (void)fetchCurrentUserCollectedDailyArticleIntoArray;
- (void)checkIfCurrentUserHasCollectedArticleWithArticleID:(int)articleID;

@end

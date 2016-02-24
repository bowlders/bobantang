//
//  BBTCollectedCampusInfoManager.h
//  BoBanTang
//
//  Created by Caesar on 16/2/23.
//  Copyright © 2016年 100steps. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BBTCollectedCampusInfoManager : NSObject

@property (strong, nonatomic) NSMutableArray * currentUserCollectedCampusInfoArray;

- (void)currentUserCollectInfoWithArticleID:(int)articleID;     //Current user collect info with a given article ID(notice it's not ID).
- (void)currentUserCancelCollectInfoWithArticleID:(int)articleID;
- (void)fetchCurrentUserCollectedCampusInfoIntoArray;
- (void)checkIfCurrentUserHasCollectedArticleWithArticleID:(int)articleID;

@end

//
//  BBTScoresManager.h
//  BoBanTang
//
//  Created by Hsu Tung Hui on 16/2/16.
//  Copyright © 2016年 100steps. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BBTScoresManager : NSObject

+ (instancetype)sharedScoresManager;
- (void)retriveScores:(NSMutableDictionary *)userInfo WithConditions:(NSDictionary *)conditons;

@property (strong, nonatomic) NSNumber *errorType;
@property NSMutableArray *scoresArray;



@end

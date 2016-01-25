//
//  BBTDailyArticleManager.h
//  BoBanTang
//
//  Created by Caesar on 16/1/25.
//  Copyright © 2016年 100steps. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BBTDailyArticleManager : NSObject

//Singleton Article Manager
@property NSMutableArray * articleArray;                    //Stores a list of infos

+ (instancetype)sharedArticleManager;                       //Singleton method
- (void)retriveData:(NSString *)appendingUrl;
- (void)addReadNumber:(NSUInteger)infoIndex;                //Add an article's read number by 1
- (void)addCollectionNumber:(NSUInteger)infoIndex;          //Add an article's collection number by 1

@end

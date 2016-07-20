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
@property (strong, nonatomic) NSMutableArray * articleArray;                    //Stores a list of infos
@property (strong, nonatomic) NSMutableArray * collectedArticleArray;           //This array stores article with all properties
@property (assign, nonatomic) int articleCount;

+ (instancetype)sharedArticleManager;                       //Singleton method
- (void)loadMoreData;
- (void)addReadNumber:(NSUInteger)infoIndex;                //Add an article's read number by 1
- (void)addCollectionNumber:(NSUInteger)infoIndex;          //Add an article's collection number by 1
- (void)fetchCollectedArticleArrayWithGivenSimplifiedArray:(NSArray *)simplifiedArticleArray;

@end

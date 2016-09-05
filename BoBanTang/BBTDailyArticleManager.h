//
//  BBTDailyArticleManager.h
//  BoBanTang
//
//  Created by Caesar on 16/1/25.
//  Copyright © 2016年 100steps. All rights reserved.
//

@class BBTDailyArticle;

#import <Foundation/Foundation.h>

@interface BBTDailyArticleManager : NSObject

//Singleton Article Manager
@property (strong, nonatomic) NSMutableArray  * articleArray;                    //Stores a list of infos
@property (strong, nonatomic) NSMutableArray  * collectedArticleArray;           //This array stores article with all properties
@property (assign, nonatomic) int articleCount;
@property (strong, nonatomic) BBTDailyArticle * articleToday;                    //The latest article.

+ (instancetype)sharedArticleManager;                                            //Singleton method
- (void)loadMoreData;
- (void)getArticleToday;                                                         //Return today's(the latest) article

@end

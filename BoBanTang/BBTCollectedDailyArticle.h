//
//  BBTCollectedDailyArticle.h
//  BoBanTang
//
//  Created by Caesar on 16/2/24.
//  Copyright © 2016年 100steps. All rights reserved.
//

#import <JSONModel/JSONModel.h>

@interface BBTCollectedDailyArticle : JSONModel

@property (assign, nonatomic) int        ID;
@property (strong, nonatomic) NSString * account;
@property (assign, nonatomic) int        articleID;        
@property (strong, nonatomic) NSDate   * date;

@end

//
//  BBTDailyArticle.h
//  BoBanTang
//
//  Created by Caesar on 16/1/25.
//  Copyright © 2016年 100steps. All rights reserved.
//

#import <JSONModel/JSONModel.h>

@interface BBTDailyArticle : JSONModel

@property (assign, nonatomic) NSUInteger ID;
@property (strong, nonatomic) NSString * date;
@property (strong, nonatomic) NSString * title;
@property (strong, nonatomic) NSString * author;
@property (strong, nonatomic) NSString * article;
@property (strong, nonatomic) NSString * authorIntroduce;
@property (assign, nonatomic) NSUInteger readNum;
@property (assign, nonatomic) NSUInteger collectionNum;

@end

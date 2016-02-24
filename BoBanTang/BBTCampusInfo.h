//
//  BBTCampusInfo.h
//  BoBanTang
//
//  Created by Caesar on 15/11/29.
//  Copyright © 2015年 100steps. All rights reserved.
//

#import <JSONModel/JSONModel.h>

@interface BBTCampusInfo : JSONModel

@property (assign, nonatomic) int        ID;                                //Info ID
@property (strong, nonatomic) NSString * date;                              //Info date
@property (strong, nonatomic) NSString * title;                             //Info title
@property (strong, nonatomic) NSString * author;                            //Info author
@property (strong, nonatomic) NSString * article;                           //Info content
@property (strong, nonatomic) NSString * summary;                           //Info abstract
@property (strong, nonatomic) NSString * picture;                           //Image url
@property (assign, nonatomic) int        readNum;                           //Read Number
@property (assign, nonatomic) int        collectionNum;                     //Collection Number

@end

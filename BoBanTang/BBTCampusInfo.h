//
//  BBTCampusInfo.h
//  BoBanTang
//
//  Created by Caesar on 15/11/29.
//  Copyright © 2015年 100steps. All rights reserved.
//

#import <JSONModel/JSONModel.h>

@interface BBTCampusInfo : JSONModel

@property (strong, nonatomic) NSString * title;                             //Info title
@property (strong, nonatomic) NSString * article;                           //Info content
@property (strong, nonatomic) NSString * abstract;                          //Info abstract
@property (strong, nonatomic) NSString * author;                            //Info author
@property (strong, nonatomic) NSString * date;                              //Info date
@property (strong, nonatomic) NSString * picture;                           //Picture url
@property (readwrite, nonatomic) NSUInteger readNum;                        //Read number
@property (readwrite, nonatomic) NSUInteger collectionNum;                  //Collection number

@end

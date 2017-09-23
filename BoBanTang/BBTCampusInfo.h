//
//  BBTCampusInfo.h
//  BoBanTang
//
//  Created by Caesar on 15/11/29.
//  Copyright © 2015年 100steps. All rights reserved.
//

#import <JSONModel/JSONModel.h>

@interface BBTCampusInfo : JSONModel

@property (strong, nonatomic) NSArray  * content;                               //Info content
@property (strong, nonatomic) NSString * date;                                  //Info date
@property (assign, nonatomic) int        ID;                                           //Info ID
@property (assign, nonatomic) int        publishNum;                                   //Info publish
@property (strong, nonatomic) NSString * title;                                 //Info title
@property (assign, nonatomic) int        type;                                         //Info type
@property (strong, nonatomic) NSString * upDate;                                //Image url

@end

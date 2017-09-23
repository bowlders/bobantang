//
//  BBTCampusInfo.h
//  BoBanTang
//
//  Created by Caesar on 15/11/29.
//  Copyright © 2015年 100steps. All rights reserved.
//

#import <JSONModel/JSONModel.h>

@interface BBTCampusInfo : JSONModel

@property (strong, nonatomic) NSDictionary  * content;                               //Info content
@property (strong, nonatomic) NSString * created_at;                                  //Info date
@property (assign, nonatomic) int        id;                                           //Info ID
@property (assign, nonatomic) int        published_by;                                   //Info publish
@property (strong, nonatomic) NSString * title;                                 //Info title
@property (assign, nonatomic) int        type;                                         //Info type
@property (strong, nonatomic) NSString * updated_at;                                //Image url

@end

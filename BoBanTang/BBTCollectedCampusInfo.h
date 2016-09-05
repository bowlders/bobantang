//
//  BBTCollectedCampusInfo.h
//  BoBanTang
//
//  Created by Caesar on 16/2/23.
//  Copyright © 2016年 100steps. All rights reserved.
//

#import <JSONModel/JSONModel.h>

@interface BBTCollectedCampusInfo : JSONModel

@property (assign, nonatomic) int        ID;               //Automatically incremented ID in collected campus info data table
@property (strong, nonatomic) NSString * account;
@property (assign, nonatomic) int        articleID;        //The ID hooked with ID in campus info data table
@property (strong, nonatomic) NSDate   * date;

@end

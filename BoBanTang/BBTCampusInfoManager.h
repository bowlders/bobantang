//
//  BBTCampusInfoManager.h
//  BoBanTang
//
//  Created by Caesar on 15/11/29.
//  Copyright © 2015年 100steps. All rights reserved.
//

#import <Foundation/Foundation.h>

//Singleton info manager
@interface BBTCampusInfoManager : NSObject

@property (strong, nonatomic) NSMutableArray * infoArray;                   //Stores a list of infos
@property (strong, nonatomic) NSMutableArray * collectedInfoArray;          //This array stores info with all properties
@property (assign, nonatomic) int infoCount;                                //Count the number of infos that have been loaded in total

+ (instancetype)sharedInfoManager;                                          //Singleton method
- (void)retriveData:(NSString *)appendingUrl;
- (void)fetchCollectedInfoArrayWithGivenSimplifiedArray:(NSArray *)simplifiedInfoArray;

@end

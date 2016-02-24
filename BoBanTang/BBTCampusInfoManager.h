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

@property NSMutableArray * infoArray;                       //Stores a list of infos
@property NSMutableArray * collectedInfoArray;              //This array stores info with all properties

+ (instancetype)sharedInfoManager;                          //Singleton method
- (void)retriveData:(NSString *)appendingUrl;
- (void)fetchCollectedInfoArrayWithGivenSimplifiedArray:(NSArray *)simplifiedInfoArray;

@end

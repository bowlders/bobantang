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

+ (instancetype)sharedInfoManager;                          //Singleton method
- (void)retriveData;
- (void)addReadNumber:(NSUInteger)infoIndex;                //Add an info's read number by 1
- (void)addCollectionNumber:(NSUInteger)infoIndex;          //Add an info's collection number by 1

@end

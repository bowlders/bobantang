//
//  BBTLAFManager.h
//  BoBanTang
//
//  Created by Hsu Tung Hui on 16/1/30.
//  Copyright © 2016年 100steps. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BBTLAFManager : NSObject

//Singleton LAF Manager
@property NSArray *itemArray;  //Stores a list of items

+ (instancetype)sharedLAFManager;
 //Singleton method
- (void)retriveItems:(NSUInteger)type WithConditions:(NSDictionary *)conditions;
- (void)postItemDic:(NSDictionary *)itemDic WithType:(NSInteger)type;

@end

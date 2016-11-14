//
//  BBTScores.h
//  BoBanTang
//
//  Created by Hsu Tung Hui on 21/10/15.
//  Copyright © 2015年 BBT. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BBTScores : NSObject

@property (nonatomic, copy) NSString *studentName;
@property (nonatomic, copy) NSString *account;
@property (nonatomic, copy) NSString *password;
@property (nonatomic, copy) NSNumber *year;
@property (nonatomic, copy) NSNumber *semester;

@property (nonatomic, copy) NSString *courseName;
@property (nonatomic, copy) NSString *score;
@property (nonatomic, copy) NSString *gradepoint;
@property (nonatomic, copy) NSString *ranking;

@end

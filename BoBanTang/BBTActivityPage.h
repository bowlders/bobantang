//
//  BBTActivityPage.h
//  波板糖
//
//  Created by Xu Donghui on 31/10/2016.
//  Copyright © 2016 100steps. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface BBTActivityPageToDataTransformer : NSValueTransformer

@end

@interface BBTActivityPage : NSManagedObject

@property (retain, nonatomic) NSString *activityID;
@property (retain, nonatomic) NSString *articleID;
@property (retain, nonatomic) NSString *imageUrl;
@property (retain, nonatomic) NSString *name;
@property (retain, nonatomic) NSDate   *startTime;
@property (retain, nonatomic) NSDate   *endTime;

@end

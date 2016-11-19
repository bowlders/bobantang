//
//  BBTActivityPageManager.h
//  波板糖
//
//  Created by Xu Donghui on 31/10/2016.
//  Copyright © 2016 100steps. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BBTActivityPage.h"

@interface BBTActivityPageManager : NSObject

@property (strong, nonatomic) BBTActivityPage *activity;

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;

+ (instancetype)sharedActivityPageManager;
//Singleton method

- (void)retriveActivityPageInfo;

@end

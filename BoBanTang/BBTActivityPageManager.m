//
//  BBTActivityPageManager.m
//  波板糖
//
//  Created by Xu Donghui on 31/10/2016.
//  Copyright © 2016 100steps. All rights reserved.
//

#import "BBTActivityPageManager.h"
#import <AFNetworking/AFNetworking.h>

static NSString *getActivityPageInfoUrl = @"http://218.192.166.167/api/protype.php?table=activityPage&method=get";

NSString *kActivityPageAvaliable = @"avaliable";
NSString *kActivityPageVoid = @"void";

@implementation BBTActivityPageManager

+ (instancetype)sharedActivityPageManager
{
    static BBTActivityPageManager *_manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _manager = [[BBTActivityPageManager alloc] init];
    });
    return _manager;
}

- (void)retriveActivityPageInfo
{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/html", nil];
    [manager GET:getActivityPageInfoUrl parameters:nil progress:nil
         success:^(NSURLSessionTask * task, id responseObject) {
             
             id delegate = [[UIApplication sharedApplication] delegate];
             self.managedObjectContext = [delegate managedObjectContext];
             [self.managedObjectContext deletedObjects];   //Update activity page information
             
             //Redundant Design: In case of receiving multiple activity pages information
             for (int i = 0; i < ([responseObject count]); i++)
             {
                 NSDictionary *dictionary = responseObject[i];
                 
                 NSEntityDescription *activityEntityDescription = [NSEntityDescription entityForName:@"BBTActivityPage" inManagedObjectContext:self.managedObjectContext];
                 BBTActivityPage *activityPage = (BBTActivityPage *)[[NSManagedObject alloc] initWithEntity:activityEntityDescription insertIntoManagedObjectContext:self.managedObjectContext];
                 
                 activityPage.activityID = dictionary[@"id"];
                 activityPage.articleID = dictionary[@"articleID"];
                 activityPage.imageUrl = dictionary[@"image"];
                 activityPage.name = dictionary[@"name"];
                 
                 NSString *startTimeString = dictionary[@"start_time"];
                 NSString *endTimeString = dictionary[@"end_time"];
                 NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                 dateFormatter.dateFormat = @"yyyy-MM-dd hh:mm:ss";
                 //dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
                 
                 activityPage.startTime = [dateFormatter dateFromString:startTimeString];
                 activityPage.endTime = [dateFormatter dateFromString:endTimeString];
                 
                 NSError *error;
                 if (![self.managedObjectContext save:&error]) {
                     NSLog(@"Error: %@", error);
                 }
                 
            }
             
             [self postActivityPageAvaliable];
             
    } failure:^(NSURLSessionTask * task, NSError * error) {
        [self postActivityPageVoid];
    }];
    
    [manager invalidateSessionCancelingTasks:NO];
}

- (void)postActivityPageAvaliable
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kActivityPageAvaliable object:nil];
}

- (void)postActivityPageVoid
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kActivityPageVoid object:nil];
}

@end

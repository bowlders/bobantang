//
//  BBTLAFManager.m
//  BoBanTang
//
//  Created by Hsu Tung Hui on 16/1/30.
//  Copyright © 2016年 100steps. All rights reserved.
//

#import "BBTLAFManager.h"
#import <AFNetworking/AFNetworking.h>
#import <QiniuSDK.h>
#import "BBTLAF.h"
#import "RSA.h"

static NSString *getLostItemsUrl = @"http://218.192.166.167/api/protype.php?table=lostItems&method=get";
static NSString *getPickItemsUrl = @"http://218.192.166.167/api/protype.php?table=pickItems&method=get";
static NSString *postLostItemUrl = @"http://218.192.166.167/api/protype.php?table=lostItems&method=save&data=";
static NSString *postPickItemUrl = @"http://218.192.166.167/api/protype.php?table=pickItems&method=save&data=";

NSString *lafNotificationName = @"lafNotification";
NSString *kGetFuzzyConditionsItemNotificationName = @"getFuzzyConditionsItemNotificationName";
NSString *kDidPostItemNotificaionName = @"didPostItemNotification";
NSString *kFailPostItemNotificaionName = @"failPostItemNotification";

@implementation BBTLAFManager

+ (instancetype)sharedLAFManager
{
    static BBTLAFManager *_manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _manager = [[BBTLAFManager alloc] init];
    });
    return _manager;
}

- (void)retriveItems:(NSUInteger)type WithConditions:(NSDictionary *)conditions
{
    self.itemArray = [[NSArray alloc] init];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/html", nil];
    NSString *url;
    
    if (!conditions)
    {
        if (type == 1) {
            url = getLostItemsUrl;
        } else if (type == 0) {
            url = getPickItemsUrl;
        }
    }
    else
    {
        NSString *rowUrl;
        if (conditions[@"fuzzy"])
        {
            if (type == 1) {
                rowUrl = [getLostItemsUrl stringByAppendingString:@"&option="];
            } else {
                rowUrl = [getPickItemsUrl stringByAppendingString:@"&option="];
            }
            
        } else {
            if (type == 1) {
                rowUrl = [getLostItemsUrl stringByAppendingString:@"&data="];
            } else {
                rowUrl = [getPickItemsUrl stringByAppendingString:@"&data="];
            }
        }
        
        NSError *error;
        NSData *data = [NSJSONSerialization dataWithJSONObject:conditions options:NSJSONWritingPrettyPrinted error:&error];
        NSString *jsonString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSString *stringCleanPath = [jsonString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
        url = [rowUrl stringByAppendingString:stringCleanPath];
    }
    
    [manager POST:url parameters:nil progress:nil success:^(NSURLSessionTask *task, id responseObject) {
        //NSLog(@"JSON: %@", responseObject);
        if (responseObject)
        {
            NSMutableArray *origArr = [[NSMutableArray alloc] init];
            for (BBTLAF* itemsInfo in responseObject)
            {
                [origArr addObject:itemsInfo];
            }
            if (conditions[@"fuzzy"]) {
                [self getFuzzyConditionsItemNotification];
            } else {
                self.itemArray = [[origArr reverseObjectEnumerator] allObjects];
                [self pushLafNotification];
            }
        }
    } failure:^(NSURLSessionTask *task, NSError *error) {
        NSLog(@"Error: %@", error);
    }];

}

- (void)postItemDic:(NSDictionary *)itemDic WithType:(NSInteger)type
{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    NSString *url;
    if (type == 1) {
        url = postLostItemUrl;
    } else if (type == 0) {
        url = postPickItemUrl;
    }
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/html", nil];
   
    NSError *error;
    NSData *data = [NSJSONSerialization dataWithJSONObject:itemDic options:NSJSONWritingPrettyPrinted error:&error];
    NSString *jsonString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSString *stringCleanPath = [jsonString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    NSString *completeUrl = [url stringByAppendingString:stringCleanPath];
    
    [manager POST:completeUrl parameters:nil progress:nil success:^(NSURLSessionTask *task, id responseObject) {
        if (responseObject) {
            NSLog(@"Succeed: %@", responseObject);
            [self postDidPostItemNotificaion];
        }
    } failure:^(NSURLSessionTask *task, NSError *error) {
        NSLog(@"Error: %@",error);
        [self postDidPostItemNotificaion];
    }];
}

- (void)pushLafNotification
{
    [[NSNotificationCenter defaultCenter] postNotificationName:lafNotificationName object:nil];
}

- (void)getFuzzyConditionsItemNotification
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kGetFuzzyConditionsItemNotificationName object:nil];
}

- (void)postDidPostItemNotificaion
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kDidPostItemNotificaionName object:nil];
}

- (void)postFailPostItemNotification
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kFailPostItemNotificaionName object:nil];
}

@end

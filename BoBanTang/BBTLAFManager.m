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

static NSString *getLostItemsUrl = @"http://218.192.166.167/api/protype.php?table=lostItems&method=get&option=";
static NSString *getPickItemsUrl = @"http://218.192.166.167/api/protype.php?table=pickItems&method=get&option=";
static NSString *getMyLostUrl = @"http://218.192.166.167/api/protype.php?table=lostItems&method=get&data=";
static NSString *getMyPickUrl = @"http://218.192.166.167/api/protype.php?table=pickItems&method=get&data=";
static NSString *postLostItemUrl = @"http://218.192.166.167/api/protype.php?table=lostItems&method=save&data=";
static NSString *postPickItemUrl = @"http://218.192.166.167/api/protype.php?table=pickItems&method=save&data=";
static NSString *deleteLostItemUrl = @"http://218.192.166.167/api/protype.php?table=lostItems&method=delete&data=";
static NSString *deletePickItemUrl = @"http://218.192.166.167/api/protype.php?table=pickItems&method=delete&data=";

NSString *lafNotificationName = @"lafNotification";
NSString *failNotificationName = @"failNoticifation";
NSString *kNoMoreItemsNotificationName = @"noMoreItems";
NSString *kGetFuzzyConditionsItemNotificationName = @"getFuzzyConditionsItemNotificationName";
NSString *kDidPostItemNotificaionName = @"didPostItemNotification";
NSString *kFailPostItemNotificaionName = @"failPostItemNotification";
NSString *kDidDeleteItemNotificationName = @"didDeleteItmeNotifiation";
NSString *kFailDeleteItemNotificaionName = @"FailDeleteItemNotification";
NSString *kDidGetPickedItemsNotificationName = @"getPickedNotification";
NSString *kDidGetLostItemsNotificationName = @"getLostNotification";

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
    if ((!_itemsCount) || (!_itemArray))
    {
        self.reservedArray = [NSMutableArray array];
    }
    
    self.itemArray = [NSArray array];
    
    int __block noMoreItemsCount = 0;
    int beginningItem = self.itemsCount;
    
    NSString *appendingString = [NSString stringWithFormat:@"{\"limit\":[%d,5]}", beginningItem];
    
    NSString *url;
    
    if (!conditions)
    {
        if (type == 1) {
            url = [[getLostItemsUrl stringByAppendingString:appendingString] stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
        } else if (type == 0) {
            url = [[getPickItemsUrl stringByAppendingString:appendingString] stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
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
                rowUrl = [[getLostItemsUrl stringByAppendingString:appendingString] stringByAppendingString:@"&data="];
            } else {
                rowUrl = [[getPickItemsUrl stringByAppendingString:appendingString] stringByAppendingString:@"&data="];
            }
        }
        
        NSError *error;
        NSData *data = [NSJSONSerialization dataWithJSONObject:conditions options:NSJSONWritingPrettyPrinted error:&error];
        NSString *jsonString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSString *stringCleanPath = [jsonString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
        url = [rowUrl stringByAppendingString:stringCleanPath];
    }
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/html", nil];
    [manager POST:url parameters:nil progress:nil success:^(NSURLSessionTask *task, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
        if (responseObject)
        {
            NSMutableArray *origArr = [[NSMutableArray alloc] init];
            for (NSDictionary *itemsInfo in responseObject)
            {
                BBTLAF *item = [[BBTLAF alloc] initWithResponesObject:itemsInfo];
                [origArr addObject:item];
                noMoreItemsCount++;
            }
            if (conditions[@"fuzzy"]) {
                [self getFuzzyConditionsItemNotification];
            } else {
                
                self.itemsCount += [(NSArray *)responseObject count];
                
                [self.reservedArray addObjectsFromArray:origArr];
                self.itemArray = self.reservedArray;
                [[self.itemArray reverseObjectEnumerator] allObjects];
                
                [self pushLafNotification];
                
                if (!noMoreItemsCount) [self pushNoMoreItemsNotification];
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
        [self postFailPostItemNotification];
    }];
}

- (void)loadMyPickedItemsWithAccount:(NSString *)account
{
    if (!self.myPicked) {
        self.myPicked = [[NSMutableArray alloc] init];
    } else {
        [self.myPicked removeAllObjects];
    }
    
    NSDictionary *condition = @{@"account":account};
    
    NSError *error;
    NSData *data = [NSJSONSerialization dataWithJSONObject:condition options:NSJSONWritingPrettyPrinted error:&error];
    NSString *jsonString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSString *stringCleanPath = [jsonString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    
    NSString *url = [getMyPickUrl stringByAppendingString:stringCleanPath];
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/html", nil];    
    
    [manager POST:url parameters:nil progress:nil success:^(NSURLSessionTask *task, id responseObject) {
        if (responseObject)
        {
            for (NSDictionary *itemsInfo in responseObject)
            {
                BBTLAF *item = [[BBTLAF alloc] initWithResponesObject:itemsInfo];
                
                [self.myPicked addObject:item];
            }
            
            [self postDidGetPickedItemsNotification];
        }
    } failure:^(NSURLSessionTask *task, NSError *error) {
        NSLog(@"Error: %@", error);
        [self postFailLafNotification];
    }];
}

- (void)loadMyLostItemsWithAccount:(NSString *)account
{
    if (!self.myLost) {
        self.myLost = [[NSMutableArray alloc] init];
    } else {
        [self.myLost removeAllObjects];
    }
    
    NSDictionary *condition = @{@"account":account};
    
    NSError *error;
    NSData *data = [NSJSONSerialization dataWithJSONObject:condition options:NSJSONWritingPrettyPrinted error:&error];
    NSString *jsonString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSString *stringCleanPath = [jsonString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    
    NSString *url = [getMyLostUrl stringByAppendingString:stringCleanPath];
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/html", nil];
    
    [manager POST:url parameters:nil progress:nil success:^(NSURLSessionTask *task, id responseObject) {
        if (responseObject)
        {
            for (NSDictionary *itemsInfo in responseObject)
            {
                BBTLAF *item = [[BBTLAF alloc] initWithResponesObject:itemsInfo];
                
                [self.myLost addObject:item];
            }
            
            [self postDidGetLostItemsNotification];
        }
    } failure:^(NSURLSessionTask *task, NSError *error) {
        NSLog(@"Error: %@", error);
        [self postFailLafNotification];
    }];

}

- (void)deletePostedItemsWithId:(NSString *)itemID inTable:(NSUInteger)lostOrFound
{
    NSString *url;
    switch (lostOrFound) {
        case 1:
            url = deleteLostItemUrl;
            break;
            
        case 0:
            url = deletePickItemUrl;
            break;
            
        default: break;
    }
    
    NSDictionary *itemMark = @{@"ID":itemID};
    
    NSError *error;
    NSData *data = [NSJSONSerialization dataWithJSONObject:itemMark options:NSJSONWritingPrettyPrinted error:&error];
    NSString *jsonString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSString *stringCleanPath = [jsonString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    NSString *completeUrl = [url stringByAppendingString:stringCleanPath];
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/html", nil];
    
    [manager POST:completeUrl parameters:nil progress:nil success:^(NSURLSessionTask *task, id responseObject) {
        if (responseObject) {
            NSLog(@"Succeed: %@", responseObject);
            if (responseObject[@"column"]) {
                [self postDidDeleteItemNotification];
            } else {
                [self postFailDeleteItemNotification];
            }
        }
    } failure:^(NSURLSessionTask *task, NSError *error) {
        NSLog(@"Error: %@",error);
        [self postFailDeleteItemNotification];
    }];
}

- (void)pushLafNotification
{
    [[NSNotificationCenter defaultCenter] postNotificationName:lafNotificationName object:nil];
}

- (void)postFailLafNotification
{
    [[NSNotificationCenter defaultCenter] postNotificationName:failNotificationName object:nil];
}

- (void)pushNoMoreItemsNotification
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kNoMoreItemsNotificationName object:nil];
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

- (void)postDidDeleteItemNotification
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kDidDeleteItemNotificationName object:nil];
}

- (void)postFailDeleteItemNotification
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kFailDeleteItemNotificaionName object:nil];
}

- (void)postDidGetPickedItemsNotification
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kDidGetPickedItemsNotificationName object:nil];
}

- (void)postDidGetLostItemsNotification
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kDidGetLostItemsNotificationName object:nil];
}

@end

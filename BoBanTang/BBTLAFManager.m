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

static const NSString *getLostAndFoundItemsUrl = @"http://apiv2.100steps.net/lostitems?";

//目前似乎是失物和寻物都在一个数据库......
static NSString *getLostItemsUrl = @"http://apiv2.100steps.net/lostitems?";
static NSString *getPickItemsUrl = @"http://apiv2.100steps.net/lostitems?";
static NSString *postLostItemUrl = @"http://apiv2.100steps.net/lostitems";
static NSString *postPickItemUrl = @"http://apiv2.100steps.net/lostitems";
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

#pragma mark 标记，日后再来修改代码
- (void)retriveItems:(NSUInteger)type WithConditions:(NSDictionary *)conditions
{
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/html",@"application/json", nil];
    
    NSString *newURL = [self appendSearchConditionWithRawUrl:getLostAndFoundItemsUrl andConditon:conditions];
    [manager GET:newURL parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSMutableArray *origArr = [[NSMutableArray alloc] init];
        for (NSDictionary *itemsInfo in responseObject)
        {
            BBTLAF *item = [[BBTLAF alloc] initWithResponesObject:itemsInfo];
            [origArr addObject:item];
            
            //[origArr addObject:item];
            //noMoreItemsCount++;
        }
        self.itemArray = origArr.copy;
        [self pushLafNotification];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
    }];
    /*
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
                self.itemArray = origArr;
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
    
    [manager invalidateSessionCancelingTasks:NO];
     */
}
- (NSString *)appendSearchConditionWithRawUrl:(const NSString *)url andConditon:(NSDictionary *)conditions{
    NSString *newURL = url.copy;
    for (NSString *name in [conditions allKeys]) {
        if (conditions[name]){
            newURL = [newURL stringByAppendingString:[NSString stringWithFormat:@"%@=%@",name,conditions[name]]];
        }else{
            
        }
    }
    return newURL;
}

- (NSString *)getJSONStringForObject:(id)object
{
    NSError *error;
    
    NSData *data = [NSJSONSerialization dataWithJSONObject:object options:NSJSONWritingPrettyPrinted error:&error];
    NSString *jsonString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSString *stringCleanPath = [jsonString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    return stringCleanPath;
}

- (void)postItemDic:(NSDictionary *)itemDic WithType:(NSInteger)type
{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/html",@"application/json",nil];
    NSString *url;
    if (type == 1) {
        url = postLostItemUrl;
    } else if (type == 0) {
        url = postPickItemUrl;
    }
    [manager POST:url parameters:itemDic progress:nil success:^(NSURLSessionTask *task, id responseObject) {
        if (responseObject) {
            [self postDidPostItemNotificaion];
        }
    } failure:^(NSURLSessionTask *task, NSError *error) {
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
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/html",@"application/json",nil];
    
    NSString *newURL = [getLostAndFoundItemsUrl stringByAppendingString:[NSString stringWithFormat:@"account=%@",account]];
    
    [manager GET:newURL parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        for (NSDictionary *itemsInfo in responseObject)
        {
            BBTLAF *item = [[BBTLAF alloc] initWithResponesObject:itemsInfo];
            if ([item.account isEqual:account]){
                [self.myPicked addObject:item];
            }
        }
        [self postDidGetPickedItemsNotification];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
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
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/html",@"application/json",nil];
    NSString *newURL = [getLostAndFoundItemsUrl stringByAppendingString:[NSString stringWithFormat:@"account=%@",account]];
    [manager GET:newURL parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        for (NSDictionary *itemsInfo in responseObject)
        {
            BBTLAF *item = [[BBTLAF alloc] initWithResponesObject:itemsInfo];
            if ([item.account isEqual:account]){
                [self.myLost addObject:item];
            }
        }
        [self postDidGetLostItemsNotification];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [self postFailLafNotification];
    }];
   
}

- (void)deletePostedItemsWithId:(NSNumber *)itemID inTable:(NSUInteger)lostOrFound
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
    
    //NSDictionary *itemMark = @{@"ID":itemID};
    NSString *newURL = [postLostItemUrl stringByAppendingString:[NSString stringWithFormat:@"/%@",itemID]];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/html",@"application/json",nil];
    
    [manager DELETE:newURL parameters:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if ([responseObject[@"message"] isEqual:@"OK"]){
            [self postDidDeleteItemNotification];
        }else{
            [self postFailDeleteItemNotification];
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
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

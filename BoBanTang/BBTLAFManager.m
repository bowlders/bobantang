//
//  BBTLAFManager.m
//  BoBanTang
//
//  Created by Hsu Tung Hui on 16/1/30.
//  Copyright © 2016年 100steps. All rights reserved.
//

#import "BBTLAFManager.h"
#import <AFNetworking/AFNetworking.h>
#import "BBTLAF.h"

static NSString *getLostItemsUrl = @"http://218.192.166.167/api/protype.php?table=lostItems&method=get";
static NSString *getPickItemsUrl = @"http://218.192.166.167/api/protype.php?table=pickItems&method=get";
NSString *lafNotificationName = @"lafNotification";

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

- (void)retriveItemsWithType:(NSUInteger)type
{
    NSDictionary *testDictionary = @{@"itemID":@"一颗赛艇",
                                     @"details":@"我是身经百战了！西方哪一个国家我没有去过？美国的华莱士，比你不知道高到哪里去，我和他谈笑风生。你们毕竟还是too young，sometimes naive! 明白我的意思没有？",
                                     @"campus":@"0",
                                     @"date":@"1989-6-4",
                                     @"location":@"东湖",
                                     @"phone":@"110",
                                     @"publisher":@"蛤蛤"};
    
    self.itemArray = [NSMutableArray array];
    [self.itemArray insertObject:testDictionary atIndex:0];
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    NSString *url;
    if (type == 1) {
        url = getLostItemsUrl;
    } else if (type == 0) {
        url = getPickItemsUrl;
    }
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/html", nil];
    [manager GET:url parameters:nil progress:nil success:^(NSURLSessionTask *task, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
        if (responseObject)
        {
            for (BBTLAF* itemsInfo in responseObject)
            {
                [self.itemArray addObject:itemsInfo];
            }
            [self pushLafNotification];
        }
    } failure:^(NSURLSessionTask *task, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}

- (void)pushLafNotification
{
    [[NSNotificationCenter defaultCenter] postNotificationName:lafNotificationName object:nil];
}

@end

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
static NSString *getTokenUrl = @"http://api.100steps.net/qiniu/index.php";
static NSString *domain = @"http://o6haukahg.bkt.clouddn.com/";
static NSString *thumbUrlSuffix = @"?imageView2/1/w/200/h/200";

static NSString *publicKey = @"-----BEGIN PUBLIC KEY-----\nMIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQC7toPDdZWWN2Mz+8S6Y+lWxXSdURd1sC785PUj/7nx0olGdawUK6wyDmv0oXmNyqaVvMTjpRL4Q0cnKRKeCFAh3tqF/IOhyNEzfd56k6g1lx4OB5jKItbov3ZJFjKuJCFLyvSc+R+bUFW1DBFPJ5bN+TT1sixlJogOHd42z6HGdQIDAQAB\n-----END PUBLIC KEY-----";
static NSString *jsonString = @"api|qiniu|";

NSString *lafNotificationName = @"lafNotification";
NSString *kGetFuzzyConditionsItemNotificationName = @"getFuzzyConditionsItemNotificationName";
NSString *kDidGetTokenNotificationName = @"didGetTokenNotification";
NSString *kFailGetTokenNotificationName = @"failGetNotification";
NSString *kDidUploadImageNotificationName = @"didUploadImageNotification";
NSString *kFailUploadImageNotificationName = @"failUploadImageNotification";
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
    self.itemArray = [NSMutableArray array];
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
        NSLog(@"JSON: %@", responseObject);
        if (responseObject)
        {
            for (BBTLAF* itemsInfo in responseObject)
            {
                [self.itemArray addObject:itemsInfo];
            }
            if (conditions[@"fuzzy"]) {
                [self getFuzzyConditionsItemNotification];
            } else {
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

- (void)getUploadToken
{
    NSString *timestamp = [NSString stringWithFormat:@"%d",((int)[[NSDate date] timeIntervalSince1970]) + 10];
    NSString *parameterString = [jsonString stringByAppendingString:timestamp];
    NSDictionary *parameter = @{@"data":[RSA encryptString:parameterString publicKey:publicKey]};
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/html", nil];
    [manager POST:getTokenUrl parameters:parameter progress:nil success:^(NSURLSessionTask *task, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
        if (responseObject) {
            if (responseObject[@"token"]) {
                self.token = [NSString stringWithString:responseObject[@"token"]];
                NSLog(@"Token is: %@",self.token);
                [self postDidGetTokenNotification];
            } else if (responseObject[@"msg"]) {
                NSLog(@"ERROR: %@", responseObject[@"msg"]);
                [self postFailGetTokenNotification];
            }
        }
    } failure:^(NSURLSessionTask *task, NSError *error) {
        NSLog(@"ERROR: %@", error);
        [self postFailGetTokenNotification];
    }];

}

- (void)uploadImageToQiniu:(UIImage *)image
{
    NSString *filePath = [self getImagePath:image];
    
    if (self.token)
    {
        QNUploadManager *upManager = [[QNUploadManager alloc] init];
        QNUploadOption *uploadOption = [[QNUploadOption alloc] initWithMime:nil
                                                            progressHandler:nil
                                                                     params:nil
                                                                   checkCrc:NO
                                                         cancellationSignal:nil];
        [
         upManager putFile:filePath key:nil token:self.token complete:^(QNResponseInfo *info, NSString *key, NSDictionary *resp) {
            NSLog(@"info ===== %@", info);
            NSLog(@"resp ===== %@", resp);
             if (resp[@"key"]) {
                 self.OrgPicUrl = [domain stringByAppendingString:resp[@"key"]];
                 self.thumbUrl = [self.OrgPicUrl stringByAppendingString:thumbUrlSuffix];
                 [self postDidUploadImageNotification];
             } else {
                 [self postFailUploadImageNotification];
             }
        }
                    option:uploadOption];
        }

}

//Get and convert loacl image path
- (NSString *)getImagePath:(UIImage *)Image
{
    //Code from QiniuDemo
    //DO NOT EDIT OR REMOVE!!!
    
    NSString *filePath = nil;
    NSData *data = nil;
    if (UIImagePNGRepresentation(Image) == nil) {
        data = UIImageJPEGRepresentation(Image, 1.0);
    } else {
        data = UIImagePNGRepresentation(Image);
    }
    
    NSString *DocumentsPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    [fileManager createDirectoryAtPath:DocumentsPath withIntermediateDirectories:YES attributes:nil error:nil];
    NSString *ImagePath = [[NSString alloc] initWithFormat:@"/theFirstImage.png"];
    [fileManager createFileAtPath:[DocumentsPath stringByAppendingString:ImagePath] contents:data attributes:nil];
    
    filePath = [[NSString alloc] initWithFormat:@"%@%@", DocumentsPath, ImagePath];
    return filePath;
}

- (void)pushLafNotification
{
    [[NSNotificationCenter defaultCenter] postNotificationName:lafNotificationName object:nil];
}

- (void)getFuzzyConditionsItemNotification
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kGetFuzzyConditionsItemNotificationName object:nil];
}

- (void)postDidGetTokenNotification
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kDidGetTokenNotificationName object:nil];
}

- (void)postFailGetTokenNotification
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kFailGetTokenNotificationName object:nil];
}

- (void)postDidUploadImageNotification
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kDidUploadImageNotificationName object:nil];
}

- (void)postFailUploadImageNotification
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kFailUploadImageNotificationName object:nil];
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

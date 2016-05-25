//
//  BBTImageUploadManager.m
//  BoBanTang
//
//  Created by Xu Donghui on 26/05/2016.
//  Copyright © 2016 100steps. All rights reserved.
//

#import "BBTImageUploadManager.h"
#import <AFNetworking/AFNetworking.h>
#import <QiniuSDK.h>
#import "RSA.h"

static NSString *getTokenUrl = @"http://api.100steps.net/qiniu/index.php";
static NSString *domain = @"http://o6haukahg.bkt.clouddn.com/";
static NSString *thumbUrlSuffix = @"?imageView2/1/w/200/h/200";

static NSString *publicKey = @"-----BEGIN PUBLIC KEY-----\nMIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQC7toPDdZWWN2Mz+8S6Y+lWxXSdURd1sC785PUj/7nx0olGdawUK6wyDmv0oXmNyqaVvMTjpRL4Q0cnKRKeCFAh3tqF/IOhyNEzfd56k6g1lx4OB5jKItbov3ZJFjKuJCFLyvSc+R+bUFW1DBFPJ5bN+TT1sixlJogOHd42z6HGdQIDAQAB\n-----END PUBLIC KEY-----";
static NSString *jsonString = @"api|qiniu|";

NSString *kDidUploadImageNotificationName = @"didUploadImageNotification";
NSString *kFailUploadImageNotificationName = @"failUploadImageNotification";

@implementation BBTImageUploadManager

extern NSString *test;

+ (instancetype)sharedUploadManager
{
    static BBTImageUploadManager *_manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _manager = [[BBTImageUploadManager alloc] init];
    });
    return _manager;
}

- (void)uploadImageToQiniu:(UIImage *)image
{
    NSString *timestamp = [NSString stringWithFormat:@"%d",((int)[[NSDate date] timeIntervalSince1970]) + 10];
    NSString *parameterString = [jsonString stringByAppendingString:timestamp];
    NSDictionary *parameter = @{@"data":[RSA encryptString:parameterString publicKey:publicKey]};
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/html", nil];
    [manager POST:getTokenUrl parameters:parameter progress:nil success:^(NSURLSessionTask *task, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
        if (responseObject) {
            if (responseObject[@"token"])
            {
                NSString *token;
                token = [NSString stringWithString:responseObject[@"token"]];
                NSLog(@"Token is: %@",token);
                
                [self upload:image withToken:token];
                
            } else if (responseObject[@"msg"]) {
                NSLog(@"ERROR: %@", responseObject[@"msg"]);
                [self postFailUploadImageNotification];
            }
        }
    } failure:^(NSURLSessionTask *task, NSError *error) {
        NSLog(@"ERROR: %@", error);
        [self postFailUploadImageNotification];
    }];

}

- (void)upload:(UIImage *)image withToken:(NSString *)token
{
    NSString *filePath = [self getImagePath:image];
    
    QNUploadManager *upManager = [[QNUploadManager alloc] init];
    QNUploadOption *uploadOption = [[QNUploadOption alloc] initWithMime:nil
                                                        progressHandler:nil
                                                                 params:nil
                                                               checkCrc:NO
                                                     cancellationSignal:nil];

    [upManager putFile:filePath key:nil token:token complete:^(QNResponseInfo *info, NSString *key, NSDictionary *resp) {
         NSLog(@"info ===== %@", info);
         NSLog(@"resp ===== %@", resp);
         if (resp[@"key"]) {
             self.OrgPicUrl = [domain stringByAppendingString:resp[@"key"]];
             self.thumbnailUrl = [self.OrgPicUrl stringByAppendingString:thumbUrlSuffix];
             [self postDidUploadImageNotification];
         } else {
             [self postFailUploadImageNotification];
         }
     }
     option:uploadOption];
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

- (void)postDidUploadImageNotification
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kDidUploadImageNotificationName object:nil];
}

- (void)postFailUploadImageNotification
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kFailUploadImageNotificationName object:nil];
}

@end

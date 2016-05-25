//
//  BBTImageUploadManager.h
//  BoBanTang
//
//  Created by Xu Donghui on 26/05/2016.
//  Copyright © 2016 100steps. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BBTImageUploadManager : NSObject

//Directly add these URLs to lost and found or userInfo tables after upload a image
@property (strong, nonatomic) NSString *originalImageUrl;
@property (strong, nonatomic) NSString *thumbnailUrl;

+ (instancetype)sharedUploadManager;
//Singleton method

- (void)uploadImageToQiniu:(UIImage *)image;

@end

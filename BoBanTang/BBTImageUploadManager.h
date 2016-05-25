//
//  BBTImageUploadManager.h
//  BoBanTang
//
//  Created by Xu Donghui on 26/05/2016.
//  Copyright © 2016 100steps. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BBTImageUploadManager : NSObject

@property (strong, nonatomic) NSString *OrgPicUrl;
@property (strong, nonatomic) NSString *thumbnailUrl;

+ (instancetype)sharedUploadManager;
//Singleton method

- (void)uploadImageToQiniu:(UIImage *)image;

@end

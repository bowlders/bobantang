//
//  BBTLAFManager.h
//  BoBanTang
//
//  Created by Hsu Tung Hui on 16/1/30.
//  Copyright © 2016年 100steps. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BBTLAFManager : NSObject

//Singleton LAF Manager
@property NSMutableArray *itemArray;  //Stores a list of items
@property NSString *token;
@property NSString *OrgPicUrl;
@property NSString *thumbUrl;

+ (instancetype)sharedLAFManager;
 //Singleton method
- (void)retriveItems:(NSUInteger)type WithConditions:(NSDictionary *)conditions;
- (void)postItemDic:(NSDictionary *)itemDic WithType:(NSInteger)type;
- (void)getUploadToken;
- (void)uploadImageToQiniu:(UIImage *)image;

@end

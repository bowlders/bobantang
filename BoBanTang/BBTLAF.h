//
//  BBTLAF.h
//  BoBanTang
//
//  Created by Hsu Tung Hui on 16/1/30.
//  Copyright © 2016年 100steps. All rights reserved.
//

#import <JSONModel/JSONModel.h>

@interface BBTLAF : JSONModel

@property (strong, nonatomic) NSString    * ID;
@property (strong, nonatomic) NSString    * account;
@property (strong, nonatomic) NSString    * thumbURL;
@property (strong, nonatomic) NSString    * orgPicUrl;
@property (strong, nonatomic) NSNumber    * campus;
@property (strong, nonatomic) NSString    * location;
@property (strong, nonatomic) NSNumber    * type;
@property (strong, nonatomic) NSString    * phone;
@property (strong, nonatomic) NSString    * otherContact;
@property (strong, nonatomic) NSString    * date;
@property (strong, nonatomic) NSString    * details;
@property (strong, nonatomic) NSString    * publisher;

- (instancetype)initWithResponesObject:(NSDictionary *)dictionary;

@end

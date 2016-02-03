//
//  BBTLAF.h
//  BoBanTang
//
//  Created by Hsu Tung Hui on 16/1/30.
//  Copyright © 2016年 100steps. All rights reserved.
//

#import <JSONModel/JSONModel.h>

@interface BBTLAF : JSONModel

@property (strong, nonatomic) NSNumber *itemID;
@property (strong, nonatomic) NSNumber *loserID;
@property (strong, nonatomic) NSURL *thumbURL;
@property (strong, nonatomic) NSURL *url;
@property (strong, nonatomic) NSString *campus;
@property (strong, nonatomic) NSString *location;
@property (strong, nonatomic) NSNumber *type;
@property (strong, nonatomic) NSString *phone;
@property (strong, nonatomic) NSString *otherContact;
@property (strong, nonatomic) NSString *date;
@property (strong, nonatomic) NSString *details;

@end

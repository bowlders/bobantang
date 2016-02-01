//
//  BBTLAF.h
//  BoBanTang
//
//  Created by Hsu Tung Hui on 16/1/30.
//  Copyright © 2016年 100steps. All rights reserved.
//

#import <JSONModel/JSONModel.h>

@interface BBTLAF : JSONModel

@property (assign, nonatomic) NSUInteger itemID;
@property (assign, nonatomic) NSUInteger loserID;
@property (strong, nonatomic) NSURL *thumbURL;
@property (strong, nonatomic) NSURL *url;
@property (assign, nonatomic) NSUInteger district;
@property (strong, nonatomic) NSString *location;
@property (assign, nonatomic) NSUInteger lostType;
@property (strong, nonatomic) NSString *contact;
@property (strong, nonatomic) NSString *otherContact;
@property (strong, nonatomic) NSString *date;
@property (strong, nonatomic) NSString *details;

@end

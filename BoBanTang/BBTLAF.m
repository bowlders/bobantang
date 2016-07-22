//
//  BBTLAF.m
//  BoBanTang
//
//  Created by Hsu Tung Hui on 16/1/30.
//  Copyright © 2016年 100steps. All rights reserved.
//

#import "BBTLAF.h"

@implementation BBTLAF

- (instancetype)initWithResponesObject:(NSDictionary *)dictionary
{
    self.itemID = (NSString *)dictionary[@"itemID"];
    self.account = (NSString *)dictionary[@"account"];
    self.thumbURL = (NSString *)dictionary[@"thumbnail"];
    self.orgPicUrl = (NSString *)dictionary[@"originalPicture"];
    self.campus = (NSNumber *)dictionary[@"campus"];
    self.location = (NSString *)dictionary[@"location"];
    self.type = (NSNumber *)dictionary[@"type"];
    self.phone = (NSString *)dictionary[@"phone"];
    self.otherContact = (NSString *)dictionary[@"otherContact"];
    self.date = (NSString *)dictionary[@"date"];
    self.details = (NSString *)dictionary[@"details"];
    self.publisher = (NSString *)dictionary[@"publisher"];
    
    return self;
}

@end

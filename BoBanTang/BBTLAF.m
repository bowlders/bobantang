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
    self.ID = ((NSNumber *)dictionary[@"id"]);
    self.account = (NSString *)dictionary[@"account"];
    self.thumbURL = (NSString *)dictionary[@"thumbnail"];
    self.orgPicUrl = (NSString *)dictionary[@"originalPicture"];
    self.campus = (NSNumber *)dictionary[@"campus"];
    self.location = (NSString *)dictionary[@"location"];
    self.type = (NSNumber *)dictionary[@"type"];
    self.phone = (NSString *)dictionary[@"phone"];
    self.otherContact = (NSString *)dictionary[@"otherContact"];
    self.date = (NSString *)dictionary[@"date"];
    self.details = (NSString *)dictionary[@"detail"];
    self.publisher = (NSString *)dictionary[@"publisher"];
    self.title = (NSString *)dictionary[@"title"];
    
    return self;
}
- (void)setOrgPicUrl:(NSString *)orgPicUrl{
    if ([orgPicUrl isKindOfClass:[NSNull class]] || [orgPicUrl isEqual:@"about:blank"]){
        _orgPicUrl = nil;
    }else{
        _orgPicUrl = orgPicUrl;
    }
}
- (void)setThumbURL:(NSString *)thumbURL{
    if ([thumbURL isKindOfClass:[NSNull class]] || [thumbURL isEqual:@"about:blank"]){
        _thumbURL = nil;
    }else{
        _thumbURL = thumbURL;
    }
}
- (void)setPhone:(NSString *)phone{
    if ([phone isKindOfClass:[NSNull class]]){
        _phone = nil;
    }else{
        _phone = phone;
    }
}
- (void)setOtherContact:(NSString *)otherContact{
    if ([otherContact isKindOfClass:[NSNull class]]){
        _otherContact = nil;
    }else{
        _otherContact = otherContact;
    }
}
@end

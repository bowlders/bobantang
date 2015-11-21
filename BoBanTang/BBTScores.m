//
//  BBTScores.m
//  BoBanTang
//
//  Created by Hsu Tung Hui on 21/10/15.
//  Copyright © 2015年 BBT. All rights reserved.
//

#import "BBTScores.h"

@implementation BBTScores

- (id)init
{
    if ((self = [super init])) {
        self.studentName = [[NSString alloc] init];
        self.account = [[NSString alloc] init];
        self.password = [[NSString alloc] init];
    }
    return self;
}

@end

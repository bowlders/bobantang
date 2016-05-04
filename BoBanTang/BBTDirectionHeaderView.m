//
//  BBTDirectionHeaderView.m
//  bobantang
//
//  Created by Bill Bai on 9/7/14.
//  Copyright (c) 2014 Bill Bai. All rights reserved.
//

#import "BBTDirectionHeaderView.h"

@interface BBTDirectionHeaderView()



@end

@implementation BBTDirectionHeaderView

- (id)init
{
    NSArray *views = [[NSBundle mainBundle] loadNibNamed:@"BBTDirectionHeaderView" owner:nil options:nil];
    id mainView = [views firstObject];
    
    return mainView;
}

@end

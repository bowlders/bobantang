//
//  UIFont+BBTFont.m
//  BoBanTang
//
//  Created by Caesar on 16/1/26.
//  Copyright © 2016年 100steps. All rights reserved.
//

#import "UIFont+BBTFont.h"

@implementation UIFont (BBTFont)

+ (UIFont *)BBTInformationTableViewTitleFont
{
    return [UIFont fontWithName:@"PingFangSC-Bold" size:25];
}

+ (UIFont *)BBTInformationTableViewAbstractFont
{
    return [UIFont fontWithName:@"PingFangSC-Ultralight" size:15];
}

+ (UIFont *)BBTInformationTableViewAuthorandDateFont
{
    return [UIFont fontWithName:@"PingFangSC" size:18];
}

@end

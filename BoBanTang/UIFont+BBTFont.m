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
    return [UIFont fontWithName:@"PingFangSC-Regular" size:20];
}

+ (UIFont *)BBTInformationTableViewAbstractFont
{
    return [UIFont fontWithName:@"PingFangSC-Ultralight" size:15];
}

+ (UIFont *)BBTInformationTableViewAuthorandDateFont
{
    return [UIFont fontWithName:@"PingFangSC-Light" size:16];
}

+ (UIFont *)BBTProductNameLabelFont
{
    return [UIFont fontWithName:@"PingFangSC-Regular" size:30];
}

+ (UIFont *)BBTProductDetailLabelFont
{
    return [UIFont fontWithName:@"PingFangSC-Light" size:20];
}

+ (UIFont *)BBTCopyRightLabelFont
{
    return [UIFont fontWithName:@"PingFangSC-Light" size:15];
}

+ (UIFont *)BBTGoLabelFont
{
    return [UIFont fontWithName:@"PingFangSC-Ultralight" size:12];
}

@end

//
//  UIColor+BBTColor.m
//  BoBanTang
//
//  Created by Caesar on 15/11/19.
//  Copyright © 2015年 100steps. All rights reserved.
//

#import "UIColor+BBTColor.h"

@implementation UIColor (BBTColor)

+ (UIColor *)BBTAppGlobalBlue
{
    return [UIColor colorWithRed:0.0f green:153.0f / 255.0f blue:204.0f / 255.0f alpha:1.0f];
}

+ (UIColor *)BBTSusscessfulGreen
{
    return [UIColor colorWithRed:0.0f green:204.0f / 255.0f blue:153.0f / 255.0f alpha:1.0f];
}

+ (UIColor *)BBTInfoSegmentedControlIndicatorBlue
{
    return [UIColor colorWithRed:0.0f green:221/255.0 blue:1.0f alpha:0.3f];
}

@end

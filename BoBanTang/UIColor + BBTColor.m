//
//  UIColor + BBTColor.m
//  BoBanTang
//
//  Created by Caesar on 15/10/15.
//  Copyright © 2015年 BBT. All rights reserved.
//

#import "UIColor + BBTColor.h"

@implementation UIColor (BBTColor)

+ (UIColor *)bbt_ColorWithR:(CGFloat)r G:(CGFloat)g B:(CGFloat)b
{
    return [UIColor colorWithRed:r/255.0f
                           green:g/255.0f
                            blue:b/255.0f
                           alpha:1.0f];
}



@end

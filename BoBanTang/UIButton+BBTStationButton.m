//
//  UIButton+BBTStationButton.m
//  bobantang
//
//  Created by Bill Bai on 8/20/14.
//  Copyright (c) 2014 Bill Bai. All rights reserved.
//
#import "UIColor+BBTColor.h"
#import "UIButton+BBTStationButton.h"

@implementation UIButton (BBTStationButton)

+ (UIButton *)stationButtonWithName:(NSString *)name
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    //button.bounds = CGRectMake(0.0f, 0.0f, 67.0f, 20.0f);
    [button setTitle:name forState:UIControlStateNormal];
    [button setTitleColor:[UIColor BBTAppGlobalBlue] forState:UIControlStateNormal];
    return button;
}
@end

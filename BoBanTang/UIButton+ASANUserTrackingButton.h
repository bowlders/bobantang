//
//  UIButton+ASANUserTrackingButton.h
//  bobantang
//
//  Created by Bill Bai on 9/8/14.
//  Copyright (c) 2014 Bill Bai. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIButton (ASANButton)

+ (UIButton *)ASANUserTrackingButtonWithFrame:(CGRect)frame;
+ (UIButton *)ASANRoundRectButtonWithFrame:(CGRect)frame image:(UIImage *)image;
+ (UIButton *)ASANRoundRectButtonWithFrame:(CGRect)frame title:(NSString *)title;

- (void)changeTitleTo:(NSString *)title;
- (void)changeImageTo:(UIImage *)image;

@end

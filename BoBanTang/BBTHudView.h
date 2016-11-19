//
//  BBTHudView.h
//  BoBanTang
//
//  Created by Hsu Tung Hui on 23/11/15.
//  Copyright © 2015年 100steps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <Foundation/Foundation.h>

@interface BBTHudView : UIView

+ (instancetype)hudInView:(UIView *)view animated:(BOOL)animated;
+ (instancetype)removeHudInView:(UIView *)view withHudView:(BBTHudView *)hudView;

@end
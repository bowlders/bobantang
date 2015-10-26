//
//  BBTBusRouteView.h
//  bobantang
//
//  Created by Bill Bai on 8/20/14.
//  Copyright (c) 2014 Bill Bai. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BBTBusRouteView : UIView

@property (strong, nonatomic) NSMutableArray * greenCircles;
@property (strong, nonatomic) NSMutableArray * violetCircles;
@property (strong, nonatomic) NSMutableArray * circlesOriginYArray;         //储存圆圈纵坐标的值
@property (strong, nonatomic) NSMutableArray * circlesHeightArray;          //储存圆圈高度的值

- (instancetype)initWithFrame:(CGRect)frame Count:(NSUInteger)count;

@end

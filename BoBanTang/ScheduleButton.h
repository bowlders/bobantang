//
//  ScheduleButton.h
//  timeTable1
//
//  Created by zzddn on 2017/8/24.
//  Copyright © 2017年 嘿嘿的客人. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ScheduleButton : UIButton

/**
 该方法的button用于下拉菜单项的按钮

 @param title 标题
 @param frame 大小
 */
- (void)setMemuTitle:(NSString *)title andFrame:(CGRect)frame;
/**
 该方法传入title和frame后，设置好button，这种button用作课表页面的底部button，点击时能添加新的课程

 @param title button的标题
 @param frame 大小
 */
- (void)setTitle:(NSString *)title andFrame:(CGRect)frame;

/**
 该种button用于底部button之上，当有课程时，这种button会覆盖在底部button上，点中该button后会出现课程详细页面

 @param title 标题
 @param frame 大小
 */

- (void)topBtnWithTitle:(NSString *)title andFrame:(CGRect)frame;

/**
 这种button用在选择“周数”的时候弹出的页面上，点击按钮能选中或者取消某周

 @param title 标题
 @param frame 大小
 */
- (void)weekBtnWithTitle:(NSString *)title andFrame:(CGRect)frame;
@end

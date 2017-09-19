//
//  ScheduleButton.m
//  timeTable1
//
//  Created by zzddn on 2017/8/24.
//  Copyright © 2017年 嘿嘿的客人. All rights reserved.
//

#import "ScheduleButton.h"

@implementation ScheduleButton
- (void)setTitle:(NSString *)title andFrame:(CGRect)frame
{
    [self setFrame:frame];
    [self setTitle:title forState:UIControlStateNormal];
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.contentEdgeInsets = UIEdgeInsetsMake(0, 3, 0, 3);
    self.titleLabel.numberOfLines = 0;
    [self.titleLabel sizeToFit];
    self.layer.borderColor = [UIColor colorWithRed:179.0/255.0 green:179.0/255.0 blue:179.0/255.0 alpha:0.8].CGColor;
    self.backgroundColor = [UIColor whiteColor];
    [self.layer setBorderWidth:0.5];
}
- (void)topBtnWithTitle:(NSString *)title andFrame:(CGRect)frame{
    [self setFrame:frame];
    [self setTitle:title forState:UIControlStateNormal];
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.contentEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
    self.titleLabel.numberOfLines = 0;
    [self.titleLabel setFont:[UIFont systemFontOfSize:13.0]];
    [self.titleLabel sizeToFit];
    [self setTintColor:[UIColor colorWithRed:77.0/255.0 green:77.0/255.0 blue:77/255.0 alpha:1]];
    [self.layer setCornerRadius:8.0];
}
- (void)weekBtnWithTitle:(NSString *)title andFrame:(CGRect)frame{
    [self setFrame:frame];
    [self setTitle:title forState:UIControlStateNormal];
    self.titleLabel.font = [UIFont systemFontOfSize:15];
    [self setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.layer.borderColor = [[UIColor colorWithRed:220/255.0 green:220/255.0 blue:220/255.0 alpha:0.8]CGColor];
    self.layer.borderWidth = 1;
    [self.layer setCornerRadius:0.0];
}

- (void)setMemuTitle:(NSString *)title andFrame:(CGRect)frame{
    [self setFrame:frame];
    self.titleLabel.font = [UIFont systemFontOfSize:15];
    [self setTintColor:[UIColor blackColor]];
    [self setTitle:title forState:UIControlStateNormal];
    self.titleLabel.textAlignment = NSTextAlignmentLeft;
    self.titleLabel.numberOfLines=0;
    //[self.layer setCornerRadius:8.0];
}



@end

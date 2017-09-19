//
//  ViewController.h
//  timeTable1
//
//  Created by zzddn on 2017/8/22.
//  Copyright © 2017年 嘿嘿的客人. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ScheduleViewController : UIViewController<UIScrollViewDelegate>
- (void)chooseWeek:(UIButton *)sender;
@property (strong,nonatomic) UIButton *topTitle;
@end


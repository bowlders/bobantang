//
//  FloatingWindow.h
//  timeTable1
//
//  Created by zzddn on 2017/9/16.
//  Copyright © 2017年 嘿嘿的客人. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void (^Blo)(UIButton *btn);

@interface FloatingWindow : UIView
@property (nonatomic,copy)Blo block;
@end

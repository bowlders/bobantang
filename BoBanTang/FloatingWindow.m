//
//  FloatingWindow.m
//  timeTable1
//
//  Created by zzddn on 2017/9/16.
//  Copyright © 2017年 嘿嘿的客人. All rights reserved.
//

#import "FloatingWindow.h"

@interface FloatingWindow()
{
    UIButton *autoImport,*manualImport,*cancel;
}
@end

@implementation FloatingWindow

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]){
        self.backgroundColor = [UIColor colorWithDisplayP3Red:41.0/255.0 green:180.0/255.0 blue:220.0/255.0 alpha:1.0];
        self.tintColor = [UIColor colorWithDisplayP3Red:41.0/255.0 green:180.0/255.0 blue:220.0/255.0 alpha:1.0];
        self.layer.cornerRadius = 8.0;
        
        //选项1 教务导课
        autoImport = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [autoImport setTitle:@"教务导课" forState:UIControlStateNormal];
        [autoImport addTarget:self action:@selector(importDidClick:) forControlEvents:UIControlEventTouchUpInside];
        [autoImport.titleLabel setFont:[UIFont systemFontOfSize:16]];
        [autoImport.titleLabel setTintColor:[UIColor colorWithRed:41.0/255.0 green:180.0/255.0 blue:220.0/255.0 alpha:1.0]];
        [autoImport setBackgroundColor:[UIColor whiteColor]];
        autoImport.layer.cornerRadius = 8.0;
        [self addSubview:autoImport];
        
        //选项2 手动导课
        manualImport = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [manualImport setTitle:@"手动导课" forState:UIControlStateNormal];
        [manualImport addTarget:self action:@selector(importDidClick:) forControlEvents:UIControlEventTouchUpInside];
        [manualImport.titleLabel setFont:[UIFont systemFontOfSize:16]];
        [manualImport.titleLabel setTintColor:[UIColor colorWithRed:41.0/255.0 green:180.0/255.0 blue:220.0/255.0 alpha:1.0]];
        [manualImport setBackgroundColor:[UIColor whiteColor]];
        manualImport.layer.cornerRadius = 8.0;
        [self addSubview:manualImport];
        
        //选项3 取消
        cancel = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [cancel setTitle:@"取消" forState:UIControlStateNormal];
        [cancel addTarget:self action:@selector(importDidClick:) forControlEvents:UIControlEventTouchUpInside];
        [cancel.titleLabel setFont:[UIFont systemFontOfSize:16]];
        [cancel.titleLabel setTintColor:[UIColor colorWithRed:41.0/255.0 green:180.0/255.0 blue:220.0/255.0 alpha:1.0]];
        [cancel setBackgroundColor:[UIColor whiteColor]];
        cancel.layer.cornerRadius = 8.0;
        [self addSubview:cancel];
        
    }
    return self;
}
- (void)layoutSubviews{
    [super layoutSubviews];
    
    [autoImport setFrame:CGRectMake(0, 0, self.frame.size.width*0.7, self.frame.size.height*0.18)];
    [manualImport setFrame:CGRectMake(0, 0, self.frame.size.width*0.7, self.frame.size.height*0.18)];
    [cancel setFrame:CGRectMake(0, 0, self.frame.size.width*0.7, self.frame.size.height*0.18)];
    CGFloat singleH = self.frame.size.height/4.0;
    [autoImport setCenter:CGPointMake(self.frame.size.width/2.0, singleH)];
    [manualImport setCenter:CGPointMake(self.frame.size.width/2.0, singleH*2)];
    [cancel setCenter:CGPointMake(self.frame.size.width/2.0, singleH*3)];
    
}
- (void)importDidClick:(UIButton *)sender{
    self.block(sender);
}
@end

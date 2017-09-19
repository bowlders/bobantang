//
//  TableTextField.m
//  timeTable1
//
//  Created by zzddn on 2017/8/23.
//  Copyright © 2017年 嘿嘿的客人. All rights reserved.
//

#import "TableTextField.h"

@implementation TableTextField

- (instancetype)initWithText:(NSString *)text andFrame:(CGRect)rect
{
    if (self = [super init])
    {
        self.text = text;
        self.textAlignment = NSTextAlignmentCenter;
        self.frame = rect;
        self.textColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:1];
        self.backgroundColor = [UIColor colorWithRed:230.0/255.0 green:233.0/255.0 blue:237.0/255.0 alpha:0.5];
        //self.borderStyle = UITextBorderStyleLine;
        self.layer.borderWidth = 0.5;
        self.layer.borderColor = [[UIColor colorWithRed:179.0/255.0 green:179.0/255.0 blue:179.0/255.0 alpha:0.8]CGColor];
        [self setEnabled:NO];
    }
    return self;
}

@end

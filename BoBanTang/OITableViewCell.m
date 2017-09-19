//
//  OITableViewCell.m
//  timeTable1
//
//  Created by zzddn on 2017/8/28.
//  Copyright © 2017年 嘿嘿的客人. All rights reserved.
//

#import "OITableViewCell.h"


@implementation OITableViewCell


- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)deleteDidClick:(UIButton *)sender {
    [[NSNotificationCenter defaultCenter]postNotificationName:@"deleteCell" object:sender];
}
@end

//
//  BBTItemCampusTableViewCell.m
//  BoBanTang
//
//  Created by Hsu Tung Hui on 16/2/9.
//  Copyright © 2016年 100steps. All rights reserved.
//

#import "BBTItemCampusTableViewCell.h"

@implementation BBTItemCampusTableViewCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    UIView *view = [[UIView alloc] initWithFrame:CGRectZero];
    view.backgroundColor = [UIColor whiteColor];
    self.selectedBackgroundView = view;
    self.campus.tintColor = [UIColor BBTAppGlobalBlue];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end

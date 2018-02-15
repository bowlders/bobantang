//
//  BBTItemImageTableViewCell.m
//  BoBanTang
//
//  Created by Hsu Tung Hui on 16/2/9.
//  Copyright © 2016年 100steps. All rights reserved.
//

#import "BBTItemImageTableViewCell.h"

@implementation BBTItemImageTableViewCell

- (void)awakeFromNib
{   [super awakeFromNib];
    UIView *view = [[UIView alloc] initWithFrame:CGRectZero];
    view.backgroundColor = [UIColor whiteColor];
    self.selectedBackgroundView = view;
    self.itemImage.image = [UIImage imageNamed:@"addNewImage"];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)configureCellWithImage:(UIImage *)image
{
    [self.itemImage setImage:image];
}

@end

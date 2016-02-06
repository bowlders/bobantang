//
//  BBTLafItemsTableViewCell.m
//  BoBanTang
//
//  Created by Hsu Tung Hui on 16/2/3.
//  Copyright © 2016年 100steps. All rights reserved.
//

#import "BBTLafItemsTableViewCell.h"

@implementation BBTLafItemsTableViewCell

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectZero];
    view.backgroundColor = [UIColor whiteColor];
    self.selectedBackgroundView = view;
    self.itemName.numberOfLines = 0;
    [self.itemName sizeToFit];
    self.itemName.adjustsFontSizeToFitWidth = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)configureItemsCells:(NSDictionary *)content
{
    self.thumbLostImageView.image = [UIImage imageNamed:@"testImage"];
    self.itemName.text = content[@"itemID"];
    self.itemDetails.text = content[@"details"];
}

@end

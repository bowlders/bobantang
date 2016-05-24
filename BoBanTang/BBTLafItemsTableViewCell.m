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
    self.thumbLostImageView.contentMode = UIViewContentModeScaleToFill;
    self.thumbLostImageView.clipsToBounds = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)configureItemsCells:(NSDictionary *)content
{
    self.itemDetails.text = content[@"details"];
    switch ([content[@"type"] integerValue]) {
        case 0:
            self.itemName.text = @"大学城一卡通";
            break;
            
        case 1:
            self.itemName.text = @"校园卡(绿卡)";
            break;
            
        case 2:
            self.itemName.text = @"钱包";
            break;
        
        case 3:
            self.itemName.text = @"钥匙";
            break;
            
        case 4:
            self.itemName.text = @"其他";
            
        default:
            break;
    }
}

@end

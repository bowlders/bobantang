//
//  BBTLafItemsTableViewCell.h
//  BoBanTang
//
//  Created by Hsu Tung Hui on 16/2/3.
//  Copyright © 2016年 100steps. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BBTLafItemsTableViewCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UIImageView * thumbLostImageView;
@property (strong, nonatomic) IBOutlet UILabel     * itemName;
@property (strong, nonatomic) IBOutlet UILabel     * itemDetails;

- (void)configureItemsCells:(NSDictionary *)content;

@end

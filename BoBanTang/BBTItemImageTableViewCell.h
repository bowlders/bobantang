//
//  BBTItemImageTableViewCell.h
//  BoBanTang
//
//  Created by Hsu Tung Hui on 16/2/9.
//  Copyright © 2016年 100steps. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BBTItemImageTableViewCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UIImageView *itemImage;

- (void)configureCellWithImage:(UIImage *)image;

@end

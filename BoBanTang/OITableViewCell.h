//
//  OITableViewCell.h
//  timeTable1
//
//  Created by zzddn on 2017/8/28.
//  Copyright © 2017年 嘿嘿的客人. All rights reserved.
//

#import <UIKit/UIKit.h>
@interface OITableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *courseLabel;
@property (weak, nonatomic) IBOutlet UILabel *locationLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *teacherLabel;
@property (weak, nonatomic) IBOutlet UIButton *deleteBtn;
- (IBAction)deleteDidClick:(UIButton *)sender;

@end

//
//  ManualImportVC.h
//  timeTable1
//
//  Created by zzddn on 2017/8/30.
//  Copyright © 2017年 嘿嘿的客人. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol MIProtocol <NSObject>
- (void)MISetDone;
@end
@interface ManualImportVC : UITableViewController
@property (weak, nonatomic) IBOutlet UITableViewCell *weekCell;
@property (weak, nonatomic) IBOutlet UITextField *courseName;
@property (weak, nonatomic) IBOutlet UITextField *teacher;
@property (weak, nonatomic) IBOutlet UITextField *classroom;
@property (weak, nonatomic) IBOutlet UILabel *weekLabel;
@property (weak, nonatomic) IBOutlet UITableViewCell *dayTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (strong, nonatomic) UIPickerView *pickerView;

@property (nonatomic) NSInteger tagValue;
@property (nonatomic,weak) id<MIProtocol>delegate;
@property (weak, nonatomic) IBOutlet UITableViewCell *deleteCell;
@end

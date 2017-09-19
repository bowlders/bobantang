//
//  OITableViewController.h
//  timeTable1
//
//  Created by zzddn on 2017/8/28.
//  Copyright © 2017年 嘿嘿的客人. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol OIDelegate <NSObject>
- (void)updateScheduleView;
@end
@interface OITableViewController : UITableViewController
@property (nonatomic,weak)id<OIDelegate> delegate;
@end

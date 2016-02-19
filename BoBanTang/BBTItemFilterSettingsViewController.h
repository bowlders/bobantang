//
//  BBTItemFilterSettingsViewController.h
//  BoBanTang
//
//  Created by Hsu Tung Hui on 16/2/19.
//  Copyright © 2016年 100steps. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BBTItemFilterSettingsViewController;

@protocol BBTItemFilterSettingsViewControllerDelegate <NSObject>

- (void)BBTItemFilters:(BBTItemFilterSettingsViewController *)controller didFinishSelectConditions:(NSMutableDictionary *)conditions;

@end

@interface BBTItemFilterSettingsViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (weak, nonatomic) id <BBTItemFilterSettingsViewControllerDelegate> delegate;

@end

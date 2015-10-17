//
//  BBTSelfStudyRoomRequestTableViewController.h
//  BoBanTang
//
//  Created by Hsu Tung Hui on 17/10/15.
//  Copyright © 2015年 BBT. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <RETableViewManager/RETableViewManager.h>

@interface BBTSelfStudyRoomRequestTableViewController : UITableViewController <RETableViewManagerDelegate>

@property (strong, nonatomic) RETableViewManager *manager;
@property (strong, nonatomic) IBOutlet RETableViewSection *settingsSection;

@end

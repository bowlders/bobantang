//
//  BBTLectureRoomsQueryTableViewController.h
//  BoBanTang
//
//  Created by Hsu Tung Hui on 8/11/15.
//  Copyright © 2015年 BBT. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BBTLectureRoomsTimeTableViewController.h"
#import "BBTLectureRooms.h"
#import <AFNetworking/AFNetworking.h>
#import "BBTPickerView.h"
#import "BBTLectureRoomsResultTableViewController.h"
#import "BBTHudView.h"

@interface BBTLectureRoomsQueryTableViewController : UITableViewController <BBTLectureRoomsTimeTableViewControllerDelegate>

@property (strong, nonatomic) IBOutlet UIDatePicker *datePicker;
@property (strong, nonatomic) IBOutlet UILabel *time;
@property (strong, nonatomic) IBOutlet UISegmentedControl *campus;
@property (strong, nonatomic) IBOutlet UILabel *buildings;

@end

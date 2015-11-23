//
//  BBTLectureRoomsQueryTableViewController.h
//  BoBanTang
//
//  Created by Hsu Tung Hui on 8/11/15.
//  Copyright © 2015年 BBT. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BBTLectureRoomsTimeTableViewController.h"
#import "BBTBuildingsTableViewController.h"
#import "BBTLectureRooms.h"
#import <AFNetworking/AFNetworking.h>

@interface BBTLectureRoomsQueryTableViewController : UITableViewController <BBTLectureRoomsTimeTableViewControllerDelegate, BBTBuildingsTableViewControllerDelegate>

@property (strong, nonatomic) IBOutlet UIDatePicker *datePicker;
@property (strong, nonatomic) IBOutlet UILabel *time;
@property (strong, nonatomic) IBOutlet UISegmentedControl *campus;
@property (strong, nonatomic) IBOutlet UILabel *buildings;

@property (strong, nonatomic) BBTLectureRooms *lectureRoomsFilter;

@end

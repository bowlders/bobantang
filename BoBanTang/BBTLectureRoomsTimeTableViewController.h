//
//  BBTLectureRoomsTimeTableViewController.h
//  BoBanTang
//
//  Created by Hsu Tung Hui on 7/11/15.
//  Copyright © 2015年 BBT. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BBTLectureRoomsTimeTableViewController;

@protocol BBTLectureRoomsTimeTableViewControllerDelegate <NSObject>

- (void)BBTLectureRoomsTime:(BBTLectureRoomsTimeTableViewController *)controller didFinishSelectTime:(NSMutableArray *) selectedTime;

@end

@interface BBTLectureRoomsTimeTableViewController : UITableViewController

@property (strong,nonatomic) NSArray *period;

@property (nonatomic, weak) id <BBTLectureRoomsTimeTableViewControllerDelegate> delegate;

@end

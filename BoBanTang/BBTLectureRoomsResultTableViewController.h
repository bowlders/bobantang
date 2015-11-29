//
//  BBTLectureRoomsResultTableViewController.h
//  BoBanTang
//
//  Created by Hsu Tung Hui on 24/11/15.
//  Copyright © 2015年 100steps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BBTLectureRooms.h"

@interface BBTLectureRoomsResultTableViewController : UITableViewController

@property (strong, nonatomic) NSArray *resultRooms;
@property (strong, nonatomic) NSArray *rawData;
@property (strong, nonatomic) BBTLectureRooms *filterConditions;

@end

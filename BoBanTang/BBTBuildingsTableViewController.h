//
//  BBTBuildingsTableViewController.h
//  BoBanTang
//
//  Created by Hsu Tung Hui on 10/11/15.
//  Copyright © 2015年 BBT. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BBTBuildingsTableViewController;

@protocol BBTBuildingsTableViewControllerDelegate <NSObject>

- (void)BBTBuildings:(BBTBuildingsTableViewController *)controller didFinishSelectBuildings:(NSMutableArray *)selectedBuildings;

@end

@interface BBTBuildingsTableViewController : UITableViewController

@property (strong, nonatomic) NSArray *buildingsToChoose;
@property (weak, nonatomic) id<BBTBuildingsTableViewControllerDelegate> delegate;

@end

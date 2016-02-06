//
//  BBTItemDetailsTableViewController.h
//  BoBanTang
//
//  Created by Hsu Tung Hui on 16/2/3.
//  Copyright © 2016年 100steps. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BBTItemDetailsTableViewController : UITableViewController

@property (strong, nonatomic) NSDictionary *itemDetails;
@property BOOL lostOrFound;

@end

//
//  BBTItemDetailsTableViewController.h
//  BoBanTang
//
//  Created by Hsu Tung Hui on 16/2/3.
//  Copyright © 2016年 100steps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MWPhotoBrowser.h"
#import "BBTLAF.h"

@interface BBTItemDetailsTableViewController : UITableViewController <MWPhotoBrowserDelegate>

@property (strong, nonatomic) BBTLAF *itemDetails;
@property BOOL lostOrFound;

@end

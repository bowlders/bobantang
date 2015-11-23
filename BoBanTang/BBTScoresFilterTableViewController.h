//
//  BBTScoresFilterTableViewController.h
//  BoBanTang
//
//  Created by Hsu Tung Hui on 21/11/15.
//  Copyright © 2015年 100steps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BBTScores.h"
#import "BBTScoresQueryResultsTableViewController.h"

@interface BBTScoresFilterTableViewController : UITableViewController <UIPickerViewDelegate, UIPickerViewDataSource>

@property (strong, nonatomic) BBTScores *scores;

@end

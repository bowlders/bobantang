//
//  BBTLostAndFoundTableViewController.h
//  BoBanTang
//
//  Created by Hsu Tung Hui on 16/1/29.
//  Copyright © 2016年 100steps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BBTItemFilterSettingsViewController.h"

@interface BBTLostAndFoundTableViewController : UITableViewController <UISearchBarDelegate, UISearchControllerDelegate, UISearchResultsUpdating, UIPopoverControllerDelegate, UIPopoverPresentationControllerDelegate, BBTItemFilterSettingsViewControllerDelegate>

@end

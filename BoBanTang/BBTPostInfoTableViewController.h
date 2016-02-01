//
//  BBTPostInfoTableViewController.h
//  BoBanTang
//
//  Created by Hsu Tung Hui on 16/1/30.
//  Copyright © 2016年 100steps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BBTItemDetailViewController.h"

@interface BBTPostInfoTableViewController : UITableViewController <UIGestureRecognizerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, BBTItemDetailViewControllerDelegate>

@property (strong, nonatomic) NSString *postType;

@end

//
//  BBTPostInfoTableViewController.h
//  BoBanTang
//
//  Created by Hsu Tung Hui on 16/1/30.
//  Copyright © 2016年 100steps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BBTItemDetailEditingViewController.h"

@interface BBTPostInfoTableViewController : UITableViewController <UIGestureRecognizerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, BBTItemDetailEditingViewControllerDelegate>

@property (strong, nonatomic) NSString *postType;

@end

//
//  BBTPostInfoViewController.h
//  BoBanTang
//
//  Created by Hsu Tung Hui on 16/2/9.
//  Copyright © 2016年 100steps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BBTItemDetailEditingViewController.h"

@interface BBTPostInfoViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UIGestureRecognizerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate, BBTItemDetailEditingViewControllerDelegate>

@property (assign, nonatomic) NSNumber     * lostOrFound;

@end

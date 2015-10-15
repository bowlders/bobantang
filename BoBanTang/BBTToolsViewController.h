//
//  BBTToolsViewController.h
//  BoBanTang
//
//  Created by Hsu Tung Hui on 14/10/15.
//  Copyright © 2015年 BBT. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreText/CoreText.h>
#import "FUIButton.h"
#import "UIColor+FlatUI.h"
#import "UIFont+FlatUI.h"

@interface BBTToolsViewController : UIViewController

@property (strong, nonatomic) IBOutlet FUIButton *campusMap;
@property (strong, nonatomic) IBOutlet FUIButton *grade;
@property (strong, nonatomic) IBOutlet FUIButton *availiableLecRoom;
@property (strong, nonatomic) IBOutlet FUIButton *information;

@end

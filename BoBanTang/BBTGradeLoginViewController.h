//
//  BBTGradeLoginViewController.h
//  BoBanTang
//
//  Created by Hsu Tung Hui on 15/10/15.
//  Copyright © 2015年 BBT. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FlatUIKit.h"
#import <CFNetwork/CFNetwork.h>
#import <AFNetworking/AFNetworking.h>

@interface BBTGradeLoginViewController : UIViewController

@property (strong, nonatomic) IBOutlet FUITextField *studentsNumber;
@property (strong, nonatomic) IBOutlet FUITextField *passwordToJW;
@property (strong, nonatomic) IBOutlet UIButton *loginButton;
@property (strong, nonatomic) IBOutlet UISwitch *isSavePassWord;

@end

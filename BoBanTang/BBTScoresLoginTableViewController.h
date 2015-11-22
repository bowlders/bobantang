//
//  BBTScoresLoginTableViewController.h
//  BoBanTang
//
//  Created by Hsu Tung Hui on 8/11/15.
//  Copyright © 2015年 BBT. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AFNetworking/AFNetworking.h>
#import "BBTScores.h"
#import <Security/Security.h>
#import "JNKeychain.h"
#import "BBTScoresFilterTableViewController.h"

@interface BBTScoresLoginTableViewController : UITableViewController

@property (strong, nonatomic) IBOutlet UITextField *studentsNumber;
@property (strong, nonatomic) IBOutlet UITextField *passwordToJW;
@property (strong, nonatomic) IBOutlet UISwitch *isSavePassword;

@property (strong, nonatomic) BBTScores *userInfo;

@end

//
//  BBTToolsViewController.m
//  BoBanTang
//
//  Created by Hsu Tung Hui on 14/10/15.
//  Copyright © 2015年 BBT. All rights reserved.
//

#import "BBTToolsViewController.h"

@interface BBTToolsViewController ()

@end

@implementation BBTToolsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.navigationController.navigationBar setBarTintColor: [UIColor colorWithRed:0/255.0 green:153.0/255.0 blue:204.0/255.0 alpha:1.0]];
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor],NSForegroundColorAttributeName,nil]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

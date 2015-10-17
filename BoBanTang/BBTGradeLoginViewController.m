//
//  BBTGradeLoginViewController.m
//  BoBanTang
//
//  Created by Hsu Tung Hui on 15/10/15.
//  Copyright © 2015年 BBT. All rights reserved.
//

#import "BBTGradeLoginViewController.h"
#import "UIColor + BBTColor.h"

@interface BBTGradeLoginViewController ()

@end

@implementation BBTGradeLoginViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor],NSForegroundColorAttributeName,nil]];
    self.navigationController.navigationBar.tintColor=[UIColor whiteColor];
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

//
//  BBTToolsTableViewController.m
//  BoBanTang
//
//  Created by Hsu Tung Hui on 16/2/16.
//  Copyright © 2016年 100steps. All rights reserved.
//

#import "BBTToolsTableViewController.h"
#import "BBTCurrentUserManager.h"
#import "BBTLoginViewController.h"
#import "BBTScoresTableViewController.h"
#import "UIColor+BBTColor.h"

@interface BBTToolsTableViewController ()

@property (strong, nonatomic) IBOutlet UIImageView *roomImage;
@property (strong, nonatomic) IBOutlet UIImageView *socresImage;
@property (strong, nonatomic) IBOutlet UIImageView *lostAndFoundImage;
@property (strong, nonatomic) IBOutlet UIImageView *mapImage;

@end

@implementation BBTToolsTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.navigationController.navigationBar setBarTintColor: [UIColor BBTAppGlobalBlue]];
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor],NSForegroundColorAttributeName,nil]];
    
    self.roomImage.image = [UIImage imageNamed:@"roomLogo"];
    self.socresImage.image = [UIImage imageNamed:@"scoresLogo"];
    self.lostAndFoundImage.image = [UIImage imageNamed:@"lostAndFoundLogo"];
    self.mapImage.image = [UIImage imageNamed:@"mapLogo"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.01f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 5.0f;
}

@end

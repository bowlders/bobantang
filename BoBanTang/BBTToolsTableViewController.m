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
#import "BBTMapContainerVC.h"
#import <Masonry.h>

static NSString *showScoresIdentifier = @"showScores";

@interface BBTToolsTableViewController ()

@property (strong, nonatomic) IBOutlet UIImageView *roomImage;
@property (strong, nonatomic) IBOutlet UIImageView *socresImage;
@property (strong, nonatomic) IBOutlet UIImageView *lostAndFoundImage;
@property (strong, nonatomic) IBOutlet UIImageView *mapImage;
@property (weak,   nonatomic) IBOutlet UILabel     *roomLabel;
@property (weak,   nonatomic) IBOutlet UILabel     *scoresLabel;
@property (weak,   nonatomic) IBOutlet UILabel     *lostAndFoundLabel;
@property (weak,   nonatomic) IBOutlet UILabel     *mapLabel;

@end

@implementation BBTToolsTableViewController

extern NSString * kUserAuthentificationFinishNotifName;

- (void)viewWillAppear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveUserAuthentificaionNotification) name:kUserAuthentificationFinishNotifName object:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.navigationController.navigationBar setBarTintColor: [UIColor BBTAppGlobalBlue]];
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor],NSForegroundColorAttributeName,nil]];
    
    self.roomImage.image = [UIImage imageNamed:@"自习icon"];
    self.socresImage.image = [UIImage imageNamed:@"成绩icon"];
    self.lostAndFoundImage.image = [UIImage imageNamed:@"失物招领icon"];
    self.mapImage.image = [UIImage imageNamed:@"地图icon"];
    
    [self configureSize:self.roomImage andLabel:self.roomLabel];
    [self configureSize:self.socresImage andLabel:self.scoresLabel];
    [self configureSize:self.lostAndFoundImage andLabel:self.lostAndFoundLabel];
    [self configureSize:self.mapImage andLabel:self.mapLabel];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)didReceiveUserAuthentificaionNotification
{
    return YES;
}

- (void)configureSize:(UIImageView *)imageView andLabel:(UILabel *)label
{
    CGFloat innerSpacing = 10.0f;
    
    [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(imageView.superview).offset(innerSpacing);
        make.centerX.equalTo(imageView.superview.mas_centerX);
        make.width.equalTo(@(imageView.image.size.width));
        make.height.equalTo(@(imageView.image.size.height));
    }];
    
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(imageView).offset(innerSpacing);
        make.centerX.equalTo(imageView.mas_centerX);
        make.right.equalTo(label.superview);
    }];
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.01f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 5.0f;
}

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
    if ([identifier isEqualToString:showScoresIdentifier]) {
        if ([[BBTCurrentUserManager sharedCurrentUserManager] userIsActive])
        {
            return YES;
        } else {
            BBTLoginViewController *loginViewController = [[BBTLoginViewController alloc] init];
            UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:loginViewController];
            [self presentViewController:navigationController animated:YES completion:nil];
            return NO;
        }
    } else {
        return YES;
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:showScoresIdentifier])
    {
        BBTScoresTableViewController *controller = segue.destinationViewController;
        NSDictionary *account =@{@"account":[BBTCurrentUserManager sharedCurrentUserManager].currentUser.account,
                                 @"password":[BBTCurrentUserManager sharedCurrentUserManager].currentUser.password
                                 };
        controller.userInfo = [[NSMutableDictionary alloc] initWithDictionary:account];
    }
}

@end

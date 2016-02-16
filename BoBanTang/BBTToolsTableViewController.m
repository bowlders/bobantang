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

static NSString *showScoresIdentifier = @"showScores";

@interface BBTToolsTableViewController ()

@property (strong, nonatomic) IBOutlet UIImageView *roomImage;
@property (strong, nonatomic) IBOutlet UIImageView *socresImage;
@property (strong, nonatomic) IBOutlet UIImageView *lostAndFoundImage;
@property (strong, nonatomic) IBOutlet UIImageView *mapImage;

@property (strong, nonatomic) NSDictionary *userInfo;

@end

@implementation BBTToolsTableViewController

extern NSString * kUserAuthentificationFinishNotifName;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.navigationController.navigationBar setBarTintColor: [UIColor BBTAppGlobalBlue]];
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor],NSForegroundColorAttributeName,nil]];
    
    self.roomImage.image = [UIImage imageNamed:@"roomLogo"];
    self.socresImage.image = [UIImage imageNamed:@"scoresLogo"];
    self.lostAndFoundImage.image = [UIImage imageNamed:@"lostAndFoundLogo"];
    self.mapImage.image = [UIImage imageNamed:@"mapLogo"];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveUserAuthentificaionNotification) name:kUserAuthentificationFinishNotifName object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)didReceiveUserAuthentificaionNotification
{
    NSLog(@"User Authentification received");
    
    self.userInfo = @{@"account":[BBTCurrentUserManager sharedCurrentUserManager].currentUser.account,
                      @"password":[BBTCurrentUserManager sharedCurrentUserManager].currentUser.password
                      };
    return YES;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.01f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 5.0f;
}

#pragma mark - Navigation

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
    if ([identifier isEqualToString:showScoresIdentifier])
    {
        if ([BBTCurrentUserManager sharedCurrentUserManager].userIsActive)
        {
            return YES;
        } else {
            UIAlertController *alertController = [[UIAlertController alloc] init];
            alertController = [UIAlertController alertControllerWithTitle:@"你还没有登录哟" message:@"请先登录" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"去登陆"
                                                               style:UIAlertActionStyleDefault
                                                             handler:^(UIAlertAction * action) {
                                                                 BBTLoginViewController *loginViewController = [[BBTLoginViewController alloc] init];
                                                                 [self presentViewController:loginViewController animated:YES completion:nil];
                                                                 }];
            
            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel"
                                                                   style:UIAlertActionStyleCancel
                                                                 handler:nil];
            
            [alertController addAction:cancelAction];
            [alertController addAction:okAction];
            
            [self presentViewController:alertController animated:YES completion:nil];
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
        controller.userInfo = [[NSMutableDictionary alloc] initWithDictionary:self.userInfo];
    }
}


@end

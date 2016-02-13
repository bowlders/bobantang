//
//  settingsViewController.m
//  BoBanTang
//
//  Created by Caesar on 15/10/15.
//  Copyright © 2015年 BBT. All rights reserved.
//

#import "BBTSettingsViewController.h"
#import "BBTCurrentUserManager.h"
#import <JNKeychain.h>
#import <JGProgressHUD.h>

@interface BBTSettingsViewController ()

@property (strong, nonatomic) IBOutlet UISwitch *appSwitch;
@property (strong, nonatomic) IBOutlet UISwitch *scoreInquireSwitch;
@property (strong, nonatomic) IBOutlet UILabel *appLabel;
@property (strong, nonatomic) IBOutlet UILabel *exitLoginLabel;

@end

@implementation BBTSettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"设置";

    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.scrollEnabled = NO;

    self.appSwitch.on = (int)[JNKeychain loadValueForKey:@"appSwitchStatus"];
    self.scoreInquireSwitch.on = (int)[JNKeychain loadValueForKey:@"scoreSwitchStatus"];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    CGFloat sectionHeight;
    
    switch (section) {
        case 0:
            sectionHeight = 15.0f;
            break;
        case 1:
            sectionHeight = 5.0f;
            break;
        case 2:
            sectionHeight = 40.0f;
            break;
        case 3:
            sectionHeight = 15.0f;
            break;
        default:
            NSAssert(NO, @"Invalid section index");
    }
    
    return sectionHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1)
    {
        [self downLoadMap];
    }
    else if (indexPath.section == 2)
    {
        [self clearCache];
    }
    else if (indexPath.section == 3)
    {
        [self logOut];
    }

}

- (void)downLoadMap
{
    //TODO: Download 2.5D map here.
}

- (void)clearCache
{
    //TODO: Clear cache here.
}

- (void)logOut
{
    BBTUser *emptyUser;
    [BBTCurrentUserManager sharedCurrentUserManager].currentUser = emptyUser;
    [BBTCurrentUserManager sharedCurrentUserManager].userIsActive = NO;
    
    JGProgressHUD *HUD = [JGProgressHUD progressHUDWithStyle:JGProgressHUDStyleDark];
    HUD.indicatorView = nil;
    HUD.textLabel.text = @"您已退出登录";
    [HUD showInView:self.view];
    [HUD dismissAfterDelay:3.0];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *cellIdentifier = @"settingCell";
    
    UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    
    if (!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    if (indexPath.section == 0)
    {
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        if (indexPath.row == 0)
        {
            if (![BBTCurrentUserManager sharedCurrentUserManager].userIsActive)
            {
                cell.userInteractionEnabled = NO;
                self.appSwitch.enabled = NO;
                self.appLabel.enabled = NO;
            }
        }
    }
    
    if (indexPath.section == 3)
    {
        if (![BBTCurrentUserManager sharedCurrentUserManager].userIsActive)
        {
            cell.userInteractionEnabled = NO;
            self.exitLoginLabel.enabled = NO;
        }
    }
    
    return cell;
}

- (IBAction)valueChanged:(UISwitch *)sender
{
    NSLog(@"Switch %ld is currently at status %d", (long)sender.tag, sender.on);
    NSNumber *boolNumber = [NSNumber numberWithBool:sender.on];
    if (sender.tag == 0)
    {
        [JNKeychain saveValue:boolNumber forKey:@"appSwitchStatus"];
        if (sender.on)                          //Change from off to on, then save current user's userName and passWord
        {
            [[BBTCurrentUserManager sharedCurrentUserManager] saveCurrentUserInfo];
        }
        else                                    //Otherwise delete current user's info
        {
            [[BBTCurrentUserManager sharedCurrentUserManager] deleteCurrentUserInfo];
        }
    }
    else if (sender.tag == 1)
    {
        [JNKeychain saveValue:boolNumber forKey:@"scoreSwitchStatus"];
        
        //TODO: Deal With score inquire switch event
    }
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

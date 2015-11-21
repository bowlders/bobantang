//
//  BBTScoresLoginTableViewController.m
//  BoBanTang
//
//  Created by Hsu Tung Hui on 8/11/15.
//  Copyright © 2015年 BBT. All rights reserved.
//

#import "BBTScoresLoginTableViewController.h"

static NSString *checkAutenticationURL = @"http://218.192.166.167/api/jw2005/checkAccount.php";

@interface BBTScoresLoginTableViewController ()

@end

@implementation BBTScoresLoginTableViewController
{
    BOOL _loginStatus;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if ((self = [super initWithCoder:aDecoder])) {
        self.userInfo = [[BBTScores alloc] init];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor],NSForegroundColorAttributeName,nil]];
    self.navigationController.navigationBar.tintColor=[UIColor whiteColor];
    self.navigationItem.title = @"成绩查询";
    
    [self.passwordToJW setSecureTextEntry:YES];
    [self fetchUserAccountInfo];
    
    self.studentsNumber.text = self.userInfo.account;
    self.passwordToJW.text = self.userInfo.password;
}

- (void)viewWillDisappear:(BOOL)animated
{
    if (self.isSavePassword.on) {
        [JNKeychain saveValue:self.userInfo.account forKey:@"account"];
        [JNKeychain saveValue:self.userInfo.password forKey:@"password"];
    } else if (!self.isSavePassword.on) {
        [JNKeychain deleteValueForKey:@"account"];
        [JNKeychain deleteValueForKey:@"password"];
    }
}

- (void)fetchUserAccountInfo
{
    if ([JNKeychain loadValueForKey:@"account"]) {
        self.userInfo.account = [JNKeychain loadValueForKey:@"account"];
        self.userInfo.password = [JNKeychain loadValueForKey:@"password"];
    } else {
        return;
    }
}

#pragma mark - Table view data source
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == 1)
    {
        if (indexPath.row == 0) {
            if ([self.studentsNumber.text length] == 0 || [self.passwordToJW.text length] == 0) {
                [self showAlert:@"1"];
                return;
            }
            
            [self isAuthenticaionConfirmed];
            [self.studentsNumber resignFirstResponder];
            [self.passwordToJW resignFirstResponder];
        }
    } else {
        return;
    }
    
}

#pragma Deal with network stuff
- (void)isAuthenticaionConfirmed
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSDictionary *parameters = @{@"account":self.studentsNumber.text,
                                 @"password":self.passwordToJW.text};
    [manager POST:checkAutenticationURL parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
        dispatch_async(dispatch_get_main_queue(), ^{
            [self parseDictionary:responseObject];
        });
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        [self showAlert:@"3"];
    }];
}

- (void)parseDictionary: (NSDictionary *)dictionary
{
    NSString *errorInfo = dictionary[@"err"];
    if ([errorInfo isEqualToString:@"subsequent request failed"]) {
        [self showAlert:@"3"];
    } else if ([errorInfo isEqualToString:@"login failed"]) {
        [self showAlert:@"2"];
    } else {
        
        //when getting the name, it means the account and password is correct and then perform segue.
        self.userInfo.studentName = dictionary[@"name"];
        self.userInfo.account = self.studentsNumber.text;
        self.userInfo.password = self.passwordToJW.text;
        
        [self performSegueWithIdentifier:@"showScores" sender:self];
    }
}

- (void)showAlert: (NSString *)errorType
{
    UIAlertController *alertController = [[UIAlertController alloc] init];
    if ([errorType isEqualToString:@"1"]) {
        alertController = [UIAlertController alertControllerWithTitle:@"请输全用户名和密码" message:@"冬辉好帅！" preferredStyle:UIAlertControllerStyleAlert];
    } else if ([errorType isEqualToString:@"2"]) {
        alertController = [UIAlertController alertControllerWithTitle:@"用户名或密码错误" message:@"冬辉好帅！" preferredStyle:UIAlertControllerStyleAlert];
    } else if ([errorType isEqualToString:@"3"]) {
        alertController = [UIAlertController alertControllerWithTitle:@"连接错误" message:@"请稍后再试" preferredStyle:UIAlertControllerStyleAlert];
    }
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleDefault handler:nil];
    [alertController addAction:okAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation

//First, refuse segue waiting for JSON results. Or it will push to the next viewContorller before get the authentication from JW2005
- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
    return NO;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
    BBTScoresQueryResultsTableViewController *controller = segue.destinationViewController;
    controller.scores = [[BBTScores alloc] init];
    controller.scores.studentName = self.userInfo.studentName;
    controller.scores.account = self.userInfo.account;
    controller.scores.password = self.userInfo.password;
    
}
@end

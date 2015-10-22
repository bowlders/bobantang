//
//  BBTGradeLoginViewController.m
//  BoBanTang
//
//  Created by Hsu Tung Hui on 15/10/15.
//  Copyright © 2015年 BBT. All rights reserved.
//

#import "BBTGradeLoginViewController.h"
#import "UIColor+BBTColor.h"

static NSString *checkAutenticationURL = @"http://218.192.166.167/api/jw2005/checkAccount.php";
static NSString *getScoreURL = @"http://218.192.166.167/api/jw2005/getScore.php";

@interface BBTGradeLoginViewController ()

@end

@implementation BBTGradeLoginViewController
{
    BOOL _loginStatus;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor],NSForegroundColorAttributeName,nil]];
    self.navigationController.navigationBar.tintColor=[UIColor whiteColor];
    //[self.passwordToJW setSecureTextEntry:YES];
}

- (IBAction)didClickLogin:(UIButton *)sender
{
    
    [self isAuthenticaionConfirmed];
    [self.studentsNumber resignFirstResponder];
    [self.passwordToJW resignFirstResponder];
    
}

- (void)isErrorOccur
{
    NSString *errorType;
    if ([self.studentsNumber.text length] == 0 || [self.passwordToJW.text length] == 0)
    {
        errorType = @"1";
        [self showAlert:errorType];
    } else {
        errorType = @"2";
        [self showAlert:errorType];
    }
}

- (void)isAuthenticaionConfirmed
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSDictionary *parameters = @{@"account":self.studentsNumber.text,
                                 @"password":self.passwordToJW.text};
    [manager POST:getScoreURL parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        [self isErrorOccur];
    }];
}

- (void)showAlert: (NSString *)errorType
{
    UIAlertController *alertController = [[UIAlertController alloc] init];
    if ([errorType isEqualToString:@"1"]) {
        alertController = [UIAlertController alertControllerWithTitle:@"请输全用户名和密码" message:@"冬辉好帅！" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleDefault handler:nil];
        [alertController addAction:okAction];
    } else if ([errorType isEqualToString:@"2"]) {
        alertController = [UIAlertController alertControllerWithTitle:@"用户名或密码错误" message:@"冬辉好帅！" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleDefault handler:nil];
        [alertController addAction:okAction];
    }
    
    [self presentViewController:alertController animated:nil completion:nil];
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

//
//  BBTScoresLoginViewController.m
//  BoBanTang
//
//  Created by Xu Donghui on 16/3/29.
//  Copyright © 2016年 100steps. All rights reserved.
//

#import "BBTScoresLoginViewController.h"
#import "BBTScoresTableViewController.h"
#import "BBTLoginTableViewCell.h"
#import "UIColor+BBTColor.h"
#import "BBTScoresManager.h"
#import "BBTCurrentUserManager.h"
#import <AYVibrantButton.h>
#import <Masonry.h>
#import <JNKeychain.h>
#import <JGProgressHUD.h>
#import <MBProgressHUD.h>

static NSString *showScoresIdentifier = @"showScores";

@interface BBTScoresLoginViewController ()

@property (strong, nonatomic) UITableView     * tableView;
@property (strong, nonatomic) AYVibrantButton * loginButton;

@property (strong, nonatomic) NSDictionary *userInfo;

@end

@implementation BBTScoresLoginViewController

extern NSString * kUserAuthentificationFinishNotifName;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.title = @"请登录教务系统";
    self.tableView.scrollEnabled = NO;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceiveUserAuthenticationNotif)
                                                 name:kUserAuthentificationFinishNotifName
                                               object:nil];
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.tableView.scrollEnabled = NO;
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    UIVisualEffectView *effectView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleExtraLight]];
    effectView.frame = self.view.bounds;
    [self.view addSubview:effectView];
    
    self.loginButton = [[AYVibrantButton alloc] initWithFrame:CGRectZero style:AYVibrantButtonStyleFill];
    self.loginButton.vibrancyEffect = nil;
    self.loginButton.text = @"登录";
    self.loginButton.font = [UIFont systemFontOfSize:18.0];
    [self.loginButton addTarget:self action:@selector(loginButtonIsTapped) forControlEvents:UIControlEventTouchUpInside];
    self.loginButton.backgroundColor = [UIColor BBTAppGlobalBlue];
    [effectView.contentView addSubview:self.loginButton];
    
    [self.view addSubview:self.tableView];
    
    CGFloat navigationBarHeight = self.navigationController.navigationBar.frame.size.height;
    CGFloat verticalInnerSpacing = 50.0f;
    CGFloat tableViewHeight = 100.0f;
    CGFloat loginButtonHeight = 50.0f;
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_top).offset(navigationBarHeight + verticalInnerSpacing);
        make.height.equalTo(@(tableViewHeight));
        make.width.equalTo(self.view.mas_width);
        make.centerX.equalTo(self.view.mas_centerX);
    }];
    
    [self.loginButton mas_makeConstraints:^(MASConstraintMaker *make){
        make.top.equalTo(self.tableView.mas_bottom).offset(verticalInnerSpacing);
        make.height.equalTo(@(loginButtonHeight));
        make.width.equalTo(self.view.mas_width).multipliedBy(0.55);
        make.centerX.equalTo(self.view.mas_centerX);
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *loginTableViewCellIdentifier = @"loginCell";
    
    BBTLoginTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:loginTableViewCellIdentifier];
    
    if (!cell)
    {
        cell = [[BBTLoginTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:loginTableViewCellIdentifier];
    }
    
    if (indexPath.row == 0)
    {
        [cell setCellContentWithLabelText:@"学号" andTextFieldPlaceHolder:@"请填写教务系统的学号"];
        cell.textField.keyboardType = UIKeyboardTypeNumberPad;
        cell.textField.tag = 0;
        if ((int)[[JNKeychain loadValueForKey:@"appSwitchStatus"] boolValue])       //Automatically fill in
        {
            NSString *savedUserName = [JNKeychain loadValueForKey:@"userName"];
            [cell presetTextFieldContentWithString:savedUserName];
        }
    }
    else if (indexPath.row == 1)
    {
        [cell setCellContentWithLabelText:@"密码" andTextFieldPlaceHolder:@"请填写教务系统的密码"];
        cell.textField.tag = 1;
        cell.textField.secureTextEntry = YES;
        if ((int)[[JNKeychain loadValueForKey:@"appSwitchStatus"] boolValue])       //Automatically fill in
        {
            NSString *savedPassWord = [JNKeychain loadValueForKey:@"passWord"];
            [cell presetTextFieldContentWithString:savedPassWord];
        }
    }
    
    cell.textField.delegate = self;
    
    [cell setNeedsUpdateConstraints];
    [cell updateConstraintsIfNeeded];
    
    return cell;
    
}

//Resign keyboard when tapping other places on screen
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
    [super touchesBegan:touches withEvent:event];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField.tag == 0)
    {
        UITextField *passwordTextField = (UITextField *)((BBTLoginTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]]).textField;
        [passwordTextField becomeFirstResponder];
    }
    else
    {
        [textField resignFirstResponder];
        [self loginButtonIsTapped];
    }
    return YES;
}

- (void)loginButtonIsTapped
{
    //Show loading hud
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    NSString *currentUserUserName = ((UITextField *)((BBTLoginTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]]).textField).text;
    NSString *currenUserPassWord = ((UITextField *)((BBTLoginTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]]).textField).text;
    
    [BBTCurrentUserManager sharedCurrentUserManager].currentUser = [BBTUser new];
    [BBTCurrentUserManager sharedCurrentUserManager].currentUser.account = currentUserUserName;
    [BBTCurrentUserManager sharedCurrentUserManager].currentUser.password = currenUserPassWord;
    [[BBTCurrentUserManager sharedCurrentUserManager] currentUserAuthentication];
}

- (void)didReceiveUserAuthenticationNotif
{
    if ([BBTCurrentUserManager sharedCurrentUserManager].userIsActive)
    {
        self.userInfo = @{@"account":[BBTCurrentUserManager sharedCurrentUserManager].currentUser.account,
                          @"password":[BBTCurrentUserManager sharedCurrentUserManager].currentUser.password
                          };
        
        //Hide loading hud
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        
        JGProgressHUD *HUD = [JGProgressHUD progressHUDWithStyle:JGProgressHUDStyleDark];
        HUD.textLabel.text = @"登录成功";
        HUD.indicatorView = [[JGProgressHUDSuccessIndicatorView alloc] init];
        HUD.square = YES;
        [HUD showInView:self.view];
        [HUD dismissAfterDelay:2.0];
        
        [self performSegueWithIdentifier:showScoresIdentifier sender:self.userInfo];
    }
    else
    {
        //Hide loading hud
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        
        JGProgressHUD *HUD = [JGProgressHUD progressHUDWithStyle:JGProgressHUDStyleDark];
        HUD.textLabel.text = @"登录失败";
        HUD.indicatorView = [[JGProgressHUDErrorIndicatorView alloc] init];
        HUD.square = YES;
        [HUD showInView:self.view];
        [HUD dismissAfterDelay:2.0];
    }
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:showScoresIdentifier])
    {
        BBTScoresTableViewController *controller = segue.destinationViewController;
        controller.userInfo = [[NSMutableDictionary alloc] initWithDictionary:sender];
    }
}

@end
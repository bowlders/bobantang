//
//  BBTLoginViewController.m
//  BoBanTang
//
//  Created by Caesar on 16/2/5.
//  Copyright © 2016年 100steps. All rights reserved.
//

#import "BBTLoginViewController.h"
#import "BBTLoginTableViewCell.h"
#import "BBTUser.h"
#import "BBTCurrentUserManager.h"
#import "UIColor+BBTColor.h"
#import <AYVibrantButton.h>
#import <Masonry.h>
#import <JNKeychain.h>
#import <JGProgressHUD.h>
#import <MBProgressHUD.h>

@interface BBTLoginViewController ()

@property (strong, nonatomic) UIImageView     * logoImageView;
@property (strong, nonatomic) UITableView     * tableView;
@property (strong, nonatomic) AYVibrantButton * loginButton;

@end

@implementation BBTLoginViewController

extern NSString * kUserAuthentificationFinishNotifName;

- (void)viewWillAppear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceiveUserAuthenticationNotif)
                                                 name:kUserAuthentificationFinishNotifName
                                               object:nil];
}

- (void)viewDidLoad
{
    self.view.backgroundColor = [UIColor whiteColor];
    self.tableView.scrollEnabled = NO;
    
    //如果appSwitchStatus键不存在，则说明用户第一次使用，那么就默认记录账号密码
    if([JNKeychain loadValueForKey:@"appSwitchStatus"]==nil){
        [JNKeychain saveValue:@1 forKey:@"appSwitchStatus"];
    }
    
    self.logoImageView = ({
        UIImageView *imageView = [UIImageView new];
        imageView.translatesAutoresizingMaskIntoConstraints = NO;
        imageView.clipsToBounds = YES;
        imageView.image = [UIImage imageNamed:@"BoBanTang"];
        imageView;
    });
    
    self.tableView = ({
        UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        tableView.scrollEnabled = NO;
        tableView.dataSource = self;
        tableView.delegate = self;
        tableView;
    });
    
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
    
    [self.view addSubview:self.logoImageView];
    [self.view addSubview:self.tableView];
    
    CGFloat navigationBarHeight = self.navigationController.navigationBar.frame.size.height;
    CGFloat verticalInnerSpacing = 50.0f;
    CGFloat logoImageSideLength = 100.0f;
    CGFloat tableViewHeight = 100.0f;
    CGFloat loginButtonHeight = 50.0f;
    
    [self.logoImageView mas_makeConstraints:^(MASConstraintMaker *make){
        make.top.equalTo(self.view.mas_top).offset(navigationBarHeight + verticalInnerSpacing);
        make.centerX.equalTo(self.view.mas_centerX);
        make.width.equalTo(@(logoImageSideLength));
        make.height.equalTo(@(logoImageSideLength));
    }];
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make){
        make.top.equalTo(self.logoImageView.mas_bottom).offset(verticalInnerSpacing);
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
    
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle:@"取消"
                                                                     style:UIBarButtonItemStylePlain
                                                                    target:self
                                                                    action:@selector(cancelButtonIsTapped)];
    self.navigationItem.leftBarButtonItem = cancelButton;
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
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    NSLog(@"touchesBegan:withEvent:");
    [self.view endEditing:YES];
    [super touchesBegan:touches withEvent:event];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    NSLog(@"textFieldShouldReturn:");
    if (textField.tag == 0) {
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
    
    [BBTCurrentUserManager sharedCurrentUserManager].currentUser.account = currentUserUserName;
    [BBTCurrentUserManager sharedCurrentUserManager].currentUser.password = currenUserPassWord;
    [[BBTCurrentUserManager sharedCurrentUserManager] currentUserAuthentication];
}

- (void)cancelButtonIsTapped
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveUserAuthenticationNotif
{
    if ([BBTCurrentUserManager sharedCurrentUserManager].userIsActive)
    {
        if ([[JNKeychain loadValueForKey:@"appSwitchStatus"] isEqual:@1]){
            //Save User info in keychain
            [[BBTCurrentUserManager sharedCurrentUserManager] saveCurrentUserInfo];
            
        }
        
        //Hide loading hud
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        
        JGProgressHUD *HUD = [JGProgressHUD progressHUDWithStyle:JGProgressHUDStyleDark];
        HUD.textLabel.text = @"登录成功";
        HUD.indicatorView = [[JGProgressHUDSuccessIndicatorView alloc] init];
        HUD.square = YES;
        [HUD showInView:self.view];
        [HUD dismissAfterDelay:2.0];
        
        //Dismiss current VC 0.5 sec after HUD disappears.
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 2.5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            [self dismissViewControllerAnimated:YES completion:nil];
        });
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

- (void)viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end

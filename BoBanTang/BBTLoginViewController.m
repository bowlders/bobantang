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
#import <AYVibrantButton.h>
#import <Masonry.h>

@interface BBTLoginViewController ()

@property (strong, nonatomic) UIImageView     * logoImageView;
@property (strong, nonatomic) UITableView     * tableView;
@property (strong, nonatomic) AYVibrantButton * loginButton;

@end

@implementation BBTLoginViewController

- (void)viewDidLoad
{
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
    self.loginButton = [[AYVibrantButton alloc] initWithFrame:CGRectZero style:AYVibrantButtonStyleInvert];
    self.loginButton.vibrancyEffect = [UIVibrancyEffect effectForBlurEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleExtraLight]];
    self.loginButton.text = @"Invert";
    self.loginButton.font = [UIFont systemFontOfSize:18.0];
    [self.loginButton addTarget:self action:@selector(loginButtonIsTapped) forControlEvents:UIControlEventTouchUpInside];
    [effectView.contentView addSubview:self.loginButton];
    
    [self.view addSubview:self.logoImageView];
    [self.view addSubview:self.tableView];
    [self.view addSubview:self.loginButton];
    
    CGFloat navigationBarHeight = self.navigationController.navigationBar.frame.size.height;
    CGFloat verticalInnerSpacing = 50.0f;
    CGFloat logoImageSideLength = 50.0f;
    CGFloat tableViewHeight = 80.0f;
    CGFloat loginButtonHeight = 30.0f;
    CGFloat loginButtonWidth = 100.0f;
    
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
        make.width.equalTo(@(loginButtonWidth));
        make.centerX.equalTo(self.view.mas_centerX);
    }];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
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
    }
    else if (indexPath.row == 1)
    {
        [cell setCellContentWithLabelText:@"密码" andTextFieldPlaceHolder:@"请填写教务系统的密码"];
        cell.textField.tag = 1;
        cell.textField.secureTextEntry = YES;
    }
    
    cell.textField.delegate = self;

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
        NSString *currentUserUserName = ((UITextField *)((BBTLoginTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]]).textField).text;
        [BBTCurrentUserManager sharedCurrentUserManager].currentUser = [BBTUser new];

        [BBTCurrentUserManager sharedCurrentUserManager].currentUser.password = textField.text;
    }
    return YES;
}

- (void)loginButtonIsTapped
{
    NSString *currentUserUserName = ((UITextField *)((BBTLoginTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]]).textField).text;
    NSString *currenUserPassWord = ((UITextField *)((BBTLoginTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]]).textField).text;
    
    [BBTCurrentUserManager sharedCurrentUserManager].currentUser = [BBTUser new];
    [BBTCurrentUserManager sharedCurrentUserManager].currentUser.account = currentUserUserName;
    [BBTCurrentUserManager sharedCurrentUserManager].currentUser.password = currenUserPassWord;
    [[BBTCurrentUserManager sharedCurrentUserManager] currentUserAuthentication];
}

@end

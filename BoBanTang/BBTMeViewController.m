//
//  BBTMeViewController.m
//  BoBanTang
//
//  Created by Caesar on 16/2/1.
//  Copyright © 2016年 100steps. All rights reserved.
//

#import "BBTMeViewController.h"
#import "UIColor+BBTColor.h"
#import "BBTCurrentUserManager.h"
#import "BBTLoginViewController.h"
#import <Masonry.h>
#import <UIImageView+WebCache.h>

@interface BBTMeViewController ()

@property (strong, nonatomic) UIView      * containerView;

@property (strong, nonatomic) UIButton    * loginButton;
@property (strong, nonatomic) UIImageView * avatarImageView;
@property (strong, nonatomic) UILabel     * nameLabel;
@property (strong, nonatomic) UILabel     * studentNumberLabel;
@property (strong, nonatomic) UITableView * meTableView;

@end

@implementation BBTMeViewController

extern NSString * kUserAuthentificationFinishNotifName;

- (void)viewWillAppear:(BOOL)animated
{
    [self updateView];
}

- (void)viewDidLoad
{
    self.title = @"我";
    self.meTableView.scrollEnabled = NO;
    
    //Lean Cloud Settings
    AVObject *testObject = [AVObject objectWithClassName:@"TestObject"];
    [testObject setObject:@"bar" forKey:@"foo"];
    [testObject save];
    
    CGFloat statusBarHeight = self.navigationController.navigationBar.frame.origin.y;
    CGFloat navigationBarHeight = self.navigationController.navigationBar.frame.size.height;
    CGFloat tabBarHeight = self.tabBarController.tabBar.frame.size.height;
    CGFloat loginButtonHeight = 30.0f;
    CGFloat verticalInnerSpacing = 10.0f;
    CGFloat avatarImageViewRadius = 50.0f;                              //Avatar imageView is circular.
    CGFloat avatarImageCenterYOffSet = 20.0f;
    CGFloat labelHeight = 20.0f;
    CGFloat containerViewHeight = statusBarHeight + navigationBarHeight + verticalInnerSpacing * 6 + avatarImageViewRadius * 2 + labelHeight * 2;
    
    //Initialization
    self.containerView = ({
        UIView *view = [UIView new];
        view.translatesAutoresizingMaskIntoConstraints = NO;
        view.backgroundColor = [UIColor BBTAppGlobalBlue];
        view.alpha = 1.0;
        view;
    });
    
    self.loginButton = ({
        UIButton *button = [UIButton new];
        button.translatesAutoresizingMaskIntoConstraints = NO;
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:@"请登录"];
        [attributedString addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInt:NSUnderlineStyleSingle] range:NSMakeRange(0, [attributedString length])];
        [button setAttributedTitle:attributedString forState:UIControlStateNormal];
        [button addTarget:self action:@selector(loginButtonIsTapped) forControlEvents:UIControlEventTouchUpInside];
        button.titleLabel.numberOfLines = 1;
        button.titleLabel.textAlignment = NSTextAlignmentRight;
        button.titleLabel.adjustsFontSizeToFitWidth = NO;
        button.alpha = 1.0;
        button;
    });
    
    self.avatarImageView = ({
        UIImageView *imageView = [UIImageView new];
        imageView.translatesAutoresizingMaskIntoConstraints = NO;
        imageView.contentMode = UIViewContentModeScaleToFill;
        imageView.alpha = 1.0;
        imageView;
    });
    
    self.nameLabel = ({
        UILabel *label = [UILabel new];
        label.translatesAutoresizingMaskIntoConstraints = NO;
        label.numberOfLines = 1;
        label.textAlignment = NSTextAlignmentCenter;
        label.adjustsFontSizeToFitWidth = NO;
        label.alpha = 1.0;
        label;
    });
    
    self.studentNumberLabel = ({
        UILabel *label = [UILabel new];
        label.translatesAutoresizingMaskIntoConstraints = NO;
        label.numberOfLines = 1;
        label.textAlignment = NSTextAlignmentCenter;
        label.adjustsFontSizeToFitWidth = NO;
        label.alpha = 1.0;
        label;
    });
    
    self.meTableView = ({
        UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        tableView.scrollEnabled = NO;
        tableView.dataSource = self;
        tableView.delegate = self;
        tableView;
    });
    
    //Add to subview
    [self.view addSubview:self.containerView];
    [self.view addSubview:self.meTableView];
    [self.containerView addSubview:self.loginButton];
    [self.containerView addSubview:self.avatarImageView];
    [self.containerView addSubview:self.nameLabel];
    [self.containerView addSubview:self.studentNumberLabel];
    
    //Set up constraints
    [self.containerView mas_makeConstraints:^(MASConstraintMaker *make){
        make.top.equalTo(self.view.mas_top);
        make.centerX.equalTo(self.view.mas_centerX);
        make.height.equalTo(@(containerViewHeight));
        make.width.equalTo(self.view.mas_width);
    }];
    
    [self.avatarImageView mas_makeConstraints:^(MASConstraintMaker *make){
        make.width.equalTo(@(2 * avatarImageViewRadius));
        make.height.equalTo(@(2 * avatarImageViewRadius));
        make.centerX.equalTo(self.containerView.mas_centerX);
        make.centerY.equalTo(self.containerView.mas_centerY).offset(avatarImageCenterYOffSet);
    }];
    self.avatarImageView.layer.cornerRadius = avatarImageViewRadius;    //Create a circular avatar imageView.
    self.avatarImageView.layer.masksToBounds = YES;
    
    [self.loginButton mas_makeConstraints:^(MASConstraintMaker *make){
        make.top.equalTo(self.avatarImageView.mas_bottom).offset(verticalInnerSpacing);
        make.width.equalTo(self.containerView.mas_width);
        make.height.equalTo(@(loginButtonHeight));
        make.centerX.equalTo(self.avatarImageView.mas_centerX);
    }];
    
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make){
        make.top.equalTo(self.avatarImageView.mas_bottom).offset(verticalInnerSpacing);
        make.width.equalTo(self.containerView.mas_width);
        make.height.equalTo(@(labelHeight));
        make.centerX.equalTo(self.avatarImageView.mas_centerX);
    }];
    
    [self.studentNumberLabel mas_makeConstraints:^(MASConstraintMaker *make){
        make.top.equalTo(self.nameLabel.mas_bottom).offset(verticalInnerSpacing);
        make.width.equalTo(self.containerView.mas_width);
        make.height.equalTo(@(labelHeight));
        make.centerX.equalTo(self.nameLabel.mas_centerX);
    }];
    
    [self.meTableView mas_makeConstraints:^(MASConstraintMaker *make){
        make.top.equalTo(self.containerView.mas_bottom);
        make.bottom.equalTo(self.view.mas_bottom).offset(-tabBarHeight);
        make.width.equalTo(self.view.mas_width);
        make.centerX.equalTo(self.studentNumberLabel.mas_centerX);
    }];

}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @" ";
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.01f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *meCellIdentifier = @"meCell";
    
    [self.meTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:meCellIdentifier];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:meCellIdentifier];
    
    if (!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:meCellIdentifier];
    }

    if (indexPath.section == 0)
    {
        if (indexPath.row == 0)
        {
            cell.textLabel.text = @"我的收藏";
        }
        else if (indexPath.row == 1)
        {
            cell.textLabel.text = @"设置";
        }
    }
    else if (indexPath.section == 1)
    {
        if (indexPath.row == 0)
        {
            cell.textLabel.text = @"意见反馈";
        }
        else if (indexPath.row == 1)
        {
            cell.textLabel.text = @"关于";
        }
    }
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
        if (indexPath.row == 0)
        {
            //Log in first
            if ([BBTCurrentUserManager sharedCurrentUserManager].userIsActive)
            {
                [self performSegueWithIdentifier:@"showMyCollections" sender:tableView];
            }
            else
            {
                BBTLoginViewController *loginVC = [[BBTLoginViewController alloc] init];
                UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:loginVC];
                [self presentViewController:navigationController animated:YES completion:nil];
            }
        }
        else if (indexPath.row == 1)
        {
            [self performSegueWithIdentifier:@"showSettings" sender:tableView];
        }
    }
    else if (indexPath.section == 1)
    {
        if (indexPath.row == 0)
        {
            LCUserFeedbackAgent *agent = [LCUserFeedbackAgent sharedInstance];
            /* title 传 nil 表示将第一条消息作为反馈的标题。 contact 也可以传入 nil，由用户来填写联系方式。*/
            [agent showConversations:self title:nil contact:@"pankobe24@vip.qq.com"];
        }
        else if (indexPath.row == 1)
        {
            [self performSegueWithIdentifier:@"showAbout" sender:tableView];
        }
    }
}

- (void)loginButtonIsTapped
{
    BBTLoginViewController *loginVC = [[BBTLoginViewController alloc] init];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:loginVC];
    [self presentViewController:navigationController animated:YES completion:nil];
}

- (void)updateView
{
    if ([BBTCurrentUserManager sharedCurrentUserManager].userIsActive)
    {
        NSLog(@"account - %@",[BBTCurrentUserManager sharedCurrentUserManager].currentUser.account);
        self.loginButton.hidden = YES;
        self.nameLabel.hidden = NO;
        self.studentNumberLabel.hidden = NO;
        self.nameLabel.text = [BBTCurrentUserManager sharedCurrentUserManager].currentUser.userName;
        self.studentNumberLabel.text = [BBTCurrentUserManager sharedCurrentUserManager].currentUser.account;
        NSURL *avatarURL = [NSURL URLWithString:[BBTCurrentUserManager sharedCurrentUserManager].currentUser.userLogo];
        [self.avatarImageView sd_setImageWithURL:avatarURL placeholderImage:[UIImage imageNamed:@"BoBanTang"]];
    }
    else
    {
        NSLog(@"username - %@", [BBTCurrentUserManager sharedCurrentUserManager].currentUser.userName);
        self.loginButton.hidden = NO;
        self.nameLabel.hidden = YES;
        self.studentNumberLabel.hidden = YES;
        self.avatarImageView.image = [UIImage imageNamed:@"BoBanTang"];
    }
}

@end

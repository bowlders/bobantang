//
//  BBTCampusInfoViewController.m
//  BoBanTang
//
//  Created by Caesar on 16/1/24.
//  Copyright © 2016年 100steps. All rights reserved.
//

#import "BBTCampusInfoViewController.h"
#import "BBTCampusInfo.h"
#import "BBTCurrentUserManager.h"
#import "BBTLoginViewController.h"
#import "BBTCollectedCampusInfoManager.h"
#import <Masonry.h>
#import <ShareSDK/ShareSDK.h>
#import <ShareSDKUI/ShareSDK+SSUI.h>
#import <JGProgressHUD.h>

@interface BBTCampusInfoViewController ()

@property (strong, nonatomic) NSURL     * url;
@property (strong, nonatomic) UIWebView * webView;
@property (strong, nonatomic) UIButton  * shareButton;
@property (strong, nonatomic) UIButton  * collectButton;                            //Tag 1 for solid star, 0 for hollow star

@end

@implementation BBTCampusInfoViewController

NSString * campusInfoURLFront = @"http://babel.100steps.net/news/index.php?ID=";
NSString * campusInfoURLEnd = @"&articleType=schoolInformation";

extern NSString * kUserAuthentificationFinishNotifName;
extern NSString * insertNewCollectedInfoSucceedNotifName;
extern NSString * insertNewCollectedInfoFailNotifName;
extern NSString * deleteCollectedInfoSucceedNotifName;
extern NSString * deleteCollectedInfoFailNotifName;
extern NSString * fetchCollectedInfoSucceedNotifName;
extern NSString * fetchCollectedInfoFailNotifName;
extern NSString * checkCurrentUserHasCollectedGivenInfoNotifName;
extern NSString * checkCurrentUserHasNotCollectedGivenInfoNotifName;
extern NSString * checkIfHasCollectedGivenInfoFailNotifName;

- (void)viewWillAppear:(BOOL)animated
{
    [self updateCollectButtonStatus];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self addObserver];
    
    self.webView = ({
        UIWebView *webView = [[UIWebView alloc] initWithFrame:CGRectZero];
        self.webView.scalesPageToFit = YES;
        webView;
    });
    
    self.shareButton = ({
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectZero];
        button.translatesAutoresizingMaskIntoConstraints = NO;
        [button setImage:[UIImage imageNamed:@"share"] forState:UIControlStateNormal];
        [button addTarget:self
                   action:@selector(share)
         forControlEvents:UIControlEventTouchUpInside];
        button.alpha = 1.0;
        button;
    });
    
    self.collectButton = ({
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectZero];
        button.translatesAutoresizingMaskIntoConstraints = NO;
        [button setImage:[UIImage imageNamed:@"hollowStar"] forState:UIControlStateNormal];
        [button addTarget:self
                   action:@selector(collectButtonIsTapped)
         forControlEvents:UIControlEventTouchUpInside];
        button.alpha = 1.0;
        button;
    });
    
    [self.view addSubview:self.webView];
    [self.view addSubview:self.shareButton];
    [self.view addSubview:self.collectButton];
    
    CGFloat tabBarHeight = self.tabBarController.tabBar.frame.size.height;
    CGFloat buttonOffset = 10.0f;
    CGFloat buttonSideLength = 50.0f;
    
    [self.webView mas_makeConstraints:^(MASConstraintMaker *make){
        make.top.equalTo(self.view.mas_top);
        make.bottom.equalTo(self.view.mas_bottom);
        make.left.equalTo(self.view.mas_left);
        make.right.equalTo(self.view.mas_right);
    }];
    
    [self.collectButton mas_makeConstraints:^(MASConstraintMaker *make){
        make.right.equalTo(self.view.mas_right).offset(-buttonOffset);
        make.bottom.equalTo(self.view.mas_bottom).offset(- tabBarHeight - buttonOffset);
        make.width.equalTo(@(buttonSideLength));
        make.height.equalTo(@(buttonSideLength));
    }];
    
    [self.shareButton mas_makeConstraints:^(MASConstraintMaker *make){
        make.right.equalTo(self.collectButton.mas_right);
        make.bottom.equalTo(self.collectButton.mas_top).offset(-buttonOffset);
        make.width.equalTo(self.collectButton.mas_width);
        make.height.equalTo(self.collectButton.mas_height);
    }];
    
    //Create and load request
    NSString *idString = [NSString stringWithFormat:@"%d", self.info.ID];
    NSString *urlString1 = [campusInfoURLFront stringByAppendingString:idString];
    NSString *urlString = [urlString1 stringByAppendingString:campusInfoURLEnd];
    NSString *cleanedUrlString = [urlString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    self.url = [NSURL URLWithString:cleanedUrlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:self.url];
    [self.webView loadRequest:request];
}

- (void)addObserver
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceiveUserAuthenticationFinishNotification)
                                                 name:kUserAuthentificationFinishNotifName
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceiveInsertNewCollectedInfoSucceedNotification)
                                                 name:insertNewCollectedInfoSucceedNotifName
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceiveInsertNewCollectedInfoFailNotification)
                                                 name:insertNewCollectedInfoFailNotifName
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceiveDeleteCollectedInfoSucceedNotification)
                                                 name:deleteCollectedInfoSucceedNotifName
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceiveDeleteCollectedInfoFailNotification)
                                                 name:deleteCollectedInfoFailNotifName
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceiveFetchCollectedInfoSucceedNotification)
                                                 name:fetchCollectedInfoSucceedNotifName
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceiveFetchCollectedInfoFailNotification)
                                                 name:fetchCollectedInfoFailNotifName
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceiveCurrentUserHasCollectedGivenInfoNotification)
                                                 name:checkCurrentUserHasCollectedGivenInfoNotifName
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceiveCurrentUserHasNotCollectedGivenInfoNotification)
                                                 name:checkCurrentUserHasNotCollectedGivenInfoNotifName
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceiveCheckIfHasCollectedGivenInfoFailNotification)
                                                 name:checkIfHasCollectedGivenInfoFailNotifName
                                               object:nil];
}

- (void)share
{
    //1、创建分享参数
    NSMutableDictionary *shareParams = [NSMutableDictionary dictionary];
    [shareParams SSDKEnableUseClientShare];
    [shareParams SSDKSetupShareParamsByText:@""
                                 images:[UIImage imageNamed:@"BoBanTang"]
                                    url:self.url
                                  title:self.info.title
                                   type:SSDKContentTypeAuto];

    //定制邮件的分享内容
    [shareParams SSDKSetupMailParamsByText:self.info.article title:self.info.title images:nil attachments:nil recipients:nil ccRecipients:nil bccRecipients:nil type:SSDKContentTypeAuto];
    
    //2、分享（可以弹出我们的分享菜单和编辑界面）
    SSUIShareActionSheetController *sheet =
    [ShareSDK showShareActionSheet:nil
                         items:nil
                   shareParams:shareParams
           onShareStateChanged:^(SSDKResponseState state, SSDKPlatformType platformType, NSDictionary *userData, SSDKContentEntity *contentEntity, NSError *error, BOOL end) {
               
               if (state == SSDKResponseStateSuccess)
               {
                   if (platformType == SSDKPlatformTypeCopy)
                   {
                       JGProgressHUD *HUD = [JGProgressHUD progressHUDWithStyle:JGProgressHUDStyleDark];
                       HUD.textLabel.text = @"已复制链接到剪贴板";
                       HUD.indicatorView = nil;
                       [HUD showInView:self.view];
                       [HUD dismissAfterDelay:2.0];
                   }
                   else
                   {
                       UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"分享成功"
                                                                           message:nil
                                                                          delegate:nil
                                                                 cancelButtonTitle:@"确定"
                                                                 otherButtonTitles:nil];
                       [alertView show];
                   }
               }
               else if (state == SSDKResponseStateFail)
               {
                   UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"分享失败"
                                                                   message:[NSString stringWithFormat:@"%@",error]
                                                                  delegate:nil
                                                         cancelButtonTitle:@"OK"
                                                         otherButtonTitles:nil, nil];
                   [alertView show];
               }
        }
    ];

    [sheet.directSharePlatforms addObject:@(SSDKPlatformTypeCopy)];
    [sheet.directSharePlatforms addObject:@(SSDKPlatformTypeMail)];
}

- (void)collectButtonIsTapped
{
    if (![BBTCurrentUserManager sharedCurrentUserManager].userIsActive)                                         //User must login first
    {
        BBTLoginViewController *loginVC = [[BBTLoginViewController alloc] init];
        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:loginVC];
        [self presentViewController:navigationController animated:YES completion:nil];
    }
    else                                                                                                        //In this situation, the VC must have received check result(check whether current user has collected this info)
    {
        if (self.collectButton.tag == 0)                                                                        //Current user has not collected this info
        {
            BBTCollectedCampusInfoManager *manager = [[BBTCollectedCampusInfoManager alloc] init];
            [manager currentUserCollectInfoWithArticleID:self.info.ID];
        }
        else                                                                                                    //Current user has collected this info
        {
            BBTCollectedCampusInfoManager *manager = [[BBTCollectedCampusInfoManager alloc] init];
            [manager currentUserCancelCollectInfoWithArticleID:self.info.ID];
        }
    }
}

- (void)didReceiveUserAuthenticationFinishNotification
{
    [self updateCollectButtonStatus];
}

- (void)updateCollectButtonStatus
{
    if ([BBTCurrentUserManager sharedCurrentUserManager].userIsActive)
    {
        self.collectButton.enabled = NO;
        self.collectButton.alpha = 0.9;
        
        BBTCollectedCampusInfoManager *manager = [[BBTCollectedCampusInfoManager alloc] init];
        [manager checkIfCurrentUserHasCollectedArticleWithArticleID:self.info.ID];
    }
}

- (void)didReceiveInsertNewCollectedInfoSucceedNotification
{
    //Show solid star
    self.collectButton.enabled = YES;
    self.collectButton.alpha = 1.0;
    [self.collectButton setImage:[UIImage imageNamed:@"solidStar"] forState:UIControlStateNormal];
    self.collectButton.tag = 1;
}

- (void)didReceiveInsertNewCollectedInfoFailNotification
{
    //Remain hollow star
    self.collectButton.enabled = YES;
    self.collectButton.alpha = 1.0;
    [self.collectButton setImage:[UIImage imageNamed:@"hollowStar"] forState:UIControlStateNormal];
    self.collectButton.tag = 0;
}

- (void)didReceiveDeleteCollectedInfoSucceedNotification
{
    //Show hollow star
    self.collectButton.enabled = YES;
    self.collectButton.alpha = 1.0;
    [self.collectButton setImage:[UIImage imageNamed:@"hollowStar"] forState:UIControlStateNormal];
    self.collectButton.tag = 0;
}

- (void)didReceiveDeleteCollectedInfoFailNotification
{
    //Remain solid star
    self.collectButton.enabled = YES;
    self.collectButton.alpha = 1.0;
    [self.collectButton setImage:[UIImage imageNamed:@"solidStar"] forState:UIControlStateNormal];
    self.collectButton.tag = 1;
}

- (void)didReceiveFetchCollectedInfoSucceedNotification
{

}

- (void)didReceiveFetchCollectedInfoFailNotification
{

}

- (void)didReceiveCurrentUserHasCollectedGivenInfoNotification
{
    //Enable cancel collect
    self.collectButton.enabled = YES;
    self.collectButton.alpha = 1.0;
    [self.collectButton setImage:[UIImage imageNamed:@"solidStar"] forState:UIControlStateNormal];
    self.collectButton.tag = 1;
}

- (void)didReceiveCurrentUserHasNotCollectedGivenInfoNotification
{
    //Enable collect
    self.collectButton.enabled = YES;
    self.collectButton.alpha = 1.0;
    [self.collectButton setImage:[UIImage imageNamed:@"hollowStar"] forState:UIControlStateNormal];
    self.collectButton.tag = 0;
}

- (void)didReceiveCheckIfHasCollectedGivenInfoFailNotification
{
    //Do nothing
}

@end

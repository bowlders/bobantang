//
//  BBTDailyArticleViewController.m
//  BoBanTang
//
//  Created by Caesar on 16/1/24.
//  Copyright © 2016年 100steps. All rights reserved.
//

#import "BBTDailyArticleViewController.h"
#import "BBTDailyArticle.h"
#import "BBTDailyArticleTableViewController.h"
#import "BBTCurrentUserManager.h"
#import "BBTLoginViewController.h"
#import "BBTDailyArticleManager.h"
#import "BBTCollectedDailyArticleManager.h"
#import <Masonry.h>
#import <ShareSDK/ShareSDK.h>
#import <ShareSDKUI/ShareSDK+SSUI.h>
#import <JGProgressHUD.h>
#import <MBProgressHUD.h>

@interface BBTDailyArticleViewController ()

@property (strong, nonatomic) NSURL                    * url;
@property (strong, nonatomic) UIWebView                * webView;
@property (strong, nonatomic) UISwipeGestureRecognizer * recognizer;
@property (strong, nonatomic) UIButton                 * shareButton;
@property (strong, nonatomic) UIButton                 * collectButton;

@end

@implementation BBTDailyArticleViewController

NSString * dailyArticleURLFront = @"http://babel.100steps.net/news/index.php?ID=";
NSString * dailyArticleURLEnd = @"&articleType=dailySoup";

extern NSString * kUserAuthentificationFinishNotifName;
extern NSString * insertNewCollectedArticleSucceedNotifName;
extern NSString * insertNewCollectedArticleFailNotifName;
extern NSString * deleteCollectedArticleSucceedNotifName;
extern NSString * deleteCollectedArticleFailNotifName;
extern NSString * fetchCollectedArticleSucceedNotifName;
extern NSString * fetchCollectedArticleFailNotifName;
extern NSString * checkCurrentUserHasCollectedGivenArticleNotifName;
extern NSString * checkCurrentUserHasNotCollectedGivenArticleNotifName;
extern NSString * checkIfHasCollectedGivenArticleFailNotifName;
extern NSString * getArticleTodaySucceedNotifName;

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
    
    //In order to deal with a autoLayout bug of iOS, an empty UIView must be added before webView.
    UIView *emptyView = [UIView new];
    [self.view addSubview:emptyView];
    [self.view addSubview:self.webView];
    [self.view addSubview:self.shareButton];
    [self.view addSubview:self.collectButton];
    
    CGFloat statusBarHeight = self.navigationController.navigationBar.frame.origin.y;
    CGFloat tabBarHeight = self.tabBarController.tabBar.frame.size.height;
    CGFloat navigationBarHeight = self.navigationController.navigationBar.frame.size.height;
    CGFloat buttonOffset = 10.0f;
    CGFloat buttonSideLength = 50.0f;
    
    [self.webView mas_makeConstraints:^(MASConstraintMaker *make){
        make.top.equalTo(self.view.mas_top).offset(statusBarHeight + navigationBarHeight);
        make.bottom.equalTo(self.view.mas_bottom).offset(-tabBarHeight);
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
    
    [self loadWebView];
    
    self.recognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe)];
    self.recognizer.direction = UISwipeGestureRecognizerDirectionRight;
    self.recognizer.delegate = self;
    [self.view addGestureRecognizer:self.recognizer];
}

- (void)loadWebView
{
    //Create and load request
    NSString *idString = [NSString stringWithFormat:@"%d", self.article.ID];
    NSString *urlString1 = [dailyArticleURLFront stringByAppendingString:idString];
    NSString *urlString = [urlString1 stringByAppendingString:dailyArticleURLEnd];
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
                                             selector:@selector(didReceiveInsertNewCollectedArticleSucceedNotification)
                                                 name:insertNewCollectedArticleSucceedNotifName
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceiveInsertNewCollectedArticleFailNotification)
                                                 name:insertNewCollectedArticleFailNotifName
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceiveDeleteCollectedArticleSucceedNotification)
                                                 name:deleteCollectedArticleSucceedNotifName
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceiveDeleteCollectedArticleFailNotification)
                                                 name:deleteCollectedArticleFailNotifName
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceiveCurrentUserHasCollectedGivenArticleNotification)
                                                 name:checkCurrentUserHasCollectedGivenArticleNotifName
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceiveCurrentUserHasNotCollectedGivenArticleNotification)
                                                 name:checkCurrentUserHasNotCollectedGivenArticleNotifName
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceiveCheckIfHasCollectedGivenArticleFailNotification)
                                                 name:checkIfHasCollectedGivenArticleFailNotifName
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceiveGetArticleTodayNotification)
                                                 name:getArticleTodaySucceedNotifName
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
                                      title:self.article.title
                                       type:SSDKContentTypeAuto];
    
    //定制邮件的分享内容
    [shareParams SSDKSetupMailParamsByText:self.article.article title:self.article.title images:nil attachments:nil recipients:nil ccRecipients:nil bccRecipients:nil type:SSDKContentTypeAuto];
    
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
                       UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"分享失败"
                                                                       message:[NSString stringWithFormat:@"%@",error]
                                                                      delegate:nil
                                                             cancelButtonTitle:@"OK"
                                                             otherButtonTitles:nil, nil];
                       [alert show];
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
        if (self.collectButton.tag == 0)                                                                        //Current user has not collected this article.
        {
            [[BBTCollectedDailyArticleManager sharedCollectedArticleManager] currentUserCollectArticleWithArticleID:self.article.ID];
        }
        else                                                                                                    //Current user has collected this article.
        {
            [[BBTCollectedDailyArticleManager sharedCollectedArticleManager] currentUserCancelCollectArticleWithArticleID:self.article.ID];
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
        
        [[BBTCollectedDailyArticleManager sharedCollectedArticleManager] checkIfCurrentUserHasCollectedArticleWithArticleID:self.article.ID];
    }
}

- (void)didReceiveInsertNewCollectedArticleSucceedNotification
{
    //Show solid star
    self.collectButton.enabled = YES;
    self.collectButton.alpha = 1.0;
    [self.collectButton setImage:[UIImage imageNamed:@"solidStar"] forState:UIControlStateNormal];
    self.collectButton.tag = 1;
    
    //Show success HUD
    MBProgressHUD *successHUD = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    
    //Set the annular determinate mode to show task progress.
    successHUD.mode = MBProgressHUDModeText;
    successHUD.labelText = @"收藏成功!";
    
    //Move to center.
    successHUD.xOffset = 0.0f;
    successHUD.yOffset = 0.0f;
    
    //Hide after 2 seconds.
    [successHUD hide:YES afterDelay:2.0f];
}

- (void)didReceiveInsertNewCollectedArticleFailNotification
{
    //Remain hollow star
    self.collectButton.enabled = YES;
    self.collectButton.alpha = 1.0;
    [self.collectButton setImage:[UIImage imageNamed:@"hollowStar"] forState:UIControlStateNormal];
    self.collectButton.tag = 0;
    
    //Show failure HUD
    MBProgressHUD *failureHUD = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    
    //Set the annular determinate mode to show task progress.
    failureHUD.mode = MBProgressHUDModeText;
    failureHUD.labelText = @"收藏失败";
    
    //Move to center.
    failureHUD.xOffset = 0.0f;
    failureHUD.yOffset = 0.0f;
    
    //Hide after 2 seconds.
    [failureHUD hide:YES afterDelay:2.0f];
}

- (void)didReceiveDeleteCollectedArticleSucceedNotification
{
    //Show hollow star
    self.collectButton.enabled = YES;
    self.collectButton.alpha = 1.0;
    [self.collectButton setImage:[UIImage imageNamed:@"hollowStar"] forState:UIControlStateNormal];
    self.collectButton.tag = 0;
    
    //Show success HUD
    MBProgressHUD *successHUD = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    
    //Set the annular determinate mode to show task progress.
    successHUD.mode = MBProgressHUDModeText;
    successHUD.labelText = @"取消收藏成功!";
    
    //Move to center.
    successHUD.xOffset = 0.0f;
    successHUD.yOffset = 0.0f;
    
    //Hide after 2 seconds.
    [successHUD hide:YES afterDelay:2.0f];
}

- (void)didReceiveDeleteCollectedArticleFailNotification
{
    //Remain solid star
    self.collectButton.enabled = YES;
    self.collectButton.alpha = 1.0;
    [self.collectButton setImage:[UIImage imageNamed:@"solidStar"] forState:UIControlStateNormal];
    self.collectButton.tag = 1;
    
    //Show failure HUD
    MBProgressHUD *failureHUD = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    
    //Set the annular determinate mode to show task progress.
    failureHUD.mode = MBProgressHUDModeText;
    failureHUD.labelText = @"取消收藏失败";
    
    //Move to center.
    failureHUD.xOffset = 0.0f;
    failureHUD.yOffset = 0.0f;
    
    //Hide after 2 seconds.
    [failureHUD hide:YES afterDelay:2.0f];
}

- (void)didReceiveCurrentUserHasCollectedGivenArticleNotification
{
    //Enable cancel collect
    self.collectButton.enabled = YES;
    self.collectButton.alpha = 1.0;
    [self.collectButton setImage:[UIImage imageNamed:@"solidStar"] forState:UIControlStateNormal];
    self.collectButton.tag = 1;
}

- (void)didReceiveCurrentUserHasNotCollectedGivenArticleNotification
{
    //Enable collect
    self.collectButton.enabled = YES;
    self.collectButton.alpha = 1.0;
    [self.collectButton setImage:[UIImage imageNamed:@"hollowStar"] forState:UIControlStateNormal];
    self.collectButton.tag = 0;
}

- (void)didReceiveCheckIfHasCollectedGivenArticleFailNotification
{
    //Do nothing
}

- (void)didReceiveGetArticleTodayNotification
{
    self.article = [[BBTDailyArticleManager sharedArticleManager].articleToday copy];
    [self loadWebView];
}

- (void)handleSwipe
{
    BBTDailyArticleTableViewController *controller = [[BBTDailyArticleTableViewController alloc] init];
    [self.navigationController pushViewController:controller animated:YES];
}

@end

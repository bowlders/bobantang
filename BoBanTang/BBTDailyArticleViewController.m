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
#import <Masonry.h>
#import <ShareSDK/ShareSDK.h>
#import <ShareSDKUI/ShareSDK+SSUI.h>
#import <JGProgressHUD.h>

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

- (void)viewWillAppear:(BOOL)animated
{
    [self updateCollectButtonStatus];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
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
                   action:@selector(collect)
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
    NSString *idString = [NSString stringWithFormat:@"%d", self.article.ID];
    NSString *urlString1 = [dailyArticleURLFront stringByAppendingString:idString];
    NSString *urlString = [urlString1 stringByAppendingString:dailyArticleURLEnd];
    NSString *cleanedUrlString = [urlString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    self.url = [NSURL URLWithString:cleanedUrlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:self.url];
    [self.webView loadRequest:request];
    
    self.recognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe)];
    self.recognizer.direction = UISwipeGestureRecognizerDirectionRight;
    self.recognizer.delegate = self;
    [self.view addGestureRecognizer:self.recognizer];
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

- (void)collect
{
    
}

- (void)updateCollectButtonStatus
{
    
}

- (void)handleSwipe
{
    BBTDailyArticleTableViewController *controller = [[BBTDailyArticleTableViewController alloc] init];
 
    [self.navigationController pushViewController:controller animated:YES];
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

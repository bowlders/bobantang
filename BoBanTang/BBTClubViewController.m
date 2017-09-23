//
//  BBTClubViewController.m
//  波板糖
//
//  Created by Authority on 2017/9/14.
//  Copyright © 2017年 100steps. All rights reserved.
//

#import "BBTClubViewController.h"
#import "BBTCurrentUserManager.h"
#import "BBTClubLoginViewController.h"
#import "BBTUser.h"
#import <MBProgressHUD.h>

@interface BBTClubViewController ()

@end

@implementation BBTClubViewController

- (void)viewWillAppear:(BOOL)animated{
    if (![[BBTCurrentUserManager sharedCurrentUserManager] clubUserIsActive])
    {
        UIAlertController *alertController = [[UIAlertController alloc] init];
        alertController = [UIAlertController
                           alertControllerWithTitle:@"你还没有登录哟"
                           message:@"请先登录"
                           preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction =
        [UIAlertAction actionWithTitle:@"去登录"
                                 style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction * action)
         {
             BBTClubLoginViewController *loginViewController = [[BBTClubLoginViewController alloc] init];
             UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:loginViewController];
             [self presentViewController:navigationController animated:YES completion:nil];
             
         }];
        
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel"
                                                               style:UIAlertActionStyleCancel
                                                             handler:nil];
        
        [alertController addAction:cancelAction];
        [alertController addAction:okAction];
        
        [self presentViewController:alertController animated:YES completion:nil];
    }
    else{
        [self loadWebView];
    }

}
- (void)viewDidLoad {
    [super viewDidLoad];

}

- (void)loadWebView{
    CGFloat width = self.view.frame.size.width;
    CGFloat height = self.view.frame.size.height - 20;

    WKWebView *webView = [[WKWebView alloc] initWithFrame:CGRectMake(0,20,width,height)];
    webView.navigationDelegate = self;
    BBTUser *user = [BBTCurrentUserManager sharedCurrentUserManager].currentUser;
    NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"http://community.100steps.net/#/login/%@/%@",user.account, user.password]];
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    [webView loadRequest:request];
    [self.view addSubview:webView];

}

- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation{
    [MBProgressHUD hideHUDForView:self.view animated:YES];
}

- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error{
    
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    
    //Show HUD
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    
    //Set the annular determinate mode to show task progress.
    hud.mode = MBProgressHUDModeText;
    hud.labelText = @"加载失败";
    
    //Move to center.
    hud.xOffset = 0.0f;
    hud.yOffset = 0.0f;
    
    //Hide after 2 seconds.
    [hud hide:YES afterDelay:2.0f];

}

@end

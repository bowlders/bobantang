//
//  BBTClubViewController.m
//  波板糖
//
//  Created by Authority on 2017/9/14.
//  Copyright © 2017年 100steps. All rights reserved.
//

#import "BBTClubViewController.h"
#import <WebKit/WebKit.h>
#import "BBTCurrentUserManager.h"
#import "BBTLoginViewController.h"

@interface BBTClubViewController ()
@property (weak, nonatomic) WKWebView *ClubWebView;

@end

@implementation BBTClubViewController

- (void)viewWillAppear:(BOOL)animated{
    if (![[BBTCurrentUserManager sharedCurrentUserManager] userIsActive])
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
             BBTLoginViewController *loginViewController = [[BBTLoginViewController alloc] init];
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

}
- (void)viewDidLoad {
    [super viewDidLoad];
    //1.创建WKWebView
    
    CGFloat width = self.view.frame.size.width;
    CGFloat height = self.view.frame.size.height - 20;
    WKWebView *webView = [[WKWebView alloc] initWithFrame:CGRectMake(0,20,width,height)];
    //2.创建URL
    NSURL *URL = [NSURL URLWithString:@"http://community.100steps.net/#/login/person/12345678"];
    //3.创建Request
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    //4.加载Request
    [webView loadRequest:request];
    //5.添加到视图
    self.ClubWebView = webView;
    [self.view addSubview:webView];
}

@end

//
//  BBTActivityPageViewController.m
//  波板糖
//
//  Created by Xu Donghui on 07/11/2016.
//  Copyright © 2016 100steps. All rights reserved.
//

#import "BBTActivityPageViewController.h"

@interface BBTActivityPageViewController ()

@property (strong, nonatomic) IBOutlet UIWebView *webView;


@end

@implementation BBTActivityPageViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //Load request
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:self.activityPageUrl]];
    [self.webView loadRequest:request];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)close:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
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

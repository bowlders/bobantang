//
//  BBTDailyArticleViewController.m
//  BoBanTang
//
//  Created by Caesar on 16/1/24.
//  Copyright © 2016年 100steps. All rights reserved.
//

#import "BBTDailyArticleViewController.h"

@interface BBTDailyArticleViewController ()

@property (strong, nonatomic) IBOutlet UIWebView *webView;

@end

@implementation BBTDailyArticleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UIBarButtonItem * shareButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(share)];

    self.navigationItem.rightBarButtonItem = shareButton;
    //[self.navigationItem setRightBarButtonItem:[NSArray arrayWithObjects:shareButton, collectButton, nil]];
    // Do any additional setup after loading the view.
}

- (void)share
{

}

- (void)collect
{

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

//
//  BBTDailyArticleViewController.m
//  BoBanTang
//
//  Created by Caesar on 16/1/24.
//  Copyright © 2016年 100steps. All rights reserved.
//

#import "BBTDailyArticleViewController.h"

@interface BBTDailyArticleViewController ()

@property (strong, nonatomic) IBOutlet UIWebView       * webView;
@property (strong, nonatomic) UISwipeGestureRecognizer * recognizer;

@end

@implementation BBTDailyArticleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.recognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe)];
    self.recognizer.direction = UISwipeGestureRecognizerDirectionRight;
    self.recognizer.delegate = self;
    [self.view addGestureRecognizer:self.recognizer];
    // Do any additional setup after loading the view.
}

- (void)share
{

}

- (void)collect
{

}

- (void)handleSwipe
{
    [self performSegueWithIdentifier:@"showPreviousArticlesList" sender:nil];
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

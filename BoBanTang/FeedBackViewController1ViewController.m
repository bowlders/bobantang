//
//  FeedBackViewController1ViewController.m
//  BoBanTang
//
//  Created by Caesar on 15/10/17.
//  Copyright © 2015年 BBT. All rights reserved.
//

#import "FeedBackViewController1ViewController.h"

@interface FeedBackViewController1ViewController ()

@end

@implementation FeedBackViewController1ViewController

- (void)viewWillAppear:(BOOL)animated
{
    
 
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    LCUserFeedbackAgent *agent = [LCUserFeedbackAgent sharedInstance];
    /* title 传 nil 表示将第一条消息作为反馈的标题。 contact 也可以传入 nil，由用户来填写联系方式。*/
    [agent showConversations:self title:nil contact:@"goodman@leancloud.cn"];
    
    //self.view.hidden = YES;
    //self.navigationBarStyle = LCUserFeedbackNavigationBarStyleNone;
    //UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:self];

    //[self presentViewController:navigationController animated:YES completion:nil];
    // Do any additional setup after loading the view.
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

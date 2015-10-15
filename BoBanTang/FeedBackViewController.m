//
//  FeedBackViewController.m
//  BoBanTang
//
//  Created by Caesar on 15/10/15.
//  Copyright © 2015年 BBT. All rights reserved.
//

#import "FeedBackViewController.h"

@interface FeedBackViewController ()

@property (strong, nonatomic) IBOutlet UITextView *textView;
@property (strong, nonatomic) IBOutlet UIButton *submitButton;

@end

@implementation FeedBackViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [[UIColor brownColor] colorWithAlphaComponent:0.5f];
    
    SZTextView *textView = [SZTextView new];
    textView.frame = self.textView.frame;
    textView.placeholder = @"请在这里输入您的建议，谢谢您的反馈！";
    textView.placeholderTextColor = [UIColor lightGrayColor];
    textView.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:18.0];
    
    UIVisualEffectView *effectView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleExtraLight]];
    effectView.frame = self.view.bounds;
    [self.view addSubview:effectView];
    
    AYVibrantButton *invertButton = [[AYVibrantButton alloc] initWithFrame:self.submitButton.frame style:AYVibrantButtonStyleInvert];
    invertButton.vibrancyEffect = [UIVibrancyEffect effectForBlurEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleExtraLight]];
    invertButton.text = @"提交反馈";
    invertButton.font = [UIFont systemFontOfSize:18.0];
    self.submitButton = invertButton;

    [effectView.contentView addSubview:textView];
    [effectView.contentView addSubview:self.submitButton];
    
    // Do any additional setup after loading the view.
}

- (IBAction)sendFeedBack
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

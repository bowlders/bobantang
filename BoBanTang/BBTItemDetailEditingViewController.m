//
//  BBTItemDetailViewController.m
//  BoBanTang
//
//  Created by Hsu Tung Hui on 16/1/31.
//  Copyright © 2016年 100steps. All rights reserved.
//

#import "BBTItemDetailEditingViewController.h"
#import "UIColor+BBTColor.h"

@interface BBTItemDetailEditingViewController ()

@property (strong, nonatomic) IBOutlet UIBarButtonItem *doneButton;

@end

@implementation BBTItemDetailEditingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.navigationController.navigationBar setBarTintColor: [UIColor BBTAppGlobalBlue]];
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor],NSForegroundColorAttributeName,nil]];
    self.navigationController.navigationBar.tintColor=[UIColor whiteColor];
    self.navigationItem.title = @"请输入详情";

    [self.itemDetails becomeFirstResponder];
    self.itemDetails.contentInset = UIEdgeInsetsMake(-65.0, 0.0, 0.0, 0.0);
    self.itemDetails.text = self.textToEditing;
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)done:(id)sender
{
    [self.itemDetails resignFirstResponder];
    [self.delegate BBTItemDetail:self didFinishEditingDetails:self.itemDetails.text];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(nonnull NSString *)text
{
    if (textView.text.length > 1 || (text.length > 0 && ![text isEqualToString:@""]))
    {
        self.doneButton.enabled = YES;
    }
    else
    {
        self.doneButton.enabled = NO;
    }
    
    return YES;
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

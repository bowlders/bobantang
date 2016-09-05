//
//  BBTItemDetailViewController.m
//  BoBanTang
//
//  Created by Hsu Tung Hui on 16/1/31.
//  Copyright © 2016年 100steps. All rights reserved.
//

#import "BBTItemDetailEditingViewController.h"
#import "UIColor+BBTColor.h"
#import <Masonry/Masonry.h>

#define MAX_LENGTH 80

@interface BBTItemDetailEditingViewController ()

@property (strong, nonatomic) IBOutlet UIBarButtonItem *doneButton;
@property (strong, nonatomic) IBOutlet UILabel *lengthLabel;
@property (strong, nonatomic) IBOutlet UITextView *itemDetails;

@end

@implementation BBTItemDetailEditingViewController

- (void)viewWillAppear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateLengthLabel)
                                                 name:UITextViewTextDidChangeNotification
                                               object:self.itemDetails];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.navigationController.navigationBar setBarTintColor: [UIColor BBTAppGlobalBlue]];
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor],NSForegroundColorAttributeName,nil]];
    self.navigationController.navigationBar.tintColor=[UIColor whiteColor];
    self.navigationItem.title = @"请输入详情";
    
    self.lengthLabel.text = [NSString stringWithFormat:@"%lu/80", [self.textToEditing length]];
    self.itemDetails.text = self.textToEditing;
    self.itemDetails.delegate = self;
    
    CGFloat statusBarHeight = self.navigationController.navigationBar.frame.origin.y;
    CGFloat navigationBarHeight = self.navigationController.navigationBar.frame.size.height;
    CGFloat innerSpacing = 10.0f;
    CGFloat lenthLabelY = statusBarHeight + navigationBarHeight + 2 * innerSpacing;
    CGFloat labelHeight = 20.0f;
    CGFloat textViewHeight = 200.0f;
    
    [self.lengthLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_top).offset(lenthLabelY);
        make.height.equalTo(@(labelHeight));
        make.left.equalTo(self.view.mas_left).offset(innerSpacing);
        make.right.equalTo(self.view.mas_right).offset(-innerSpacing);
    }];
    
    [self.itemDetails mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.lengthLabel.mas_top).insets(UIEdgeInsetsMake(-100.0, 0.0, 0.0, 0.0));
        make.height.equalTo(@(textViewHeight));
        make.left.equalTo(self.view.mas_left).offset(innerSpacing);
        make.right.equalTo(self.view.mas_right).offset(-innerSpacing);
    }];

    [self.itemDetails becomeFirstResponder];
    
    if (self.itemDetails.text.length == 0 || [self.itemDetails.text isEqualToString:@""]) {
        self.doneButton.enabled = NO;
    } else {
        self.doneButton.enabled = YES;
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)updateLengthLabel
{
    NSString *currentTextViewString = [NSString stringWithFormat:@"%lu/80", [self.itemDetails.text length]];
    self.lengthLabel.text = currentTextViewString;
}

- (IBAction)done:(id)sender
{
    [self.itemDetails resignFirstResponder];
    [self.delegate BBTItemDetail:self didFinishEditingDetails:self.itemDetails.text];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    //Avoid to send an empty string
    unsigned long times = [[text componentsSeparatedByString:@" "] count]-1;  //Count spaces number
    if (text.length == 0 || times == text.length) {
        self.doneButton.enabled = NO;
    } else {
        self.doneButton.enabled = YES;
    }
    
    NSUInteger newLength = (textView.text.length - range.length) + text.length;
    if(newLength <= MAX_LENGTH)
    {
        return YES;
    } else {
        NSUInteger emptySpace = MIN(0, MAX_LENGTH - (textView.text.length - range.length));
        textView.text = [[[textView.text substringToIndex:range.location]
                          stringByAppendingString:[text substringToIndex:emptySpace]]
                         stringByAppendingString:[textView.text substringFromIndex:(range.location + range.length)]];
        return NO;
    }
}

@end

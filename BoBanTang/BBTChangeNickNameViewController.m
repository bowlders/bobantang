//
//  BBTChangeNickNameViewController.m
//  BoBanTang
//
//  Created by Caesar on 16/7/13.
//  Copyright © 2016年 100steps. All rights reserved.
//

#import "BBTChangeNickNameViewController.h"
#import "BBTCurrentUserManager.h"
#import <Masonry.h>

@interface BBTChangeNickNameViewController ()

@property (strong, nonatomic) UILabel     * nickNameLengthLabel;
@property (strong, nonatomic) UITextField * nickNameTextField;

@end

@implementation BBTChangeNickNameViewController

- (void)viewDidLoad
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textDidChange) name:UITextFieldTextDidChangeNotification object:self.nickNameTextField];
 
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.nickNameLengthLabel = ({
        UILabel *label = [UILabel new];
        NSString *currentNickNameLengthText = [NSString stringWithFormat:@"%lu/20", (unsigned long)[[BBTCurrentUserManager sharedCurrentUserManager].currentUser.nickName length]];
        label.text = currentNickNameLengthText;
        label.textAlignment = NSTextAlignmentLeft;
        label;
    });
    
    self.nickNameTextField = ({
        UITextField *textField = [UITextField new];
        textField.placeholder = [BBTCurrentUserManager sharedCurrentUserManager].currentUser.nickName;
        textField.textAlignment = NSTextAlignmentLeft;
        textField.backgroundColor = [UIColor lightGrayColor];
        textField;
    });
    
    [self.view addSubview:self.nickNameLengthLabel];
    [self.view addSubview:self.nickNameTextField];
    
    CGFloat statusBarHeight = self.navigationController.navigationBar.frame.origin.y;
    CGFloat navigationBarHeight = self.navigationController.navigationBar.frame.size.height;
    CGFloat nickNameLengthLabelHeight = 20.0f;
    CGFloat nickNameLabelHeight = 30.0f;
    CGFloat nickNameLabelY = statusBarHeight + navigationBarHeight + 20.0f;
    
    [self.nickNameLengthLabel mas_makeConstraints:^(MASConstraintMaker *make){
        make.top.equalTo(self.view.mas_top).offset(nickNameLabelY);
        make.height.equalTo(@(nickNameLengthLabelHeight));
        make.left.equalTo(self.view.mas_left);
        make.width.equalTo(self.view.mas_width);
    }];
    
    [self.nickNameTextField mas_makeConstraints:^(MASConstraintMaker *make){
        make.top.equalTo(self.nickNameLengthLabel.mas_bottom);
        make.height.equalTo(@(nickNameLabelHeight));
        make.left.equalTo(self.view.mas_left);
        make.width.equalTo(self.view.mas_width);
    }];
    
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle:@"取消"
                                                                     style:UIBarButtonItemStylePlain
                                                                    target:self
                                                                    action:@selector(cancelButtonIsTapped)];
    
    UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithTitle:@"保存"
                                                                   style:UIBarButtonItemStylePlain
                                                                  target:self
                                                                  action:@selector(saveButtonIsTapped)];
    
    self.navigationItem.leftBarButtonItem = cancelButton;
    self.navigationItem.rightBarButtonItem = saveButton;
    
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (textField == self.nickNameTextField)
    {
        NSLog(@"%lu", textField.text.length);
        if (textField.text.length > 20) return NO;
    }
    
    return YES;
}

- (void)textDidChange
{
    NSString *currentNickNameLengthText = [NSString stringWithFormat:@"%lu/20", (unsigned long)[self.nickNameTextField.text length]];
    self.nickNameLengthLabel.text = currentNickNameLengthText;
}

- (void)cancelButtonIsTapped
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)saveButtonIsTapped
{
    [[BBTCurrentUserManager sharedCurrentUserManager] uploadNewNickName:self.nickNameTextField.text];
    //TODO: Receive upload success/failure notification.
}

@end

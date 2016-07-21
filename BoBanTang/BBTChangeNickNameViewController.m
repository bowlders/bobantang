//
//  BBTChangeNickNameViewController.m
//  BoBanTang
//
//  Created by Caesar on 16/7/13.
//  Copyright © 2016年 100steps. All rights reserved.
//

#import "BBTChangeNickNameViewController.h"
#import "BBTCurrentUserManager.h"
#import <MBProgressHUD.h>
#import <Masonry.h>

@interface BBTChangeNickNameViewController ()

@property (strong, nonatomic) UILabel     * nickNameLengthLabel;
@property (strong, nonatomic) UITextField * nickNameTextField;

@end

@implementation BBTChangeNickNameViewController

extern NSString * didUploadNickNameNotifName;
extern NSString * failUploadNickNameNotifName;

- (void)viewDidLoad
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(textDidChange)
                                                 name:UITextFieldTextDidChangeNotification
                                               object:self.nickNameTextField];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceiveUploadNickNameNotification)
                                                 name:didUploadNickNameNotifName
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceiveUploadNickNameFailNotification)
                                                 name:failUploadNickNameNotifName
                                               object:nil];
 
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
        textField.text = [BBTCurrentUserManager sharedCurrentUserManager].currentUser.nickName;
        textField.textAlignment = NSTextAlignmentLeft;
        textField.backgroundColor = [UIColor lightGrayColor];
        textField.delegate = self;
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
    //Prevent crashing undo bug.
    if(range.length + range.location > textField.text.length)
    {
        return NO;
    }
    
    NSUInteger newLength = [textField.text length] + [string length] - range.length;
    //Set a maximum length of 20.
    return newLength <= 20;
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
}

- (void)didReceiveUploadNickNameNotification
{
    //Show success HUD
    MBProgressHUD *successHUD = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    
    //Set the annular determinate mode to show task progress.
    successHUD.mode = MBProgressHUDModeText;
    successHUD.labelText = @"昵称修改成功!";
    
    //Move to center.
    successHUD.xOffset = 0.0f;
    successHUD.yOffset = 0.0f;
    
    //Hide after 2 seconds.
    [successHUD hide:YES afterDelay:2.0f];
    
    //Dismiss current VC 0.5 sec after HUD disappears.
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 2.5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [self dismissViewControllerAnimated:YES completion:nil];
    });
}

- (void)didReceiveUploadNickNameFailNotification
{
    //Show failure HUD
    MBProgressHUD *failureHUD = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    
    //Set the annular determinate mode to show task progress.
    failureHUD.mode = MBProgressHUDModeText;
    failureHUD.labelText = @"昵称修改失败";
    
    //Move to center.
    failureHUD.xOffset = 0.0f;
    failureHUD.yOffset = 0.0f;
    
    //Hide after 2 seconds.
    [failureHUD hide:YES afterDelay:2.0f];
}

@end

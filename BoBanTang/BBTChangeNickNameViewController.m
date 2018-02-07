//
//  BBTChangeNickNameViewController.m
//  BoBanTang
//
//  Created by Caesar on 16/7/13.
//  Copyright © 2016年 100steps. All rights reserved.
//

#import "BBTChangeNickNameViewController.h"
#import "BBTCurrentUserManager.h"
#import "UIColor+BBTColor.h"
#import <MBProgressHUD.h>
#import <Masonry.h>

@interface BBTChangeNickNameViewController ()

@property (strong, nonatomic) UILabel     * nickNameLengthLabel;
@property (strong, nonatomic) UITextField * nickNameTextField;
@property (strong, nonatomic) UIView      * blueLineView;

@end

@implementation BBTChangeNickNameViewController

//extern NSString * didUploadNickNameNotifName;
//extern NSString * failUploadNickNameNotifName;
extern NSString * finishUpdateCurrentUserInformationName;

- (void)viewWillAppear:(BOOL)animated
{
    [self addObserver];
}

- (void)viewDidLoad
{
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.nickNameLengthLabel = ({
        UILabel *label = [UILabel new];
        NSString *currentNickNameLengthText = [NSString stringWithFormat:@"%lu/20", (unsigned long)[[BBTCurrentUserManager sharedCurrentUserManager].currentUser.nick length]];
        label.text = currentNickNameLengthText;
        label.textAlignment = NSTextAlignmentLeft;
        label;
    });
    
    self.nickNameTextField = ({
        UITextField *textField = [UITextField new];
        textField.text = [BBTCurrentUserManager sharedCurrentUserManager].currentUser.nick;
        textField.textAlignment = NSTextAlignmentLeft;
        //textField.backgroundColor = [UIColor lightGrayColor];
        textField.delegate = self;
        textField;
    });
    
    self.blueLineView = ({
        UIView *view = [UIView new];
        view.backgroundColor = [UIColor BBTAppGlobalBlue];
        view;
    });
    
    [self.view addSubview:self.nickNameLengthLabel];
    [self.view addSubview:self.nickNameTextField];
    [self.view addSubview:self.blueLineView];
    
    CGFloat statusBarHeight = self.navigationController.navigationBar.frame.origin.y;
    CGFloat navigationBarHeight = self.navigationController.navigationBar.frame.size.height;
    CGFloat nickNameLengthLabelHeight = 20.0f;
    CGFloat nickNameLabelHeight = 30.0f;
    CGFloat nickNameLabelY = statusBarHeight + navigationBarHeight + 20.0f;
    CGFloat nickNameLengthLabelUpperOffset = 20.0f;
    CGFloat innerOffset = 5.0f;
    CGFloat leftOffset = 10.0f;
    CGFloat rightOffset = 10.0f;
    
    [self.nickNameLengthLabel mas_makeConstraints:^(MASConstraintMaker *make){
        make.top.equalTo(self.view.mas_top).offset(nickNameLabelY+nickNameLengthLabelUpperOffset);
        make.height.equalTo(@(nickNameLengthLabelHeight));
        make.left.equalTo(self.view.mas_left).offset(leftOffset);
        make.right.equalTo(self.view.mas_right).offset(-rightOffset);
        //make.width.equalTo(self.view.mas_width);
    }];
    
    [self.nickNameTextField mas_makeConstraints:^(MASConstraintMaker *make){
        make.top.equalTo(self.nickNameLengthLabel.mas_bottom).offset(innerOffset);
        make.height.equalTo(@(nickNameLabelHeight));
        make.left.equalTo(self.nickNameLengthLabel.mas_left);
        make.width.equalTo(self.nickNameLengthLabel.mas_width);
    }];
    
    [self.blueLineView mas_makeConstraints:^(MASConstraintMaker *make){
        make.top.equalTo(self.nickNameTextField.mas_bottom);
        make.left.equalTo(self.nickNameTextField.mas_left);
        make.width.equalTo(self.nickNameTextField.mas_width);
        make.height.equalTo(@(2));
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

- (void)addObserver
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(textDidChange)
                                                 name:UITextFieldTextDidChangeNotification
                                               object:self.nickNameTextField];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(finishUpdateCurrentUserNickName:)
                                                 name:finishUpdateCurrentUserInformationName
                                               object:nil];
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
    //检查是否修改nickName
    if ([self.nickNameTextField.text isEqual:[BBTCurrentUserManager sharedCurrentUserManager].currentUser.nick]){
        //没有修改
        [self didReceiveUploadNickNameNotification];
        
    }else{
        [[BBTCurrentUserManager sharedCurrentUserManager] updateUserInformationThroughPathMethodWith:@{@"nick":self.nickNameTextField.text}];
    }
}
- (void)finishUpdateCurrentUserNickName:(NSNotification *)notification{
    BOOL isError = [notification.userInfo[@"status"] isEqual:@"fail"];
    if (!isError){
        [self didReceiveUploadNickNameNotification];
    }else{
        [self didReceiveUploadNickNameFailNotification];
    }
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

- (void)viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end

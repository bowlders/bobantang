//
//  BBTPostInfoViewController.m
//  BoBanTang
//
//  Created by Hsu Tung Hui on 16/2/9.
//  Copyright © 2016年 100steps. All rights reserved.
//

#import "BBTPostInfoViewController.h"
#import "BBTCurrentUserManager.h"
#import "BBTItemCampusTableViewCell.h"
#import "BBTItemImageTableViewCell.h"
#import "BBTTextFieldTableViewCell.h"
#import "UIColor+BBTColor.h"
#import "ActionSheetPicker.h"
#import <Masonry.h>
#import <AYVibrantButton.h>
#import <MBProgressHUD.h>
#import <JGProgressHUD.h>
#import "BBTLAF.h"
#import "BBTLAFManager.h"
#import "BBTImageUploadManager.h"

static NSString * campusCellIdentifier = @"BBTItemCampusTableViewCell";
static NSString * imageCellIdentifier = @"BBTItemImageTableViewCell";
static NSString * textFieldCellIdentifier = @"BBTTextFieldTableViewCell";
static NSString * dateCellIdentifier = @"dateCell";
static NSString * rightDisclosureCellIdentifier = @"itemRightDisclosureCell";
static NSString * itemDetailIdentifier = @"itemDetailIdentifier";
static NSString * detailsInitial = @"请输入详情";

@interface BBTPostInfoViewController ()

@property (strong, nonatomic) UITableView         * tableView;
@property (strong, nonatomic) NSString            * itemDetails;
@property (strong, nonatomic) NSString            * account;
@property (strong, nonatomic) UIImage             * lostItemImage;
@property (strong, nonatomic) NSMutableDictionary * itemInfoToPost;

@property (strong, nonatomic) BBTLAF              * item;

@property (strong, nonatomic) AYVibrantButton     * postButton;
@property (strong, nonatomic) AYVibrantButton     * resetButton;

@end

@implementation BBTPostInfoViewController

extern NSString *kDidUploadImageNotificationName;
extern NSString *kFailUploadImageNotificationName;
extern NSString *kDidPostItemNotificaionName;
extern NSString *kFailPostItemNotificaionName;

- (void)viewDidLoad
{
    
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor],NSForegroundColorAttributeName,nil]];
    self.navigationController.navigationBar.tintColor=[UIColor whiteColor];
    if ([self.lostOrFound integerValue] == 0) {
        self.navigationItem.title = @"发布招领启事";
    } else {
        self.navigationItem.title = @"发布失物启示";
    }
    
    self.account = [BBTCurrentUserManager sharedCurrentUserManager].currentUser.account;
    //self.account = (@201430202488);
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:tap];
    [tap setCancelsTouchesInView:NO];
    
    self.itemDetails = detailsInitial;
    
    //Set tableview
    self.tableView = ({
        UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        tableView.dataSource = self;
        tableView.delegate = self;
        tableView.translatesAutoresizingMaskIntoConstraints = NO;
        tableView;
    });
    
    [self.tableView registerNib:[UINib nibWithNibName:campusCellIdentifier bundle:nil] forCellReuseIdentifier:campusCellIdentifier];
    [self.tableView registerNib:[UINib nibWithNibName:imageCellIdentifier bundle:nil] forCellReuseIdentifier:imageCellIdentifier];
    [self.tableView registerNib:[UINib nibWithNibName:textFieldCellIdentifier bundle:nil] forCellReuseIdentifier:textFieldCellIdentifier];
    
    self.item = [[BBTLAF alloc] init];
    
    //Set buttons
    UIVisualEffectView *effectView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleExtraLight]];
    effectView.frame = self.view.bounds;
    [self.view addSubview:effectView];
    
    self.postButton = [[AYVibrantButton alloc] initWithFrame:CGRectZero style:AYVibrantButtonStyleFill];
    self.postButton.vibrancyEffect = nil;
    self.postButton.text = @"发布";
    self.postButton.font = [UIFont systemFontOfSize:18.0];
    self.postButton.backgroundColor = [UIColor BBTAppGlobalBlue];
    self.postButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.postButton addTarget:self action:@selector(postButtonIsTapped) forControlEvents:UIControlEventTouchUpInside];
    
    self.resetButton = [[AYVibrantButton alloc] initWithFrame:CGRectZero style:AYVibrantButtonStyleFill];
    self.resetButton.vibrancyEffect = nil;
    self.resetButton.text = @"重置";
    self.resetButton.font = [UIFont systemFontOfSize:18.0];
    self.resetButton.backgroundColor = [UIColor BBTAppGlobalBlue];
    self.resetButton.translatesAutoresizingMaskIntoConstraints = NO;
    
    [effectView.contentView addSubview:self.postButton];
    [effectView.contentView addSubview:self.resetButton];
    [effectView.contentView addSubview:self.tableView];
    
    //Set up constraints
    CGFloat innerSpacing = 10.0f;
    CGFloat buttonHeight = 50.0f;
    CGFloat navigationBarHeight = self.navigationController.navigationBar.frame.size.height;
    CGFloat buttonPosition = self.view.frame.size.width/4;
    CGFloat buttonWidth = self.view.frame.size.width/2 - 2 * innerSpacing;
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_top).offset(navigationBarHeight + 20);
        make.bottom.equalTo(self.view.mas_bottom).offset(- 2 * innerSpacing - buttonHeight);
        make.centerX.equalTo(self.view.mas_centerX);
        make.width.equalTo(self.view.mas_width);
    }];
    
    [self.postButton mas_makeConstraints:^(MASConstraintMaker *make){
        make.bottom.equalTo(self.view.mas_bottom).offset(- innerSpacing);
        make.height.equalTo(@(buttonHeight));
        make.centerX.equalTo(@(buttonPosition));
        make.left.equalTo(self.view).offset(innerSpacing);
        make.right.equalTo(self.resetButton).offset(- buttonWidth - 2 * innerSpacing);
    }];
    
    [self.resetButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.view.mas_bottom).offset(- innerSpacing);
        make.height.equalTo(@(buttonHeight));
        make.right.equalTo(self.view).offset(- innerSpacing);
        make.centerX.equalTo(@(buttonPosition * 3));
        make.width.equalTo(@(buttonWidth));
    }];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    //Keyboard Notifications
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    //Upload Notifications
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didUploadImage) name:kDidUploadImageNotificationName object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(failUploading) name:kFailUploadImageNotificationName object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didPostItem) name:kDidPostItemNotificaionName object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(failUploading) name:kFailPostItemNotificaionName object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma -mark handle keyboard
- (void)dismissKeyboard
{
    BBTTextFieldTableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]];
    [cell dismissKeyboard];
    for (NSInteger i = 0; i < 3; i++)
    {
        BBTTextFieldTableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:2]];
        [cell dismissKeyboard];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    BBTTextFieldTableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]];
    [cell dismissKeyboard];
    for (NSInteger i = 0; i < 3; i++)
    {
        BBTTextFieldTableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:2]];
        [cell dismissKeyboard];
    }
    return YES;
}

- (void)keyboardWillShow:(NSNotification *)sender
{
    CGFloat height = [[sender.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size.height;
    NSTimeInterval duration = [[sender.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    UIViewAnimationOptions curveOption = [[sender.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] unsignedIntegerValue] << 16;
    
    [UIView animateWithDuration:duration
                          delay:0
                        options:UIViewAnimationOptionBeginFromCurrentState|curveOption
                     animations:^{
        UIEdgeInsets edgeInsets = UIEdgeInsetsMake(0, 0, height, 0);
        self.tableView.contentInset = edgeInsets;
        self.tableView.scrollIndicatorInsets = edgeInsets;
    }
                     completion:nil];
}

- (void)keyboardWillHide:(NSNotification *)sender
{
    NSTimeInterval duration = [[sender.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    UIViewAnimationOptions curveOption = [[sender.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] unsignedIntegerValue] << 16;
    
    [UIView animateWithDuration:duration delay:0
                        options:UIViewAnimationOptionBeginFromCurrentState|curveOption
                     animations:^{
        UIEdgeInsets edgeInsets = UIEdgeInsetsZero;
        self.tableView.contentInset = edgeInsets;
        self.tableView.scrollIndicatorInsets = edgeInsets;
    }
                     completion:nil];
}

#pragma -mark get upload notifications
- (void)didUploadImage
{
    [self.itemInfoToPost setObject:([BBTImageUploadManager sharedUploadManager].originalImageUrl) forKey:@"originalPicture"];
    [self.itemInfoToPost setObject:([BBTImageUploadManager sharedUploadManager].thumbnailUrl) forKey:@"thumbnail"];
    
    [[BBTLAFManager sharedLAFManager] postItemDic:self.itemInfoToPost WithType:[self.lostOrFound integerValue]];
}

- (void)didPostItem
{
    [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
    JGProgressHUD *HUD = [JGProgressHUD progressHUDWithStyle:JGProgressHUDStyleDark];
    HUD.interactionType = 0;
    HUD.textLabel.text = @"发布成功";
    HUD.indicatorView = [[JGProgressHUDSuccessIndicatorView alloc] init];
    HUD.square = YES;
    [HUD showInView:self.navigationController.view];
    [HUD dismissAfterDelay:2.0 animated:YES];
    [self.view setUserInteractionEnabled:YES];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)failUploading
{
    [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
    [self.view setUserInteractionEnabled:YES];
    UIAlertController *alertController = [[UIAlertController alloc] init];
    alertController = [UIAlertController alertControllerWithTitle:@"上传失败" message:@"可能是网络不好，请稍后再试" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleDefault handler:nil];
    [alertController addAction:okAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 3;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @" ";
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.01f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1 && indexPath.row == 1) {
        return 100.0f;
    } else {
        return 44.0f;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 10.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:dateCellIdentifier];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:rightDisclosureCellIdentifier];
    
    if (indexPath.section == 0)
    {
        if (indexPath.row == 0)
        {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:dateCellIdentifier];
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:dateCellIdentifier];
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"YYYY-MM-dd"];
            
            self.item.date = [dateFormatter stringFromDate:[NSDate date]];
            
            cell.textLabel.font = [UIFont systemFontOfSize:16];
            cell.textLabel.text = @"日期";
            cell.detailTextLabel.text = [dateFormatter stringFromDate:[NSDate date]];

            return cell;
        }
        else if (indexPath.row == 1)
        {
            BBTItemCampusTableViewCell *cell = (BBTItemCampusTableViewCell *)[tableView dequeueReusableCellWithIdentifier:campusCellIdentifier];
            return cell;
        }
        else if (indexPath.row == 2)
        {
            BBTTextFieldTableViewCell *cell = (BBTTextFieldTableViewCell *)[tableView dequeueReusableCellWithIdentifier:textFieldCellIdentifier];
            [cell configureCellForDifferntUse:0];
            cell.contents.delegate = self;
            return  cell;
        }
    }
    else if (indexPath.section == 1)
    {
        if (indexPath.row == 0)
        {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:rightDisclosureCellIdentifier];
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:rightDisclosureCellIdentifier];
            self.item.type = @(0);
            cell.textLabel.text = @"失物类型";
            cell.textLabel.font = [UIFont systemFontOfSize:16];
            cell.detailTextLabel.text = @"大学城一卡通";
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            return cell;
        }
        else if (indexPath.row == 1)
        {
            BBTItemImageTableViewCell *cell = (BBTItemImageTableViewCell *)[tableView dequeueReusableCellWithIdentifier:imageCellIdentifier];
            
            return cell;
        }
        else if (indexPath.row == 2)
        {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:rightDisclosureCellIdentifier];
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:rightDisclosureCellIdentifier];
            cell.textLabel.text = @"失物详情";
            cell.detailTextLabel.text = detailsInitial;
            cell.textLabel.font = [UIFont systemFontOfSize:16];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            return cell;
        }
    }
    else if (indexPath.section == 2)
    {
        if (indexPath.row == 0)
        {
            BBTTextFieldTableViewCell *cell = (BBTTextFieldTableViewCell *)[tableView dequeueReusableCellWithIdentifier:textFieldCellIdentifier];
            [cell configureCellForDifferntUse:1];
            cell.contents.delegate = self;
            return cell;
        }
        else if (indexPath.row == 1)
        {
            BBTTextFieldTableViewCell *cell = (BBTTextFieldTableViewCell *)[tableView dequeueReusableCellWithIdentifier:textFieldCellIdentifier];
            [cell configureCellForDifferntUse:2];
            cell.contents.delegate = self;
            cell.contents.keyboardType = UIKeyboardTypeNumberPad;
            return cell;
        }
        else if (indexPath.row == 2)
        {
            BBTTextFieldTableViewCell *cell = (BBTTextFieldTableViewCell *)[tableView dequeueReusableCellWithIdentifier:textFieldCellIdentifier];
            [cell configureCellForDifferntUse:3];
            cell.contents.delegate = self;
            return cell;
        }
    }
    return 0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0 && indexPath.row == 0)
    {
        AbstractActionSheetPicker *datePicker;
        
        NSCalendar *calendar = [NSCalendar currentCalendar];
        NSDateComponents *minimumDateComponents = [calendar components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:[NSDate date]];
        [minimumDateComponents setYear:2000];
        NSDate *minDate = [calendar dateFromComponents:minimumDateComponents];
        
        datePicker = [[ActionSheetDatePicker alloc] initWithTitle:@""
                                                   datePickerMode:UIDatePickerModeDate
                                                     selectedDate:[NSDate date]
                                                      minimumDate:minDate
                                                      maximumDate:[NSDate date]
                                                           target:self
                                                           action:@selector(dateWasSelected:element:)
                                                           origin:[tableView cellForRowAtIndexPath:indexPath].detailTextLabel];
        [datePicker showActionSheetPicker];

    } else if (indexPath.section == 1 && indexPath.row == 0) {
        NSArray *itemTypes = [NSArray arrayWithObjects:@"大学城一卡通", @"校园卡(绿卡)", @"钱包", @"钥匙", @"其它", nil];
        [ActionSheetStringPicker showPickerWithTitle:@"请选择类型"
                                                rows:itemTypes
                                    initialSelection:0
                                           doneBlock:^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
                                               [tableView cellForRowAtIndexPath:indexPath].detailTextLabel.text = itemTypes[selectedIndex];
                                               self.item.type = @(selectedIndex);
                                           }
                                         cancelBlock:^(ActionSheetStringPicker *picker) {
                                             
                                         }
                                              origin:[tableView cellForRowAtIndexPath:indexPath].detailTextLabel
         ];

    } else if (indexPath.section == 1 && indexPath.row == 1) {
        
        UIImagePickerController *pickerContoller = [[UIImagePickerController alloc] init];
        pickerContoller.modalPresentationStyle = UIModalPresentationCurrentContext;
        pickerContoller.delegate = self;
        pickerContoller.allowsEditing = YES;
        
        UIAlertController *pickerView = [UIAlertController alertControllerWithTitle:@"Select a photo"
                                                                            message:nil
                                                                     preferredStyle:UIAlertControllerStyleActionSheet];
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel"
                                                         style:UIAlertActionStyleCancel
                                                       handler:^(UIAlertAction *action){
                                                           [pickerView dismissViewControllerAnimated:YES completion:nil];
                                                       }];
        UIAlertAction *useCamera = [UIAlertAction actionWithTitle:@"拍照"
                                                            style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction *action){
                                                              pickerContoller.sourceType = UIImagePickerControllerSourceTypeCamera;
                                                              pickerContoller.cameraCaptureMode = UIImagePickerControllerCameraCaptureModePhoto;
                                                              [self presentViewController:pickerContoller animated:YES completion:nil];
                                                          }];
        UIAlertAction *chooseFromGallery = [UIAlertAction actionWithTitle:@"从相册选取"
                                                                    style:UIAlertActionStyleDefault
                                                                  handler:^(UIAlertAction *action){
                                                                      pickerContoller.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                                                                      [self presentViewController:pickerContoller animated:YES completion:nil];
                                                                  }];
        
        [pickerView addAction:useCamera];
        [pickerView addAction:chooseFromGallery];
        [pickerView addAction:cancel];
        [self presentViewController:pickerView animated:YES completion:nil];
    } else if (indexPath.section == 1 && indexPath.row == 2) {
        [self performSegueWithIdentifier:itemDetailIdentifier sender:self.itemDetails];
    }

}

- (void)dateWasSelected:(NSDate *)selectedDate element:(id)element
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"YYYY-MM-dd"];
    [element setText:[dateFormatter stringFromDate:selectedDate]];
}

- (void)BBTItemDetail:(BBTItemDetailEditingViewController *)controller didFinishEditingDetails:(NSString *)itemDetails
{
    self.itemDetails = itemDetails;
    if ([itemDetails length] < 10) {
        [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:1]].detailTextLabel.text = itemDetails;
    } else {
        [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:1]].detailTextLabel.text = [[itemDetails substringToIndex:10] stringByAppendingString:@"..."];
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)postButtonIsTapped
{
    UITableViewCell *dateCell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    self.item.date = dateCell.detailTextLabel.text;
    
    BBTItemCampusTableViewCell *campusCell = (BBTItemCampusTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
    self.item.campus = @(campusCell.campus.selectedSegmentIndex);
    
    BBTTextFieldTableViewCell *locationCell = (BBTTextFieldTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]];
    self.item.location = locationCell.contents.text;
    
    self.item.details = self.itemDetails;
    
    BBTTextFieldTableViewCell *publisherCell = (BBTTextFieldTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:2]];
    self.item.publisher = publisherCell.contents.text;
    
    BBTTextFieldTableViewCell *phoneCell = (BBTTextFieldTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:2]];
    self.item.phone = phoneCell.contents.text;
    
    BBTTextFieldTableViewCell *otherContactCell = (BBTTextFieldTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:2]];
    self.item.otherContact = otherContactCell.contents.text;
    
    if ([self.item.location isEqualToString:@""] || [self.item.publisher isEqualToString:@""] || [self.item.phone isEqualToString:@""])
    {
        UIAlertController *alertController = [[UIAlertController alloc] init];
        alertController = [UIAlertController alertControllerWithTitle:@"信息不全" message:@"请补全补填信息" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleDefault handler:nil];
        [alertController addAction:okAction];
        [self presentViewController:alertController animated:YES completion:nil];
        return;
    }
    
    self.itemInfoToPost = [[NSMutableDictionary alloc] init];
    [self.itemInfoToPost setObject:self.item.date forKey:@"date"];
    [self.itemInfoToPost setObject:self.item.campus forKey:@"campus"];
    [self.itemInfoToPost setObject:self.item.location forKey:@"location"];
    [self.itemInfoToPost setObject:self.item.type forKey:@"type"];
    [self.itemInfoToPost setObject:self.item.publisher forKey:@"publisher"];
    [self.itemInfoToPost setObject:self.item.phone forKey:@"phone"];
    [self.itemInfoToPost setObject:self.account forKey:@"account"];
    
    if (![self.item.details isEqualToString:detailsInitial])[self.itemInfoToPost setObject:self.item.details forKey:@"details"];
    if (![self.item.otherContact isEqualToString:@""] && !self.item.otherContact)[self.itemInfoToPost setObject:self.item.otherContact forKey:@"otherContact"];
    
    //Show a HUD
    [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    [self.view setUserInteractionEnabled:NO];
    
    if (!self.lostItemImage) {
        [[BBTLAFManager sharedLAFManager] postItemDic:self.itemInfoToPost WithType:[self.lostOrFound integerValue]];
    } else {
        [[BBTImageUploadManager sharedUploadManager] uploadImageToQiniu:self.lostItemImage];
    }
}

#pragma mark - UIImagePickerController Delegate Methods
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [self dismissViewControllerAnimated:YES completion:NULL];
    
    self.lostItemImage = [info valueForKey:UIImagePickerControllerEditedImage];
    BBTItemImageTableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:1]];
    [cell configureCellWithImage:self.lostItemImage];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:itemDetailIdentifier]) {
        UINavigationController *navigationController = segue.destinationViewController;
        BBTItemDetailEditingViewController *controller = (BBTItemDetailEditingViewController *)navigationController.topViewController;
        controller.title = sender;
        controller.delegate = self;
        if (![sender isEqualToString:detailsInitial]) {
            controller.textToEditing = [[NSString alloc] initWithString:sender];
        }
    }
}

@end

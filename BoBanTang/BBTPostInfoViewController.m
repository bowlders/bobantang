//
//  BBTPostInfoViewController.m
//  BoBanTang
//
//  Created by Hsu Tung Hui on 16/2/9.
//  Copyright © 2016年 100steps. All rights reserved.
//

#import "BBTPostInfoViewController.h"
#import "BBTItemCampusTableViewCell.h"
#import "BBTItemImageTableViewCell.h"
#import "BBTTextFieldTableViewCell.h"
#import "UIColor+BBTColor.h"
#import "ActionSheetPicker.h"
#import <Masonry.h>
#import <AYVibrantButton.h>
#import "BBTLAF.h"
#import "BBTLAFManager.h"
#import "BBTCurrentUserManager.h"

static NSString * campusCellIdentifier = @"BBTItemCampusTableViewCell";
static NSString * imageCellIdentifier = @"BBTItemImageTableViewCell";
static NSString * textFieldCellIdentifier = @"BBTTextFieldTableViewCell";
static NSString * dateCellIdentifier = @"dateCell";
static NSString * rightDisclosureCellIdentifier = @"itemRightDisclosureCell";
static NSString *itemDetailIdentifier = @"itemDetailIdentifier";

@interface BBTPostInfoViewController ()

@property (strong, nonatomic) UITableView     * tableView;
@property (strong, nonatomic) NSString        * itemDetails;
@property (strong, nonatomic) AYVibrantButton * postButton;
@property (strong, nonatomic) AYVibrantButton * resetButton;
@property (strong, nonatomic) BBTLAF          * item;

@end

@implementation BBTPostInfoViewController

- (void)viewDidLoad
{
    
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor],NSForegroundColorAttributeName,nil]];
    self.navigationController.navigationBar.tintColor=[UIColor whiteColor];
    if ([self.lostOrFound longValue] == 0) {
        self.navigationItem.title = @"发布招领启事";
    } else {
        self.navigationItem.title = @"发布寻物启事";
    }
    
    self.item = [[BBTLAF alloc] init];
    self.item.type = [NSNumber numberWithInteger:0];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:tap];
    [tap setCancelsTouchesInView:NO];
    
    self.itemDetails = @"请输入详情";

    self.tableView = ({
        UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        tableView.dataSource = self;
        tableView.delegate = self;
        tableView.translatesAutoresizingMaskIntoConstraints = NO;
        [tableView reloadData];
        tableView;
    });
    
    [self.tableView registerNib:[UINib nibWithNibName:campusCellIdentifier bundle:nil] forCellReuseIdentifier:campusCellIdentifier];
    [self.tableView registerNib:[UINib nibWithNibName:imageCellIdentifier bundle:nil] forCellReuseIdentifier:imageCellIdentifier];
    [self.tableView registerNib:[UINib nibWithNibName:textFieldCellIdentifier bundle:nil] forCellReuseIdentifier:textFieldCellIdentifier];
    
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
    self.postButton.translatesAutoresizingMaskIntoConstraints = NO;
    
    [effectView.contentView addSubview:self.postButton];
    [effectView.contentView addSubview:self.resetButton];
    [self.view addSubview:self.tableView];
    
    //Set up constraints
    CGFloat innerSpacing = 10.0f;
    CGFloat buttonHeight = 40.0f;
    CGFloat navigationBarHeight = self.navigationController.navigationBar.frame.size.height;
    CGFloat buttonCenterXPosition = self.view.frame.size.width/4;
    CGFloat buttonWidth = self.view.frame.size.width/2 - 2 * innerSpacing;
    
    NSLog(@"View width is %f and button width is %f", self.view.frame.size.width, buttonWidth);
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_top).offset(navigationBarHeight + 20);
        make.bottom.equalTo(self.view.mas_bottom).offset( - 2 * innerSpacing - buttonHeight);
        make.centerX.equalTo(self.view.mas_centerX);
        make.width.equalTo(self.view.mas_width);
    }];
    
    [self.postButton mas_makeConstraints:^(MASConstraintMaker *make){
        make.bottom.equalTo(self.view.mas_bottom).offset( - innerSpacing);
        make.height.equalTo(@(buttonHeight));
        make.left.equalTo(self.view.mas_left).offset(innerSpacing);
        make.right.equalTo(self.resetButton.mas_left).offset( - 2 * innerSpacing);
        make.width.equalTo(@(buttonWidth));
        make.centerX.equalTo(@(buttonCenterXPosition));
    }];
    
    [self.resetButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.view.mas_bottom).offset( - innerSpacing);
        make.height.equalTo(@(buttonHeight));
        make.right.equalTo(self.view.mas_right).offset( - innerSpacing);
        make.width.equalTo(@(buttonWidth));
        make.centerX.equalTo(@(3 * buttonCenterXPosition));
    }];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

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
    //[self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:dateCellIdentifier];
    //[self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:rightDisclosureCellIdentifier];
    
    if (indexPath.section == 0)
    {
        if (indexPath.row == 0)
        {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:dateCellIdentifier];
            if (!cell) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:dateCellIdentifier];
            }
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"YYYY-MM-dd"];
            cell.textLabel.text = @"日期";
            cell.detailTextLabel.text = [dateFormatter stringFromDate:[NSDate date]];
            cell.textLabel.font = [UIFont systemFontOfSize:16];
            cell.detailTextLabel.font = [UIFont systemFontOfSize:16];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
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
            if (!cell) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:rightDisclosureCellIdentifier];
            }
            cell.textLabel.text = @"失物类型";
            cell.detailTextLabel.text = @"大学城一卡通";
            cell.textLabel.font = [UIFont systemFontOfSize:16];
            cell.detailTextLabel.font = [UIFont systemFontOfSize:16];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
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
            if (!cell) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:rightDisclosureCellIdentifier];
            }
            cell.textLabel.text = @"失物详情";
            cell.detailTextLabel.text = @"请输入详情";
            cell.textLabel.font = [UIFont systemFontOfSize:16];
            cell.detailTextLabel.font = [UIFont systemFontOfSize:16];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
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
                                               self.item.type = [NSNumber numberWithInteger:selectedIndex];
                                           }
                                         cancelBlock:^(ActionSheetStringPicker *picker) {
                                             
                                         }
                                              origin:[tableView cellForRowAtIndexPath:indexPath].detailTextLabel
         ];

    } else if (indexPath.section == 1 && indexPath.row == 1) {
        
        UIImagePickerController *pickerContoller = [[UIImagePickerController alloc] init];
        pickerContoller.modalPresentationStyle = UIModalPresentationCurrentContext;
        pickerContoller.delegate = self;
        
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

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    [self dismissViewControllerAnimated:YES completion:NULL];
    
    UIImage *image = [info valueForKey:UIImagePickerControllerOriginalImage];
    BBTItemImageTableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:1]];
    [cell configureCellWithImage:image];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (void)BBTItemDetail:(BBTItemDetailEditingViewController *)controller didFinishEditingDetails:(NSString *)itemDetails
{
    self.itemDetails = itemDetails;
    if ([itemDetails length] < 10) {
        [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:1]].detailTextLabel.text = itemDetails;
    } else if ([itemDetails isEqualToString:@""]) {
        [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:1]].detailTextLabel.text = @"请输入详情";
    } else {
        [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:1]].detailTextLabel.text = [[itemDetails substringToIndex:10] stringByAppendingString:@"..."];
    }
    
    if (![itemDetails isEqualToString:@""]) {
        self.item.details = itemDetails;
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)postButtonIsTapped
{
    self.item.loserID = [BBTCurrentUserManager sharedCurrentUserManager].currentUser.account;
    
    self.item.date = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]].detailTextLabel.text;
    
    BBTItemCampusTableViewCell *campusCell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
    self.item.campus = [NSNumber numberWithInteger:campusCell.campus.selectedSegmentIndex];
    
    BBTTextFieldTableViewCell *locationCell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]];
    self.item.location = locationCell.contents.text;
    
    BBTTextFieldTableViewCell *contactCell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:2]];
    self.item.publisher = contactCell.contents.text;
    
    BBTTextFieldTableViewCell *phoneCell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:2]];
    self.item.phone = phoneCell.contents.text;
    
    BBTTextFieldTableViewCell *otherContactCell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:2]];
    self.item.otherContact = otherContactCell.contents.text;
    
    if ([self.item.location isEqualToString:@""] || [self.item.publisher isEqualToString:@""] || [self.item.phone isEqualToString:@""])
    {
        UIAlertController *alertController = [[UIAlertController alloc] init];
        alertController = [UIAlertController alertControllerWithTitle:@"信息不全" message:@"请补齐必填信息" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleDefault handler:nil];
        [alertController addAction:okAction];
        [self presentViewController:alertController animated:YES completion:nil];
        return;
    }
    
    NSMutableDictionary *itemDic = [[NSMutableDictionary alloc] init];
    [itemDic setObject:self.item.campus forKey:@"campus"];
    [itemDic setObject:self.item.date forKey:@"date"];
    [itemDic setObject:self.item.location forKey:@"loaction"];
    [itemDic setObject:self.item.phone forKey:@"phone"];
    [itemDic setObject:self.item.publisher forKey:@"publisher"];
    [itemDic setObject:self.item.type forKey:@"type"];
    
    if (self.item.details)[itemDic setObject:self.item.details forKey:@"details"];
    if (self.item.otherContact)[itemDic setObject:self.item.otherContact forKey:@"otherContact"];
    
    [[BBTLAFManager sharedLAFManager] postItemDic:itemDic WithType:[self.lostOrFound integerValue]];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:itemDetailIdentifier]) {
        UINavigationController *navigationController = segue.destinationViewController;
        BBTItemDetailEditingViewController *controller = (BBTItemDetailEditingViewController *)navigationController.topViewController;
        controller.title = sender;
        controller.delegate = self;
        if (![sender isEqualToString:@"请输入详情"]) {
            controller.textToEditing = [[NSString alloc] initWithString:sender];
        }
    }
}

@end

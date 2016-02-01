//
//  BBTPostInfoTableViewController.m
//  BoBanTang
//
//  Created by Hsu Tung Hui on 16/1/30.
//  Copyright © 2016年 100steps. All rights reserved.
//

#import "BBTPostInfoTableViewController.h"
#import "ActionSheetPicker.h"
#import "BBTLAF.h"
#import "BBTLAFManager.h"

static NSString *itemDetailIdentifier = @"itemDetailIdentifier";

@class AbstractActionSheetPicker;
@interface BBTPostInfoTableViewController ()

@property (strong, nonatomic) IBOutlet UILabel *dateDetail;

@property (strong, nonatomic) IBOutlet UISegmentedControl *campus;

@property (strong, nonatomic) IBOutlet UILabel *locationTitle;
@property (strong, nonatomic) IBOutlet UITextField *locationDetail;

@property (strong, nonatomic) IBOutlet UILabel *itemTypeTitle;
@property (strong, nonatomic) IBOutlet UILabel *itemType;

@property (strong, nonatomic) IBOutlet UILabel *imageTitle;
@property (strong, nonatomic) IBOutlet UIImageView *image;

@property (strong, nonatomic) IBOutlet UILabel *itemDetailTitle;
@property (strong, nonatomic) IBOutlet UILabel *itemDetail;

@property (strong, nonatomic) IBOutlet UITextField *contactName;
@property (strong, nonatomic) IBOutlet UITextField *contactNum;
@property (strong, nonatomic) IBOutlet UITextField *contactOthers;

@end

@implementation BBTPostInfoTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.title = self.postType;
    self.navigationItem.backBarButtonItem.title = @"失物招领";
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor],NSForegroundColorAttributeName,nil]];
    self.navigationController.navigationBar.tintColor=[UIColor whiteColor];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    
    [self.view addGestureRecognizer:tap];
    [tap setCancelsTouchesInView:NO];
     
    [self.locationDetail addTarget:self
                            action:@selector(dismissKeyboard)
                  forControlEvents:UIControlEventEditingDidEndOnExit];
    [self.contactName addTarget:self
                         action:@selector(dismissKeyboard)
               forControlEvents:UIControlEventEditingDidEndOnExit];
    [self.contactNum addTarget:self
                        action:@selector(dismissKeyboard)
              forControlEvents:UIControlEventEditingDidEndOnExit];
    [self.contactOthers addTarget:self
                           action:@selector(dismissKeyboard)
                 forControlEvents:UIControlEventEditingDidEndOnExit];
    
    if ([self.postType isEqualToString:@"发布招领启事"]) {
        self.locationTitle.text = @"拾获地点";
        self.locationDetail.placeholder = @"填写拾获物拾获地点";
        self.itemTypeTitle.text = @"拾获物类型";
        self.imageTitle.text = @"拾获物图片";
        self.itemDetailTitle.text = @"拾获物详情";
        
    } else {
        self.locationTitle.text = @"丢失地点";
        self.locationDetail.placeholder = @"填写丢失物丢失地点";
        self.itemTypeTitle.text = @"丢失物类型";
        self.imageTitle.text = @"丢失物图片";
        self.itemDetailTitle.text = @"丢失物详情";
    }
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MM月dd日"];
    self.dateDetail.text = [dateFormatter stringFromDate:[NSDate date]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dismissKeyboard
{
    [self.locationDetail resignFirstResponder];
    [self.contactName resignFirstResponder];
    [self.contactNum resignFirstResponder];
    [self.contactOthers resignFirstResponder];
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
                                                                       origin:self.dateDetail];
        [datePicker showActionSheetPicker];
        
    } else if (indexPath.section == 1 && indexPath.row == 0) {
        NSArray *itemTypes = [NSArray arrayWithObjects:@"大学城一卡通", @"校园卡(绿卡)", @"钱包", @"钥匙", @"电子产品", @"其它", nil];
        [ActionSheetStringPicker showPickerWithTitle:@"请选择类型"
                                                rows:itemTypes
                                    initialSelection:0
                                           doneBlock:^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
            self.itemType.text = itemTypes[selectedIndex];
        }
                                         cancelBlock:^(ActionSheetStringPicker *picker) {
            
        }
                                              origin:self.itemType
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
    }
    
}

- (void)dateWasSelected:(NSDate *)selectedDate element:(id)element
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MM月dd日"];
    [element setText:[dateFormatter stringFromDate:selectedDate]];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    [self dismissViewControllerAnimated:YES completion:NULL];
    
    UIImage *image = [info valueForKey:UIImagePickerControllerOriginalImage];
    [self.image setImage:image];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (void)BBTItemDetail:(BBTItemDetailViewController *)controller didFinishEditingDetails:(NSString *)itemDetails
{
    if ([itemDetails length] < 10) {
        self.itemDetail.text = itemDetails;
    } else {
        self.itemDetail.text = [[itemDetails substringToIndex:10] stringByAppendingString:@"..."];
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:itemDetailIdentifier]) {
        UINavigationController *navigationController = segue.destinationViewController;
        BBTItemDetailViewController *controller = (BBTItemDetailViewController *)navigationController.topViewController;
        controller.title = self.itemDetailTitle.text;
        controller.delegate = self;
        if (![self.itemDetail.text isEqualToString:@"请输入详情"]) {
            controller.textToEditing = [[NSString alloc] initWithString:self.itemDetail.text];
        }
    }
}


@end

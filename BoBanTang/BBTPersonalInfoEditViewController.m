//
//  BBTPersonalInfoEditViewController.m
//  BoBanTang
//
//  Created by Caesar on 16/2/18.
//  Copyright © 2016年 100steps. All rights reserved.
//

#import "BBTPersonalInfoEditViewController.h"
#import "BBTImageUploadManager.h"
#import "BBTChangeNickNameViewController.h"
#import "BBTCurrentUserManager.h"
#import <MBProgressHUD.h>

@interface BBTPersonalInfoEditViewController ()

@property (strong, nonatomic) IBOutlet UIImageView * addNewImageView;
@property (strong, nonatomic) UIImage              * theNewAvatarImage;

@end

@implementation BBTPersonalInfoEditViewController

extern NSString * kDidUploadImageNotificationName;
extern NSString * kFailUploadImageNotificationName;
extern NSString * didUploadUserLogoURLNotifName;
extern NSString * failUploadUserLogoURLNotifName;

- (void)viewDidLoad
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceiveImageUploadSucceedNotif)
                                                 name:kDidUploadImageNotificationName
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceiveImageUploadFailNotif)
                                                 name:kFailUploadImageNotificationName
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceiveLogoUploadSucceedNotif)
                                                 name:didUploadUserLogoURLNotifName
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceiveLogoUploadFailNotif)
                                                 name:failUploadUserLogoURLNotifName
                                               object:nil];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0)
    {
        [self changeAvatar];
    }
    else
    {
        [self changeNickName];
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)changeAvatar
{
    UIImagePickerController *pickerContoller = [[UIImagePickerController alloc] init];
    pickerContoller.modalPresentationStyle = UIModalPresentationCurrentContext;
    pickerContoller.delegate = self;
    pickerContoller.allowsEditing = YES;
    
    //Hide tabbar and disable user interaction
    self.tabBarController.tabBar.hidden = YES;
    self.tabBarController.tabBar.userInteractionEnabled = NO;
    
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

#pragma mark - UIImagePickerController Delegate Methods
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [self dismissViewControllerAnimated:YES completion:NULL];
    //Show tabbar and allow user interaction
    self.tabBarController.tabBar.hidden = NO;
    self.tabBarController.tabBar.userInteractionEnabled = YES;
    //self.hidesBottomBarWhenPushed = NO;                             //Show tab bar
    //if ([info valueForKey:UIImagePickerControllerEditedImage])
    //{
    
    UIImage *avatarImage = [info valueForKey:UIImagePickerControllerEditedImage];
    self.theNewAvatarImage = avatarImage;

    //Upload the picture to QiNiu
    [[BBTImageUploadManager sharedUploadManager] uploadImageToQiniu:avatarImage];
    
    //}
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    //Show tabbar and allow user interaction
    self.tabBarController.tabBar.hidden = NO;
    self.tabBarController.tabBar.userInteractionEnabled = YES;
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (void)changeNickName
{
    BBTChangeNickNameViewController *changeNickNameVC = [[BBTChangeNickNameViewController alloc] init];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:changeNickNameVC];
    [self presentViewController:navigationController animated:YES completion:nil];
}

- (void)didReceiveImageUploadSucceedNotif
{
    //Set the image of the cell be the choosen picture.
    self.addNewImageView.image = self.theNewAvatarImage;
    
    //Upload current user's logo url
    [[BBTCurrentUserManager sharedCurrentUserManager] uploadNewLogoURL:[BBTImageUploadManager sharedUploadManager].originalImageUrl];
}

- (void)didReceiveImageUploadFailNotif
{
    //Change back addNewImageView's image
    self.addNewImageView.image = [UIImage imageNamed:@"addNewImage"];
    
    //Show failure HUD
    MBProgressHUD *failureHUD = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    
    //Set the annular determinate mode to show task progress.
    failureHUD.mode = MBProgressHUDModeText;
    failureHUD.labelText = @"头像上传失败";
    
    //Move to center.
    CGFloat centerY = 0.5 * (CGRectGetMaxY(self.view.frame) + CGRectGetMinY(self.view.frame));
    failureHUD.xOffset = 0.0f;
    failureHUD.yOffset = centerY;
    
    //Hide after 3 seconds.
    [failureHUD hide:YES afterDelay:3.0f];
}

- (void)didReceiveLogoUploadSucceedNotif
{
    //Show success HUD
    MBProgressHUD *successHUD = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    
    //Set the annular determinate mode to show task progress.
    successHUD.mode = MBProgressHUDModeText;
    successHUD.labelText = @"头像上传成功!";
    
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

- (void)didReceiveLogoUploadFailNotif
{
    //Change back addNewImageView's image
    self.addNewImageView.image = [UIImage imageNamed:@"addNewImage"];
    
    //Show failure HUD
    MBProgressHUD *failureHUD = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    
    //Set the annular determinate mode to show task progress.
    failureHUD.mode = MBProgressHUDModeText;
    failureHUD.labelText = @"头像上传失败";
    
    //Move to center.
    failureHUD.xOffset = 0.0f;
    failureHUD.yOffset = 0.0f;
    
    //Hide after 2 seconds.
    [failureHUD hide:YES afterDelay:2.0f];
    
    //Dismiss current VC 0.5 sec after HUD disappears.
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 2.5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [self dismissViewControllerAnimated:YES completion:nil];
    });
}

@end

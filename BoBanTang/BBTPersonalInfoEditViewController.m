//
//  BBTPersonalInfoEditViewController.m
//  BoBanTang
//
//  Created by Caesar on 16/2/18.
//  Copyright © 2016年 100steps. All rights reserved.
//

#import "BBTPersonalInfoEditViewController.h"
#import "BBTImageUploadManager.h"

@interface BBTPersonalInfoEditViewController ()

@property (strong, nonatomic) IBOutlet UIImageView *addNewImageView;

@end

@implementation BBTPersonalInfoEditViewController

extern NSString *kDidUploadImageNotificationName;
extern NSString *kFailUploadImageNotificationName;

- (void)viewDidLoad
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceiveImageUploadNotif:)
                                                 name:kDidUploadImageNotificationName
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceiveImageUploadNotif:)
                                                 name:kFailUploadImageNotificationName
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
        //Set the image of the cell be the choosen picture.
        UIImage *avatarImage = [info valueForKey:UIImagePickerControllerEditedImage];
        self.addNewImageView.image = avatarImage;

        //Upload the picture to QiNiu
        //[[BBTImageUploadManager sharedUploadManager] uploadImageToQiniu:avatarImage];
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
    //TODO: Change user's nickname here.
}

- (void)didReceiveImageUploadNotif:(NSString *)notifName
{
    if ([notifName isEqualToString:kDidUploadImageNotificationName])
    {
        //TODO: Show HUD
        //TODO: Write Original Image URL into database
    }
    else if ([notifName isEqualToString:kFailUploadImageNotificationName])
    {
        //TODO: Show HUD
    }
}

@end

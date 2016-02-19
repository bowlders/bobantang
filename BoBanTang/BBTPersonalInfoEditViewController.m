//
//  BBTPersonalInfoEditViewController.m
//  BoBanTang
//
//  Created by Caesar on 16/2/18.
//  Copyright © 2016年 100steps. All rights reserved.
//

#import "BBTPersonalInfoEditViewController.h"

@implementation BBTPersonalInfoEditViewController

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0)
    {
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

@end

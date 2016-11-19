//
//  BBTItemDetailViewController.h
//  BoBanTang
//
//  Created by Hsu Tung Hui on 16/1/31.
//  Copyright © 2016年 100steps. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BBTItemDetailEditingViewController;

@protocol BBTItemDetailEditingViewControllerDelegate

- (void)BBTItemDetail:(BBTItemDetailEditingViewController *)controller didFinishEditingDetails:(NSString *)itemDetails;

@end

@interface BBTItemDetailEditingViewController : UIViewController <UITextViewDelegate>

@property (weak, nonatomic) id <BBTItemDetailEditingViewControllerDelegate> delegate;

@property (copy, nonatomic) NSString *textToEditing;

@end


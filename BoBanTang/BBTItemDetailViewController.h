//
//  BBTItemDetailViewController.h
//  BoBanTang
//
//  Created by Hsu Tung Hui on 16/1/31.
//  Copyright © 2016年 100steps. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BBTItemDetailViewController;

@protocol BBTItemDetailViewControllerDelegate

- (void)BBTItemDetail:(BBTItemDetailViewController *)controller didFinishEditingDetails:(NSString *)itemDetails;

@end

@interface BBTItemDetailViewController : UIViewController <UITextViewDelegate>

@property (weak, nonatomic) id <BBTItemDetailViewControllerDelegate> delegate;

@property (copy, nonatomic) NSString *textToEditing;
@property (strong, nonatomic) IBOutlet UITextView *itemDetails;

@end


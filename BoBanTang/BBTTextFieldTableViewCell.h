//
//  BBTTextFieldTableViewCell.h
//  BoBanTang
//
//  Created by Hsu Tung Hui on 16/2/9.
//  Copyright © 2016年 100steps. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BBTTextFieldTableViewCell : UITableViewCell <UITextFieldDelegate>

@property (strong, nonatomic) IBOutlet UILabel *title;
@property (strong, nonatomic) IBOutlet UITextField *contents;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;

- (void)configureCellForDifferntUse:(NSInteger) type;
- (void)dismissKeyboard;

@end

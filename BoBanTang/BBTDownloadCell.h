//
//  BBTDownloadCell.h
//  bobantang
//
//  Created by Bill Bai on 10/7/14.
//  Copyright (c) 2014 Bill Bai. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BBTDownloadCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel *downloadStatLabel;
@property (nonatomic, weak) IBOutlet UILabel *downloadedCountLabel;
@property (nonatomic, weak) IBOutlet UILabel *fullSizeCountLabel;

@property (nonatomic, weak) IBOutlet UIProgressView *downloadProgressView;
@end

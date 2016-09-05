//
//  BBTScoresCell.h
//  BoBanTang
//
//  Created by Hsu Tung Hui on 26/10/15.
//  Copyright © 2015年 BBT. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BBTScores;

@interface BBTScoresCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel *courseName;
@property (strong, nonatomic) IBOutlet UILabel *score;
@property (strong, nonatomic) IBOutlet UILabel *gradePoint;
@property (strong, nonatomic) IBOutlet UILabel *ranking;

- (void)configureForScores:(BBTScores *)scores;

@end

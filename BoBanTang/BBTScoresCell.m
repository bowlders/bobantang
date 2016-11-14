//
//  BBTScoresCell.m
//  BoBanTang
//
//  Created by Hsu Tung Hui on 26/10/15.
//  Copyright © 2015年 BBT. All rights reserved.
//

#import "BBTScoresCell.h"
#import "BBTScores.h"

@implementation BBTScoresCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectZero];
    view.backgroundColor = [UIColor whiteColor];
    self.selectedBackgroundView = view;
    self.courseName.numberOfLines = 0;
    [self.courseName sizeToFit];
    self.courseName.adjustsFontSizeToFitWidth = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)configureForScores:(BBTScores *)scores
{
    self.courseName.text = scores.courseName;
    self.score.text = scores.score;
    self.gradePoint.text = scores.gradepoint;
    self.ranking.text = scores.ranking;
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    self.courseName.text = nil;
    self.score.text = nil;
    self.gradePoint.text = nil;
    self.ranking.text = nil;
}

@end

//
//  BBTSpecRailway2TableViewCell.m
//  BoBanTang
//
//  Created by Caesar on 15/11/22.
//  Copyright © 2015年 100steps. All rights reserved.
//

#import "BBTSpecRailway2TableViewCell.h"
#import <Masonry.h>

@interface BBTSpecRailway2TableViewCell ()

@property (strong, nonatomic) UILabel     * stationLabel;
@property (strong, nonatomic) UIImageView * leftCircleImageView;
@property (strong, nonatomic) UIImageView * leftBusImageView;

@property (nonatomic) BOOL didSetupConstraints;

@end

@implementation BBTSpecRailway2TableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    
    if (self)
    {
        self.stationLabel = ({
            UILabel *label = [UILabel new];
            label.translatesAutoresizingMaskIntoConstraints = NO;
            label.textAlignment = NSTextAlignmentLeft;
            label.numberOfLines = 1;
            label.adjustsFontSizeToFitWidth = NO;
            label.alpha = 1.0;
            label;
        });
        
        self.leftCircleImageView = ({
            UIImageView *imageView = [UIImageView new];
            imageView.translatesAutoresizingMaskIntoConstraints = NO;
            imageView.contentMode = UIViewContentModeScaleAspectFill;
            imageView.clipsToBounds = YES;
            imageView.image = [UIImage imageNamed:@"circle"];
            imageView.alpha = 1.0;
            imageView;
        });

        self.leftBusImageView = ({
            UIImageView *imageView = [UIImageView new];
            imageView.translatesAutoresizingMaskIntoConstraints = NO;
            imageView.contentMode = UIViewContentModeScaleAspectFill;
            imageView.clipsToBounds = YES;
            imageView.image = [UIImage imageNamed:@"bus"];
            imageView.alpha = 0.0;
            imageView;
        });
        
        [self.contentView addSubview:self.stationLabel];
        [self.contentView addSubview:self.leftCircleImageView];
        [self.contentView addSubview:self.leftBusImageView];
        
    }
    
    return self;
}

- (void)updateConstraints
{
    if (!self.didSetupConstraints)
    {
        CGFloat horizontalInnerSpacing = 5.0f;
        CGFloat leftImageOffset = 60.0f;
        CGFloat stationLabelWidth = 130.0f;
        
        [self.contentView mas_makeConstraints:^(MASConstraintMaker *make){
            make.center.equalTo(self);
            make.size.equalTo(self);
        }];
        
        [self.stationLabel mas_makeConstraints:^(MASConstraintMaker *make){
            make.left.equalTo(self.leftCircleImageView.mas_right).offset(horizontalInnerSpacing);
            make.right.equalTo(self.contentView.mas_right);
            make.centerY.equalTo(self.contentView);
        }];
        
        [self.leftCircleImageView mas_makeConstraints:^(MASConstraintMaker *make){
            make.left.equalTo(self.contentView.mas_left).offset(leftImageOffset);
            make.width.equalTo(self.mas_height).multipliedBy(0.8);
            make.height.equalTo(self.mas_height).multipliedBy(0.8);
            make.centerY.equalTo(self.contentView);
        }];
        
        [self.leftBusImageView mas_makeConstraints:^(MASConstraintMaker *make){
            make.left.equalTo(self.contentView.mas_left).offset(leftImageOffset);
            make.width.equalTo(self.mas_height).multipliedBy(0.8);
            make.height.equalTo(self.mas_height).multipliedBy(0.8);
            make.centerY.equalTo(self.contentView);
        }];
        
        self.didSetupConstraints = YES;
    }
    [super updateConstraints];
}

- (void)initCellContent:(NSString *)stationName
{
    self.stationLabel.text = stationName;
}

- (void)initCellContent
{
    [UIView animateWithDuration:1.0 delay:0
                        options:UIViewAnimationOptionCurveLinear
                     animations:^(void){
                         self.leftBusImageView.alpha = 0.0;
                         self.leftCircleImageView.alpha = 1.0;
                     }
                     completion:nil];
}

- (void)changeCellImage
{
        [UIView animateWithDuration:1.0 delay:0
                            options:UIViewAnimationOptionCurveLinear
                         animations:^(void){
                             self.leftBusImageView.alpha = 1.0;
                             self.leftCircleImageView.alpha = 0.0;
                         }
                         completion:nil];
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end

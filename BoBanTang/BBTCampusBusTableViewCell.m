//
//  BBTCampusBusTableViewCell.m
//  BoBanTang
//
//  Created by Caesar on 16/1/28.
//  Copyright © 2016年 100steps. All rights reserved.
//

#import "BBTCampusBusTableViewCell.h"
#import <Masonry.h>

@interface BBTCampusBusTableViewCell ()

@property (strong, nonatomic) UILabel     * stationLabel;
@property (strong, nonatomic) UIImageView * leftCircleImageView;
@property (strong, nonatomic) UIImageView * rightCircleImageView;
@property (strong, nonatomic) UIImageView * leftBusImageView;
@property (strong, nonatomic) UIImageView * rightBusImageView;

@property (nonatomic) BOOL didSetupConstraints;

@end

@implementation BBTCampusBusTableViewCell

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
        
        self.rightCircleImageView = ({
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

        self.rightBusImageView = ({
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
        [self.contentView addSubview:self.rightCircleImageView];
        [self.contentView addSubview:self.leftBusImageView];
        [self.contentView addSubview:self.rightBusImageView];
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
            make.width.equalTo(@(stationLabelWidth));
            make.centerY.equalTo(self.contentView);
        }];
        
        [self.leftCircleImageView mas_makeConstraints:^(MASConstraintMaker *make){
            make.left.equalTo(self.contentView.mas_left).offset(leftImageOffset);
            make.width.equalTo(self.mas_height).multipliedBy(0.8);
            make.height.equalTo(self.mas_height).multipliedBy(0.8);
            make.centerY.equalTo(self.contentView);
        }];
        
        [self.rightCircleImageView mas_makeConstraints:^(MASConstraintMaker *make){
            make.left.equalTo(self.stationLabel.mas_right).offset(horizontalInnerSpacing);
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
        
        [self.rightBusImageView mas_makeConstraints:^(MASConstraintMaker *make){
            make.left.equalTo(self.stationLabel.mas_right).offset(horizontalInnerSpacing);
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
    [UIView animateWithDuration:1.0 delay:0
                        options:UIViewAnimationOptionCurveLinear
                     animations:^(void){
                         self.rightBusImageView.alpha = 0.0;
                         self.rightCircleImageView.alpha = 1.0;
                         }
                     completion:nil];
}

- (void)changeCellImageAtSide:(BOOL)side
{
    if (!side)                          //change left image (to bus image).
    {
        [UIView animateWithDuration:1.0 delay:0
                            options:UIViewAnimationOptionCurveLinear
                         animations:^(void){
                             self.leftBusImageView.alpha = 1.0;
                             self.leftCircleImageView.alpha = 0.0;
                         }
                         completion:nil];
    }
    else                                //change right image (to bus image);
    {
        [UIView animateWithDuration:1.0 delay:0
                            options:UIViewAnimationOptionCurveLinear
                         animations:^(void){
                             self.rightBusImageView.alpha = 1.0;
                             self.rightCircleImageView.alpha = 0.0;
                         }
                         completion:nil];
    }
}

@end

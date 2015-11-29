//
//  BBTCampusInfoCellTableViewCell.m
//  BoBanTang
//
//  Created by Caesar on 15/11/29.
//  Copyright © 2015年 100steps. All rights reserved.
//

#import "BBTCampusInfoCellTableViewCell.h"
#import <Masonry.h>

@interface BBTCampusInfoCellTableViewCell ()

@property (strong, nonatomic) UILabel       *       titleLabel;
@property (strong, nonatomic) UILabel       *       authorLabel;
@property (strong, nonatomic) UILabel       *       abstractLabel;
@property (strong, nonatomic) UILabel       *       dateLabel;
@property (strong, nonatomic) UIImageView   *       thumbImage;

@property (nonatomic) BOOL didSetupConstraints;

@end

@implementation BBTCampusInfoCellTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    
    if (self)
    {
        
        self.titleLabel = ({
            UILabel * label = [UILabel new];
            label.translatesAutoresizingMaskIntoConstraints = NO;
            label.lineBreakMode = NSLineBreakByTruncatingTail;
            label.textAlignment = NSTextAlignmentLeft;
            label.numberOfLines = 1;
            label.adjustsFontSizeToFitWidth = YES;
            label;
        });
        
        self.authorLabel = ({
            UILabel * label = [UILabel new];
            label.translatesAutoresizingMaskIntoConstraints = NO;
            label.lineBreakMode = NSLineBreakByTruncatingTail;
            label.textAlignment = NSTextAlignmentLeft;
            label.numberOfLines = 1;
            label.adjustsFontSizeToFitWidth = YES;
            label;
        });
        
        self.abstractLabel = ({
            UILabel * label = [UILabel new];
            label.translatesAutoresizingMaskIntoConstraints = NO;
            label.lineBreakMode = NSLineBreakByTruncatingTail;
            label.textAlignment = NSTextAlignmentLeft;
            label.numberOfLines = 1;
            label.adjustsFontSizeToFitWidth = YES;
            label;
        });
        
        self.dateLabel = ({
            UILabel * label = [UILabel new];
            label.translatesAutoresizingMaskIntoConstraints = NO;
            label.lineBreakMode = NSLineBreakByTruncatingTail;
            label.textAlignment = NSTextAlignmentRight;
            label.numberOfLines = 1;
            label.adjustsFontSizeToFitWidth = YES;
            label;
        });
        
        self.thumbImage = ({
            UIImageView * imageView = [UIImageView new];
            imageView.translatesAutoresizingMaskIntoConstraints = NO;
            imageView.contentMode = UIViewContentModeScaleAspectFill;
            imageView.clipsToBounds = YES;
            imageView;
        });
        
        [self.contentView addSubview:self.titleLabel];
        [self.contentView addSubview:self.authorLabel];
        [self.contentView addSubview:self.abstractLabel];
        [self.contentView addSubview:self.dateLabel];
        [self.contentView addSubview:self.thumbImage];
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [self.contentView setNeedsLayout];
    [self.contentView layoutIfNeeded];
}

- (void)updateConstraints
{
    if (!self.didSetupConstraints)
    {
        static const CGFloat topOffset = 5.0;
        static const CGFloat bottomOffset = 5.0;
        static const CGFloat imageLeftOffset = 3.0;
        static const CGFloat horizontalInnerSpacing = 5.0;
        static const CGFloat verticalInnerSpacing = 3.0;
        static const CGFloat rightOffset = 3.0;
        
        [self.contentView mas_makeConstraints:^(MASConstraintMaker *make){
            make.size.equalTo(self);
            make.center.equalTo(self);
        }];
        
        [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make){
            make.top.equalTo(self.contentView.mas_top).offset(topOffset);
            make.bottom.equalTo(self.abstractLabel.mas_top).offset(-verticalInnerSpacing);
            make.left.equalTo(self.thumbImage.mas_right).offset(horizontalInnerSpacing);
            make.right.equalTo(self.contentView.mas_right).offset(-rightOffset);
        }];
        
        [self.authorLabel mas_makeConstraints:^(MASConstraintMaker *make){
            make.top.equalTo(self.abstractLabel.mas_bottom).offset(verticalInnerSpacing);
            make.bottom.equalTo(self.contentView.mas_bottom).offset(-bottomOffset);
            make.left.equalTo(self.thumbImage.mas_right).offset(horizontalInnerSpacing);
            make.width.equalTo(self.abstractLabel.mas_width).multipliedBy(0.5);
        }];
        
        [self.abstractLabel mas_makeConstraints:^(MASConstraintMaker *make){
            make.top.equalTo(self.titleLabel.mas_bottom).offset(verticalInnerSpacing);
            make.bottom.equalTo(self.authorLabel.mas_top).offset(-verticalInnerSpacing);
            make.left.equalTo(self.thumbImage.mas_right).offset(horizontalInnerSpacing);
            make.right.equalTo(self.contentView.mas_right).offset(-rightOffset);
        }];
        
        [self.dateLabel mas_makeConstraints:^(MASConstraintMaker *make){
            make.top.equalTo(self.abstractLabel.mas_bottom).offset(verticalInnerSpacing);
            make.bottom.equalTo(self.contentView.mas_bottom).offset(-bottomOffset);
            make.right.equalTo(self.contentView.mas_right).offset(-rightOffset);
            make.width.equalTo(self.abstractLabel.mas_width).multipliedBy(0.5);
        }];
        
        [self.thumbImage mas_makeConstraints:^(MASConstraintMaker *make){
            make.top.equalTo(self.contentView.mas_top).offset(topOffset);
            make.bottom.equalTo(self.contentView.mas_bottom).offset(-bottomOffset);
            make.left.equalTo(self.contentView.mas_left).offset(imageLeftOffset);
            make.right.equalTo(self.abstractLabel.mas_left).offset(-horizontalInnerSpacing);
        }];
        
        self.didSetupConstraints = YES;
    }
    [super updateConstraints];
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end

//
//  BBTCampusInfoCellTableViewCell.m
//  BoBanTang
//
//  Created by Caesar on 15/11/29.
//  Copyright © 2015年 100steps. All rights reserved.
//

#import "BBTCampusInfoTableViewCell.h"
#import "UIFont+BBTFont.h"
#import "BBTCampusInfo.h"
#import <Masonry.h>
#import "UIImageView+UIActivityIndicatorForSDWebImage.h"

@interface BBTCampusInfoTableViewCell ()

@property (strong, nonatomic) UILabel       *       titleLabel;
@property (strong, nonatomic) UILabel       *       authorLabel;
@property (strong, nonatomic) UILabel       *       abstractLabel;
@property (strong, nonatomic) UILabel       *       dateLabel;
@property (strong, nonatomic) UIImageView   *       thumbImage;

@property (nonatomic) BOOL didSetupConstraints;

@end

@implementation BBTCampusInfoTableViewCell

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
            label.numberOfLines = 2;
            label.adjustsFontSizeToFitWidth = NO;
            label.font = [UIFont BBTInformationTableViewTitleFont];
            label.clipsToBounds = YES;
            label;
        });
        
        self.authorLabel = ({
            UILabel * label = [UILabel new];
            label.translatesAutoresizingMaskIntoConstraints = NO;
            label.lineBreakMode = NSLineBreakByTruncatingTail;
            label.textAlignment = NSTextAlignmentRight;
            label.numberOfLines = 1;
            label.font = [UIFont BBTInformationTableViewAuthorandDateFont];
            label.clipsToBounds = YES;
            //[label setPreferredMaxLayoutWidth:10.0f];
            label;
        });
        
        self.abstractLabel = ({
            UILabel * label = [UILabel new];
            label.translatesAutoresizingMaskIntoConstraints = NO;
            label.lineBreakMode = NSLineBreakByTruncatingTail;
            label.textAlignment = NSTextAlignmentLeft;
            label.numberOfLines = 2;
            label.adjustsFontSizeToFitWidth = NO;
            label.font = [UIFont BBTInformationTableViewAbstractFont];
            label.clipsToBounds = YES;
            label;
        });
        
        self.dateLabel = ({
            UILabel * label = [UILabel new];
            label.translatesAutoresizingMaskIntoConstraints = NO;
            label.lineBreakMode = NSLineBreakByTruncatingTail;
            label.textAlignment = NSTextAlignmentRight;
            label.numberOfLines = 1;
            label.font = [UIFont BBTInformationTableViewAuthorandDateFont];
            label.clipsToBounds = YES;
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
        
    }
    
    return self;
}

- (void)updateConstraints
{
    if (!self.didSetupConstraints)
    {
        static const CGFloat topOffset = 8.0f;
        static const CGFloat bottomOffset = 8.0f;
        static const CGFloat imageLeftOffset = 8.0f;
        static const CGFloat horizontalInnerSpacing = 3.0f;
        static const CGFloat verticalInnerSpacing = 3.0f;
        static const CGFloat rightOffset = 8.0f;
        static const CGFloat imageSideLength = 80.0f;
        
        [self.contentView mas_makeConstraints:^(MASConstraintMaker *make){
            make.size.equalTo(self);
            make.center.equalTo(self);
        }];
        
        [self.authorLabel mas_makeConstraints:^(MASConstraintMaker *make){
            make.top.equalTo(self.abstractLabel.mas_bottom).offset(verticalInnerSpacing);
            make.bottom.equalTo(self.contentView.mas_bottom).offset(-bottomOffset);
            make.left.equalTo(self.dateLabel.mas_right).offset(horizontalInnerSpacing);
            make.right.equalTo(self.contentView.mas_right).offset(-rightOffset);
        }];
        
        [self.dateLabel mas_makeConstraints:^(MASConstraintMaker *make){
            make.top.equalTo(self.authorLabel.mas_top);
            make.bottom.equalTo(self.authorLabel.mas_bottom);
            make.left.greaterThanOrEqualTo(self.thumbImage.mas_right).offset(horizontalInnerSpacing);
            make.right.equalTo(self.authorLabel.mas_left).offset(-horizontalInnerSpacing);
        }];
        
        [self.abstractLabel mas_makeConstraints:^(MASConstraintMaker *make){
            make.top.equalTo(self.thumbImage.mas_top);
            make.bottom.equalTo(self.authorLabel.mas_top).offset(-verticalInnerSpacing);
            make.left.equalTo(self.thumbImage.mas_right).offset(horizontalInnerSpacing);
            make.right.equalTo(self.authorLabel.mas_right);
        }];
        
        [self.thumbImage mas_makeConstraints:^(MASConstraintMaker *make){
            make.bottom.equalTo(self.dateLabel.mas_bottom);
            make.height.equalTo(@(imageSideLength));
            make.left.equalTo(self.contentView.mas_left).offset(imageLeftOffset);
            make.width.equalTo(@(imageSideLength));
        }];
        
        [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make){
            make.top.equalTo(self.contentView.mas_top).offset(topOffset);
            make.bottom.equalTo(self.thumbImage.mas_top).offset(-verticalInnerSpacing);
            make.left.equalTo(self.thumbImage.mas_left);
            make.right.equalTo(self.authorLabel.mas_right);
        }];
        
        
        
        
        
        /*
        [self.contentView mas_makeConstraints:^(MASConstraintMaker *make){
            make.size.equalTo(self);
            make.center.equalTo(self);
        }];

        [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make){
            make.top.equalTo(self.contentView.mas_top).offset(topOffset);
            make.bottom.equalTo(self.thumbImage.mas_top).offset(-verticalInnerSpacing);
            make.left.equalTo(self.contentView.mas_left).offset(imageLeftOffset);
            make.right.equalTo(self.contentView.mas_right).offset(-rightOffset);
        }];
        
        [self.authorLabel mas_makeConstraints:^(MASConstraintMaker *make){
            make.top.equalTo(self.abstractLabel.mas_bottom).offset(verticalInnerSpacing);
            make.bottom.equalTo(self.thumbImage.mas_bottom);//(self.contentView.mas_bottom).offset(-bottomOffset);
            make.left.equalTo(self.dateLabel.mas_right);
            make.right.equalTo(self.titleLabel.mas_right);
        }];
        
        [self.abstractLabel mas_makeConstraints:^(MASConstraintMaker *make){
            make.top.equalTo(self.titleLabel.mas_bottom).offset(verticalInnerSpacing);
            make.bottom.equalTo(self.authorLabel.mas_top).offset(-verticalInnerSpacing);
            make.left.equalTo(self.thumbImage.mas_right).offset(horizontalInnerSpacing);
            make.right.equalTo(self.titleLabel.mas_right);
        }];
        
        [self.dateLabel mas_makeConstraints:^(MASConstraintMaker *make){
            make.top.equalTo(self.authorLabel.mas_top);
            make.bottom.equalTo(self.authorLabel.mas_bottom);
            make.left.equalTo(self.abstractLabel.mas_left);
            make.right.equalTo(self.titleLabel.mas_right);
        }];
                
        [self.thumbImage mas_makeConstraints:^(MASConstraintMaker *make){
            make.left.equalTo(self.contentView.mas_left).offset(imageLeftOffset);
            make.top.equalTo(self.abstractLabel.mas_top);
            //make.bottom.equalTo(self.contentView.mas_bottom).offset(-bottomOffset);
            make.width.equalTo(@(80.f));
            make.height.equalTo(@(80.f));
        }];
        */
        
        self.didSetupConstraints = YES;
    }
    [super updateConstraints];
}

- (void)setCellContentDictionary:(BBTCampusInfo *)content
{
    self.titleLabel.text = content.title;
    self.authorLabel.text = content.content[1];
    self.abstractLabel.text = content.content[5];
    self.dateLabel.text = content.date;
    NSURL *imageURL = [NSURL URLWithString:content.content[3]];
    [self.thumbImage sd_setImageWithURL:imageURL placeholderImage:[UIImage imageNamed:@"BoBanTang"]];
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end

//
//  BBTDailyArticleTableViewCell.m
//  BoBanTang
//
//  Created by Caesar on 16/1/26.
//  Copyright © 2016年 100steps. All rights reserved.
//

#import "BBTDailyArticleTableViewCell.h"
#import "UIFont+BBTFont.h"
#import "BBTDailyArticle.h"
#import <Masonry.h>

@interface BBTDailyArticleTableViewCell ()

@property (strong, nonatomic) UILabel * titleLabel;
@property (strong, nonatomic) UILabel * abstractLabel;
@property (strong, nonatomic) UILabel * dateLabel;
@property (strong, nonatomic) UILabel * authorLabel;

@property (nonatomic) BOOL didSetupConstraints;

@end

@implementation BBTDailyArticleTableViewCell

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
            label;
        });
        
        self.abstractLabel = ({
            UILabel * label = [UILabel new];
            label.translatesAutoresizingMaskIntoConstraints = NO;
            label.lineBreakMode = NSLineBreakByTruncatingTail;
            label.textAlignment = NSTextAlignmentLeft;
            label.numberOfLines = 3;
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
        
        [self.contentView addSubview:self.titleLabel];
        [self.contentView addSubview:self.authorLabel];
        [self.contentView addSubview:self.abstractLabel];
        [self.contentView addSubview:self.dateLabel];
                
    }
    
    return self;
}

- (void)updateConstraints
{
    if (!self.didSetupConstraints)
    {
        CGFloat topOffset = 5.0f;
        CGFloat bottomOffset = 5.0f;
        CGFloat imageLeftOffset = 5.0f;
        CGFloat horizontalInnerSpacing = 3.0f;
        CGFloat verticalInnerSpacing = 3.0f;
        CGFloat rightOffset = 5.0f;
        
        [self.contentView mas_makeConstraints:^(MASConstraintMaker *make){
            make.size.equalTo(self);
            make.center.equalTo(self);
        }];
        
        [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make){
            make.top.equalTo(self.contentView.mas_top).offset(topOffset);
            make.bottom.equalTo(self.abstractLabel.mas_top).offset(verticalInnerSpacing);
            make.left.equalTo(self.contentView).offset(imageLeftOffset);
            make.right.equalTo(self.contentView.mas_right).offset(-rightOffset);
        }];
        
        [self.authorLabel mas_makeConstraints:^(MASConstraintMaker *make){
            make.bottom.equalTo(self.contentView.mas_bottom).offset(-bottomOffset);
            make.right.equalTo(self.contentView.mas_right).offset(-rightOffset);
        }];
        
        [self.abstractLabel mas_makeConstraints:^(MASConstraintMaker *make){
            make.top.equalTo(self.titleLabel.mas_bottom).offset(verticalInnerSpacing);
            make.bottom.equalTo(self.authorLabel.mas_top).offset(-verticalInnerSpacing);
            make.left.equalTo(self.titleLabel.mas_left);
            make.right.equalTo(self.contentView.mas_right).offset(-rightOffset);
        }];
        
        [self.dateLabel mas_makeConstraints:^(MASConstraintMaker *make){
            make.top.equalTo(self.abstractLabel.mas_bottom).offset(verticalInnerSpacing);
            make.bottom.equalTo(self.contentView.mas_bottom).offset(-bottomOffset);
            make.right.equalTo(self.authorLabel.mas_left).offset(-horizontalInnerSpacing);
        }];
        
        self.didSetupConstraints = YES;
    }
    [super updateConstraints];
}

- (void)setCellContentDictionary:(BBTDailyArticle *)content
{
    self.titleLabel.text = content.title;
    self.authorLabel.text = content.author;
    self.abstractLabel.text = content.article;
    self.dateLabel.text = content.date;
}

@end

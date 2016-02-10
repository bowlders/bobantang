//
//  AboutViewController.m
//  BoBanTang
//
//  Created by Caesar on 15/10/18.
//  Copyright © 2015年 BBT. All rights reserved.
//

#import "BBTAboutViewController.h"
#import "UIFont+BBTFont.h"
#import <Masonry.h>

@interface BBTAboutViewController ()

@property (strong, nonatomic) UIImageView * logoImageView;
@property (strong, nonatomic) UILabel     * productNameLabel;
@property (strong, nonatomic) UILabel     * detailFirstLineLabel;
@property (strong, nonatomic) UILabel     * detailSecondLineLabel;
@property (strong, nonatomic) UILabel     * theCopyRightLabel;
@property (strong, nonatomic) UITableView * tableView;

@end

@implementation BBTAboutViewController

- (void)viewDidLoad {
    
    self.logoImageView = ({
        UIImageView *imageView = [UIImageView new];
        imageView.translatesAutoresizingMaskIntoConstraints = NO;
        imageView.contentMode = UIViewContentModeScaleToFill;
        imageView.image = [UIImage imageNamed:@"BoBanTang"];
        imageView.alpha = 1.0;
        imageView;
    });
    
    self.productNameLabel = ({
        UILabel *label = [UILabel new];
        label.translatesAutoresizingMaskIntoConstraints = NO;
        label.numberOfLines = 1;
        label.lineBreakMode = NSLineBreakByTruncatingTail;
        label.clipsToBounds = YES;
        label.textAlignment = NSTextAlignmentCenter;
        label.adjustsFontSizeToFitWidth = NO;
        label.text = @"波板糖1.0";
        label.font = [UIFont BBTProductNameLabelFont];
        label.alpha = 1.0;
        label;
    });
    
    self.detailFirstLineLabel = ({
        UILabel *label = [UILabel new];
        label.translatesAutoresizingMaskIntoConstraints = NO;
        label.numberOfLines = 1;
        label.lineBreakMode = NSLineBreakByTruncatingTail;
        label.clipsToBounds = YES;
        label.textAlignment = NSTextAlignmentCenter;
        label.adjustsFontSizeToFitWidth = NO;
        label.text = @"华南理工大学百步梯学生创新中心";
        label.font = [UIFont BBTProductDetailLabelAndCopyRightFont];
        label.alpha = 1.0;
        label;
    });
    
    self.detailSecondLineLabel = ({
        UILabel *label = [UILabel new];
        label.translatesAutoresizingMaskIntoConstraints = NO;
        label.numberOfLines = 1;
        label.lineBreakMode = NSLineBreakByTruncatingTail;
        label.clipsToBounds = YES;
        label.textAlignment = NSTextAlignmentCenter;
        label.adjustsFontSizeToFitWidth = NO;
        label.text = @"诚意出品";
        label.font = [UIFont BBTProductDetailLabelAndCopyRightFont];
        label.alpha = 1.0;
        label;
    });
    
    self.theCopyRightLabel = ({
        UILabel *label = [UILabel new];
        label.translatesAutoresizingMaskIntoConstraints = NO;
        label.numberOfLines = 1;
        label.lineBreakMode = NSLineBreakByTruncatingTail;
        label.clipsToBounds = YES;
        label.textAlignment = NSTextAlignmentCenter;
        label.adjustsFontSizeToFitWidth = NO;
        label.text = @"Copyright I don't know";
        label.font = [UIFont BBTProductDetailLabelAndCopyRightFont];
        label.alpha = 1.0;
        label;
    });
    
    self.tableView = ({
        UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        tableView.scrollEnabled = NO;
        tableView.dataSource = self;
        tableView.delegate = self;
        tableView;
    });
    
    [self.view addSubview:self.logoImageView];
    [self.view addSubview:self.productNameLabel];
    [self.view addSubview:self.detailFirstLineLabel];
    [self.view addSubview:self.detailSecondLineLabel];
    [self.view addSubview:self.theCopyRightLabel];
    [self.view addSubview:self.tableView];
    
    CGFloat navigationBarHeight = self.navigationController.navigationBar.frame.size.height;
    CGFloat logoImageViewUpPadding = 50.0f;
    CGFloat logoImageViewSideLength = 80.0f;            //Square ImageView
    CGFloat logoImageViewBottomPadding = 40.0f;
    CGFloat productNameLabelHeight = 40.0f;
    CGFloat labelVerticalInnerSpacing = 5.0f;
    CGFloat productDetailAndCopyRightLabelHeight = 30.0f;
    CGFloat copyRightLabelBottomPadding = 40.0f;
    CGFloat tabBarHeight = self.tabBarController.tabBar.frame.size.height;
    
    //Add Constraints
    [self.logoImageView mas_makeConstraints:^(MASConstraintMaker *make){
        make.top.equalTo(self.view.mas_top).offset(navigationBarHeight + logoImageViewUpPadding);
        make.height.equalTo(@(logoImageViewSideLength));
        make.width.equalTo(@(logoImageViewSideLength));
        make.centerX.equalTo(self.view.mas_centerX);
    }];
    
    [self.productNameLabel mas_makeConstraints:^(MASConstraintMaker *make){
        make.top.equalTo(self.logoImageView.mas_bottom).offset(logoImageViewBottomPadding);
        make.height.equalTo(@(productNameLabelHeight));
        make.width.equalTo(self.view.mas_width);
        make.centerX.equalTo(self.view.mas_centerX);
    }];
    
    [self.detailFirstLineLabel mas_makeConstraints:^(MASConstraintMaker *make){
        make.top.equalTo(self.productNameLabel.mas_bottom).offset(labelVerticalInnerSpacing);
        make.height.equalTo(@(productDetailAndCopyRightLabelHeight));
        make.width.equalTo(self.view.mas_width);
        make.centerX.equalTo(self.view.mas_centerX);
    }];
    
    [self.detailSecondLineLabel mas_makeConstraints:^(MASConstraintMaker *make){
        make.top.equalTo(self.detailFirstLineLabel.mas_bottom).offset(labelVerticalInnerSpacing);
        make.height.equalTo(@(productDetailAndCopyRightLabelHeight));
        make.width.equalTo(self.view.mas_width);
        make.centerX.equalTo(self.view.mas_centerX);
    }];
    
    [self.theCopyRightLabel mas_makeConstraints:^(MASConstraintMaker *make){
        make.top.equalTo(self.detailSecondLineLabel.mas_bottom).offset(labelVerticalInnerSpacing);
        make.height.equalTo(@(productDetailAndCopyRightLabelHeight));
        make.width.equalTo(self.view.mas_width);
        make.centerX.equalTo(self.view.mas_centerX);
    }];
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make){
        make.top.equalTo(self.theCopyRightLabel.mas_bottom).offset(copyRightLabelBottomPadding);
        make.bottom.equalTo(self.view.mas_bottom).offset(-tabBarHeight);
        make.width.equalTo(self.view.mas_width);
        make.centerX.equalTo(self.view.mas_centerX);
    }];
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.01f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"aboutCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    cell.textLabel.text = @"去 App Store 评分";
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

    return cell;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

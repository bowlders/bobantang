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
#import <MBProgressHUD.h>

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
        label.text = @"波板糖";
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
        label.text = @"V4.0 Donut";
        label.font = [UIFont BBTProductDetailLabelFont];
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
        label.text = @"便捷生活 一触即达";
        label.font = [UIFont BBTProductDetailLabelFont];
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
        label.adjustsFontSizeToFitWidth = YES;
        label.text = @"Copyright © 2018 100steps Student Innovation Centre. All rights reserved.";
        label.font = [UIFont BBTCopyRightLabelFont];
        label.textColor = [UIColor grayColor];
        label.alpha = 1.0;
        label;
    });
    
    self.tableView = ({
        UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        tableView.scrollEnabled = NO;
        tableView.dataSource = self;
        tableView.delegate = self;
        tableView;
    });
    
    self.view.backgroundColor = self.tableView.backgroundColor;
    
    [self.view addSubview:self.logoImageView];
    [self.view addSubview:self.productNameLabel];
    [self.view addSubview:self.detailFirstLineLabel];
    [self.view addSubview:self.detailSecondLineLabel];
    [self.view addSubview:self.tableView];
    [self.view addSubview:self.theCopyRightLabel];
    
    CGFloat navigationBarHeight = self.navigationController.navigationBar.frame.size.height;
    CGFloat logoImageViewUpPadding = 50.0f;
    CGFloat logoImageViewSideLength = 80.0f;            //Square ImageView
    CGFloat logoImageViewBottomPadding = 40.0f;
    CGFloat productNameLabelHeight = 40.0f;
    CGFloat labelVerticalInnerSpacing = 5.0f;
    CGFloat productDetailLabelHeight = 30.0f;
    CGFloat copyRightLabelHeight = 15.0f;
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
        make.height.equalTo(@(productDetailLabelHeight));
        make.width.equalTo(self.view.mas_width);
        make.centerX.equalTo(self.view.mas_centerX);
    }];
    
    [self.detailSecondLineLabel mas_makeConstraints:^(MASConstraintMaker *make){
        make.top.equalTo(self.detailFirstLineLabel.mas_bottom).offset(labelVerticalInnerSpacing);
        make.height.equalTo(@(productDetailLabelHeight));
        make.width.equalTo(self.view.mas_width);
        make.centerX.equalTo(self.view.mas_centerX);
    }];
     
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make){
        make.top.equalTo(self.detailSecondLineLabel.mas_bottom);
        make.bottom.equalTo(self.theCopyRightLabel.mas_top).offset(-labelVerticalInnerSpacing);
        make.width.equalTo(self.view.mas_width);
        make.centerX.equalTo(self.view.mas_centerX);
    }];
    
    [self.theCopyRightLabel mas_makeConstraints:^(MASConstraintMaker *make){
        make.bottom.equalTo(self.view.mas_bottom).offset(-tabBarHeight);
        make.height.equalTo(@(copyRightLabelHeight));
        make.width.equalTo(self.view.mas_width);
        make.centerX.equalTo(self.view.mas_centerX);
    }];
    
    [super viewDidLoad];
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //Show loading hud
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    SKStoreProductViewController *storeProductVC =[[SKStoreProductViewController alloc]init];
    storeProductVC.delegate = self;
    [storeProductVC loadProductWithParameters:@{SKStoreProductParameterITunesItemIdentifier:@"625954338"} completionBlock:^(BOOL result, NSError *error) {
        if (result) {
            //Hide loading hud
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            
            [self presentViewController:storeProductVC animated:YES completion:nil];
        }else{
            NSLog(@"error:%@", error);
        }
    }];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)productViewControllerDidFinish:(SKStoreProductViewController* )viewController
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

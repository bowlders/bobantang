//
//  AboutViewController.m
//  BoBanTang
//
//  Created by Caesar on 15/10/18.
//  Copyright © 2015年 BBT. All rights reserved.
//

#import "BBTAboutViewController.h"
#import "UIFont+BBTFont.h"
#import "STScratchView.h"
#import <Masonry.h>
#import <MBProgressHUD.h>

@interface BBTAboutViewController ()

@property (strong, nonatomic) UIImageView   * logoImageView;
@property (strong, nonatomic) UILabel       * productNameLabel;
@property (strong, nonatomic) UILabel       * detailFirstLineLabel;
@property (strong, nonatomic) UILabel       * detailSecondLineLabel;
@property (strong, nonatomic) UILabel       * theCopyRightLabel;
@property (strong, nonatomic) UITableView   * tableView;
@property (strong, nonatomic) STScratchView * hiddenContainerView;
@property (strong, nonatomic) UIImageView   * surpriseView;
@property (strong, nonatomic) UIView        * scratchView;      //Actually this is the view to be scratched

@end

@implementation BBTAboutViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    CGFloat screenWidth = CGRectGetWidth(self.view.frame);
    CGFloat screenHeight = CGRectGetHeight(self.view.frame);
    CGFloat statusBarHeight = self.navigationController.navigationBar.frame.origin.y;
    CGFloat navigationBarHeight = self.navigationController.navigationBar.frame.size.height;
    CGFloat logoImageViewUpPadding = 50.0f;
    CGFloat logoImageViewSideLength = 80.0f;                    //Square ImageView
    CGFloat logoImageViewBottomPadding = 40.0f;
    CGFloat productNameLabelHeight = 40.0f;
    CGFloat labelVerticalInnerSpacing = 5.0f;
    CGFloat productDetailLabelHeight = 30.0f;
    CGFloat theCopyRightLabelHeight = 15.0f;
    CGFloat matViewHeight = 50.0f;
    CGFloat tabBarHeight = self.tabBarController.tabBar.frame.size.height;
    CGFloat logoImageViewY = statusBarHeight + navigationBarHeight + logoImageViewUpPadding;
    CGFloat productNameLabelY = logoImageViewY + logoImageViewSideLength + logoImageViewBottomPadding;
    CGFloat detailFirstLineLabelY = productNameLabelY + productDetailLabelHeight + labelVerticalInnerSpacing;
    CGFloat detailSecondLineLabelY = detailFirstLineLabelY + productDetailLabelHeight + labelVerticalInnerSpacing;
    CGFloat tableViewY = detailSecondLineLabelY + productDetailLabelHeight;
    CGFloat tableViewHeight = 100.0f;
    CGFloat matViewY = tableViewY + tableViewHeight;
    
    self.logoImageView = ({
        UIImageView *imageView = [UIImageView new];
        [imageView setFrame:CGRectMake(0.5*(screenWidth-logoImageViewSideLength), logoImageViewY, logoImageViewSideLength, logoImageViewSideLength)];
        imageView.contentMode = UIViewContentModeScaleToFill;
        imageView.image = [UIImage imageNamed:@"BoBanTang"];
        imageView.alpha = 1.0;
        imageView;
    });
    
    self.productNameLabel = ({
        UILabel *label = [UILabel new];
        [label setFrame:CGRectMake(0, productNameLabelY, screenWidth, productNameLabelHeight)];
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
        [label setFrame:CGRectMake(0, detailFirstLineLabelY, screenWidth, productDetailLabelHeight)];
        label.numberOfLines = 1;
        label.lineBreakMode = NSLineBreakByTruncatingTail;
        label.clipsToBounds = YES;
        label.textAlignment = NSTextAlignmentCenter;
        label.adjustsFontSizeToFitWidth = NO;
        label.text = @"V3.0 Blueberry";
        label.font = [UIFont BBTProductDetailLabelFont];
        label.alpha = 1.0;
        label;
    });
    
    self.detailSecondLineLabel = ({
        UILabel *label = [UILabel new];
        [label setFrame:CGRectMake(0, detailSecondLineLabelY, screenWidth, productDetailLabelHeight)];
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
    
    self.tableView = ({
        UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, tableViewY, screenWidth, tableViewHeight) style:UITableViewStyleGrouped];
        tableView.scrollEnabled = NO;
        tableView.dataSource = self;
        tableView.delegate = self;
        tableView;
    });
  
    self.surpriseView = ({
        UIImageView *surpriseView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"surprise_bg.png"]];
        [surpriseView setFrame:CGRectMake(0, matViewY, screenWidth, matViewHeight)];
        surpriseView;
    });
    
    self.scratchView = ({
        UIView *scratchView = [[UIView alloc] initWithFrame:CGRectMake(0, matViewY, screenWidth, matViewHeight)];
        scratchView.backgroundColor = self.tableView.backgroundColor;
        scratchView;
    });
    
    self.hiddenContainerView = ({
        STScratchView *view = [[STScratchView alloc] initWithFrame:CGRectMake(0, matViewY, screenWidth, matViewHeight)];
        view.backgroundColor = [UIColor clearColor];
        [view setSizeBrush:30.0f];
        [view setHideView:self.scratchView];
        view;
    });
    
    self.theCopyRightLabel = ({
        UILabel *label = [UILabel new];
        [label setFrame:CGRectMake(0, screenHeight-tabBarHeight-theCopyRightLabelHeight, screenWidth, theCopyRightLabelHeight)];
        label.numberOfLines = 1;
        label.lineBreakMode = NSLineBreakByTruncatingTail;
        label.clipsToBounds = YES;
        label.textAlignment = NSTextAlignmentCenter;
        label.adjustsFontSizeToFitWidth = YES;
        label.text = @"Copyright © 2016 100steps Student Innovation Centre. All rights reserved.";
        label.font = [UIFont BBTCopyRightLabelFont];
        label.textColor = [UIColor grayColor];
        label.alpha = 1.0;
        label;
    });

    self.view.backgroundColor = self.tableView.backgroundColor;
    
    [self.view addSubview:self.logoImageView];
    [self.view addSubview:self.productNameLabel];
    [self.view addSubview:self.detailFirstLineLabel];
    [self.view addSubview:self.detailSecondLineLabel];
    [self.view addSubview:self.tableView];
    [self.view addSubview:self.theCopyRightLabel];
    [self.view addSubview:self.surpriseView];
    [self.view addSubview:self.hiddenContainerView];

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

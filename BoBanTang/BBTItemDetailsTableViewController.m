//
//  BBTItemDetailsTableViewController.m
//  BoBanTang
//
//  Created by Hsu Tung Hui on 16/2/3.
//  Copyright © 2016年 100steps. All rights reserved.
//

#import "BBTItemDetailsTableViewController.h"
#import "BBTLAFManager.h"
#import "UIImageView+AFNetworking.h"
#import <SDImageCache.h>

@interface BBTItemDetailsTableViewController ()

@property (strong, nonatomic) IBOutlet UIImageView *thumbImage;
@property (strong, nonatomic) IBOutlet UILabel *details;
@property (strong, nonatomic) IBOutlet UILabel *date;
@property (strong, nonatomic) IBOutlet UILabel *campus;
@property (strong, nonatomic) IBOutlet UILabel *locationTitle;
@property (strong, nonatomic) IBOutlet UILabel *location;
@property (strong, nonatomic) IBOutlet UILabel *contactName;
@property (strong, nonatomic) IBOutlet UILabel *phone;
@property (strong, nonatomic) IBOutlet UILabel *otherContact;

@property (strong, nonatomic) NSMutableArray   *photos;

@end

@implementation BBTItemDetailsTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor],NSForegroundColorAttributeName,nil]];
    self.navigationController.navigationBar.tintColor=[UIColor whiteColor];
    
    if (self.lostOrFound) {
        self.locationTitle.text = @"丢失地点";
    } else {
        self.locationTitle.text = @"拾获地点";
    }
    
    NSLog(@"campus %@", self.itemDetails.campus);
    
    self.details.text = self.itemDetails.details;
    self.details.numberOfLines = 0;
    [self.details sizeToFit];
    self.details.adjustsFontSizeToFitWidth = YES;
    
    self.date.text = self.itemDetails.date;
    if ([self.itemDetails.campus intValue] == 0) {
        self.campus.text = @"北校区";
    } else {
        self.campus.text = @"南校区";
    }
    self.location.text = self.itemDetails.location;
    self.contactName.text = self.itemDetails.publisher;
    self.phone.text = self.itemDetails.phone;
    
    [self.thumbImage setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.itemDetails.thumbURL]] placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage * image) {
        NSLog(@"Pic");
        self.thumbImage.image = image;
        [self.view setNeedsLayout];
        
        self.thumbImage.userInteractionEnabled = YES;
        UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
        [self.thumbImage addGestureRecognizer:gesture];
        
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
        NSLog(@"NO PIC");
        self.thumbImage.image = [UIImage imageNamed:@"BoBanTang"];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)handleTap:(UITapGestureRecognizer *)gesture
{
    NSLog(@"Touched!");
    
    self.photos = [NSMutableArray array];
    
    [self.photos addObject:[MWPhoto photoWithURL:[NSURL URLWithString:self.itemDetails.orgPicUrl]]];
    
    MWPhotoBrowser *browser = [[MWPhotoBrowser alloc] initWithDelegate:self];
    browser.displayActionButton = YES;
    browser.enableGrid = NO;
    
    [self.navigationController pushViewController:browser animated:YES];
}

- (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser
{
    return 1;
}


- (id <MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index
{
    if (index < self.photos.count) {
        return [self.photos objectAtIndex:index];
    }
    return nil;
}
/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
*/

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

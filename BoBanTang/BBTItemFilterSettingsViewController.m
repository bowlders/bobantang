//
//  BBTItemFilterSettingsViewController.m
//  BoBanTang
//
//  Created by Hsu Tung Hui on 16/2/19.
//  Copyright © 2016年 100steps. All rights reserved.
//

#import "BBTItemFilterSettingsViewController.h"
#import "BBTItemCampusTableViewCell.h"
#import "ActionSheetPicker.h"

static NSString * campusCellIdentifier = @"BBTItemCampusTableViewCell";
static NSString * typeCellIdentifier = @"typeCell";

@interface BBTItemFilterSettingsViewController ()

@property (strong, nonatomic) NSNumber *type;

@end

@implementation BBTItemFilterSettingsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.tableView registerNib:[UINib nibWithNibName:campusCellIdentifier bundle:nil] forCellReuseIdentifier:campusCellIdentifier];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    self.type = [[NSNumber alloc] initWithInteger:0];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    BBTItemCampusTableViewCell *cell = (BBTItemCampusTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    
    NSMutableDictionary *conditions = [[NSMutableDictionary alloc] init];
    
    [conditions setObject:@(cell.campus.selectedSegmentIndex) forKey:@"campus"];
    if ([self.type integerValue] != 0) {
        [conditions setObject:@([self.type integerValue] - 1) forKey:@"type"];
    }
    
    [self.delegate BBTItemFilters:self didFinishSelectConditions:conditions];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 5.0f;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0)
    {
        BBTItemCampusTableViewCell *cell = (BBTItemCampusTableViewCell *)[tableView dequeueReusableCellWithIdentifier:campusCellIdentifier forIndexPath:indexPath];
        return cell;
    } else {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:typeCellIdentifier];
        cell.textLabel.text = @"失物类型";
        cell.detailTextLabel.text = @"全部";
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 1)
    {
        NSArray *itemTypes = [NSArray arrayWithObjects:@"全部", @"大学城一卡通", @"校园卡(绿卡)", @"钱包", @"钥匙", @"其它", nil];
        [ActionSheetStringPicker showPickerWithTitle:@"请选择类型"
                                                rows:itemTypes
                                    initialSelection:0
                                           doneBlock:^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
                                               [tableView cellForRowAtIndexPath:indexPath].detailTextLabel.text = itemTypes[selectedIndex];
                                               self.type = [NSNumber numberWithInteger:selectedIndex];
                                           }
                                         cancelBlock:^(ActionSheetStringPicker *picker) {
                                             
                                         }
                                              origin:[tableView cellForRowAtIndexPath:indexPath].detailTextLabel
         ];

    }
}

@end

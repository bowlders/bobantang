//
//  BBTScoresQueryResultsTableViewController.m
//  BoBanTang
//
//  Created by Hsu Tung Hui on 26/10/15.
//  Copyright © 2015年 BBT. All rights reserved.
//

#import "BBTScoresQueryResultsTableViewController.h"
#import <AFNetworking/AFNetworking.h>
#import "BBTScoresCell.h"

static NSString * const getScoreURL = @"http://218.192.166.167/api/jw2005/getScore.php";
static NSString * const ScoresCellIdentifire = @"BBTScoresCell";

@interface BBTScoresQueryResultsTableViewController ()

@end

@implementation BBTScoresQueryResultsTableViewController
{
    NSMutableArray *_results;
    BOOL _isLoading;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationController.navigationBar setBarTintColor: [UIColor colorWithRed:0/255.0 green:153.0/255.0 blue:204.0/255.0 alpha:1.0]];
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor],NSForegroundColorAttributeName,nil]];
    
    UINib *cellNib = [UINib nibWithNibName:ScoresCellIdentifire bundle:nil];
    [self.tableView registerNib:cellNib forCellReuseIdentifier:ScoresCellIdentifire];
    
    self.navigationItem.title = [NSString stringWithFormat:@"欢迎你，%@", self.scores.studentName];

    [self performFetchScores];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -fetch scores from desperate2005
- (void)performFetchScores
{
    _isLoading = YES;
    
    _results = [[NSMutableArray alloc] init];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    //manager.requestSerializer = [AFJSONRequestSerializer serializer];
    
    NSDictionary *parameters = @{@"account":self.scores.account,
                                 @"password":self.scores.password,
                                 //@"year":self.scores.year,
                                 //@"term":self.scores.semester
                                 };

    [manager POST:getScoreURL parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
        [self parseDictionary:responseObject];
         _isLoading = NO;
        [self.tableView reloadData];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        _isLoading = NO;
        [self.tableView reloadData];
    }];
}

- (void)parseDictionary:(NSDictionary *)responseObject
{
    NSDictionary *scoreDictionary = responseObject[@"score"];
    NSArray *array = scoreDictionary[@"passed"];
    
    [self addTitle];
    
    for (NSDictionary *resultDic in array) {
        
        BBTScores *result = [[BBTScores alloc] init];
        
        result.courseName = resultDic[@"subject"];
        result.score = [NSString stringWithFormat:@"%@", resultDic[@"grade"]];
        
        NSString *isRankingExist = [NSString stringWithFormat:@"%@", resultDic[@"ranking"]];
        if ([isRankingExist isEqualToString:@"&nbsp;"]) {
            result.ranking = @"";
        } else {
            result.ranking = [NSString stringWithFormat:@"%@", resultDic[@"ranking"]];
        }
        
        result.gradepoint = [NSString stringWithFormat:@"%@", resultDic[@"GPA"]];
        
        [_results addObject:result];
    }
    
}

- (void)addTitle
{
    BBTScores *result = [[BBTScores alloc] init];
    
    result.courseName = @"科目";
    result.score = @"分数";
    result.gradepoint = @"绩点";
    result.ranking = @"排名";
    
    [_results addObject:result];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (_isLoading) {
        return 0;
    } else {
        return [_results count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    BBTScoresCell *cell = (BBTScoresCell *)[tableView dequeueReusableCellWithIdentifier:ScoresCellIdentifire forIndexPath:indexPath];
    
    BBTScores *results = _results[indexPath.row];
    [cell configureForScores:results];
    
    return cell;
}


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

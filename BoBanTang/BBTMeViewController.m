//
//  MoreViewControllerTableViewController.m
//  BoBanTang
//
//  Created by Caesar on 15/10/13.
//  Copyright © 2015年 BBT. All rights reserved.
//

#import "BBTMeViewController.h"

static const NSInteger kBBTMeSectionIndex         = 0;
static const NSInteger kBBTSettingSectionIndex    = 1;
static const NSInteger kBBTOtherSectionIndex      = 2;

static const NSInteger kBBTMeSectionRowCount      = 1;
static const NSInteger kBBTSettingSectionRowCount = 1;
static const NSInteger kBBTOtherSectionRowCount   = 2;

@interface BBTMeViewController ()

@property (strong, nonatomic) IBOutlet AMWaveTransition *interactive;

@end

@implementation BBTMeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIBarButtonItem * shareButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(share)];
    self.navigationItem.rightBarButtonItem = shareButton;

    //Lean Cloud Settings
    AVObject *testObject = [AVObject objectWithClassName:@"TestObject"];
    [testObject setObject:@"bar" forKey:@"foo"];
    [testObject save];
    
    self.title = @"我";
    
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.scrollEnabled = NO;
    
    self.interactive = [[AMWaveTransition alloc] init];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - AMWaveNavigationController Methods

- (id<UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController
                                  animationControllerForOperation:(UINavigationControllerOperation)operation
                                               fromViewController:(UIViewController*)fromVC
                                                 toViewController:(UIViewController*)toVC
{
    
    if (operation != UINavigationControllerOperationNone)
    {
        AMWaveTransition *transition = [AMWaveTransition transitionWithOperation:operation];
        [transition setTransitionType:AMWaveTransitionTypeSubtle];
        // FIXME: 不要出现 magic number，定义 const
        [transition setDuration:1.3];
        [transition setMaxDelay:0.4];
        return [AMWaveTransition transitionWithOperation:operation];
    }
    
    return nil;

}

- (void)viewDidAppear:(BOOL)animated
{
    
    [super viewDidAppear:animated];
    [self.navigationController setDelegate:self];
    [self.interactive attachInteractiveGestureToNavigationController:self.navigationController];
    
}

- (void)viewDidDisappear:(BOOL)animated
{

    [super viewDidDisappear:animated];
    [self.interactive detachInteractiveGesture];

}

- (void)dealloc
{
    
    [self.navigationController setDelegate:nil];
    
}

#pragma mark - AMWaveTransitioning Methods

- (NSArray*)visibleCells
{
    return [self.tableView visibleCells];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    NSInteger rowsNumber = 0;
    
    switch (section) {
        case kBBTMeSectionIndex:
            rowsNumber = kBBTMeSectionRowCount;
            break;
        case kBBTSettingSectionIndex:
            rowsNumber = kBBTSettingSectionRowCount;
            break;
        case kBBTOtherSectionIndex:
            rowsNumber = kBBTOtherSectionRowCount;
            break;
        default:
            NSAssert(NO, @"Invalid section index");
    }
    
    return rowsNumber;
    
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    
    NSString *sectionTitle;
    
    switch (section) {
        case kBBTMeSectionIndex:
            sectionTitle = @"个人";
            break;
        case kBBTSettingSectionIndex:
            sectionTitle = @"设置";
            break;
        case kBBTOtherSectionIndex:
            sectionTitle = @"其他";
            break;
        default:
            NSAssert(NO, @"Invalid section index");
    }
    
    return sectionTitle;
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 50;
}


-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{

    CGRect screenBound = self.view.bounds;
    CGFloat screenHeight = screenBound.size.height;
    CGFloat footerHeight = 0.1 * screenHeight;
    return footerHeight;
    
}

-(void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section
{
    
    ((UITableViewHeaderFooterView *)view).backgroundView.backgroundColor = [[UIColor brownColor] colorWithAlphaComponent:0.3f];

}

-(void)tableView:(UITableView *)tableView willDisplayFooterView:(UIView *)view forSection:(NSInteger)section
{
    
    ((UITableViewHeaderFooterView *)view).backgroundView.backgroundColor = [UIColor clearColor];
    
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *meCellIdentifier = @"meCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:meCellIdentifier];
    
    if (!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:meCellIdentifier];
    }
    
    // FIXME: 使用 const
    if (indexPath.section == 0)
    {
        cell.textLabel.text = @"账户管理";
    }
    else if (indexPath.section == 1)
    {
        cell.textLabel.text = @"设置";
    }
    else if (indexPath.section == 2)
    {
        if (indexPath.row == 0)
        {
            cell.textLabel.text = @"意见反馈";
        }
        else if (indexPath.row == 1)
        {
            cell.textLabel.text = @"关于";
        }

    }

    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // FIXME: 使用 const
    if (indexPath.section == 0)
    {
        [self performSegueWithIdentifier:@"showAccountManage" sender:tableView];
    }
    else if (indexPath.section == 1)
    {
        [self performSegueWithIdentifier:@"showSettings" sender:tableView];
    }
    else if (indexPath.section == 2)
    {
        if (indexPath.row == 0)
        {
            LCUserFeedbackAgent *agent = [LCUserFeedbackAgent sharedInstance];
            /* title 传 nil 表示将第一条消息作为反馈的标题。 contact 也可以传入 nil，由用户来填写联系方式。*/
            [agent showConversations:self title:nil contact:@"pankobe24@vip.qq.com"];
        }
        else if (indexPath.row == 1)
        {
            [self performSegueWithIdentifier:@"showAbout" sender:tableView];
        }
    }
        
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

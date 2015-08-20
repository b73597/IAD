//
//  HighScoreTableViewController.m
//  FutBoy
//
//  Created by Hoa Nguyen Van on 8/19/15.
//  Copyright (c) 2015 Omar Davila. All rights reserved.
//

#import "HighScoreTableViewController.h"
#import "ScoreManager.h"
#import <Parse/Parse.h>

@interface HighScoreTableViewController ()
{
    NSArray* highScoreUser;
    NSArray* highScoreGlobal;
    NSArray* highScoreCurrent;
}
@end

@implementation HighScoreTableViewController

-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if(self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]){
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(scoreUpdated) name:kSCORE_UPDATED_NOTIFICATION object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self scoreUpdated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)scoreUpdated
{
    highScoreUser = [ScoreManager scoreForCurrentUser];
    highScoreGlobal = [ScoreManager scoreForGlobal];
    [self switchScoreTable:self];
}

- (IBAction)back:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:^(){}];
}
- (IBAction)switchScoreTable:(id)sender
{
    if(self.segmentedView.selectedSegmentIndex==0) highScoreCurrent = highScoreUser;
    else highScoreCurrent = highScoreGlobal;
    dispatch_async(dispatch_get_main_queue(), ^(){
        [self.tableView reloadData];
    });
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
   return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return highScoreCurrent.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    UILabel* lblName = (UILabel*)[cell viewWithTag:1000]; lblName.text = [[highScoreCurrent objectAtIndex:indexPath.row] objectForKey:@"name"];
    UILabel* lblScore = (UILabel*)[cell viewWithTag:1001]; lblScore.text = [NSString stringWithFormat:@"%@",[[highScoreCurrent objectAtIndex:indexPath.row] objectForKey:@"score"] ];
    if([(NSNumber*)[[highScoreCurrent objectAtIndex:indexPath.row] objectForKey:@"isLastAdded"] boolValue]){
        lblName.textColor = lblScore.textColor = [UIColor redColor];
    }else{
        lblName.textColor = lblScore.textColor = [UIColor blackColor];
    }
    return cell;
}

- (BOOL)shouldAutorotate
{
    return NO;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskLandscape;
}
-(UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationLandscapeRight;
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

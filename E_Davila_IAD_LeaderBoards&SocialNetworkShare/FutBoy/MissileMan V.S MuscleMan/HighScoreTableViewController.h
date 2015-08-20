//
//  HighScoreTableViewController.h
//  FutBoy
//
//  Created by Hoa Nguyen Van on 8/19/15.
//  Copyright (c) 2015 Omar Davila. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HighScoreTableViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>

@property(retain,nonatomic) IBOutlet UISegmentedControl* segmentedView;
@property(retain,nonatomic) IBOutlet UITableView* tableView;

+(void)submitScore:(long)score;

@end

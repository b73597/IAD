//
//  LoginViewController.h
//  FutBoy
//
//  Created by Omar Davila on 8/19/15.
//  Copyright (c) 2015 Omar Davila. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface LoginViewController : UIViewController

@property() long awaitingScore;

@property(retain,nonatomic) IBOutlet UITextField* txtLogin;
@property(retain,nonatomic) IBOutlet UITextField* txtPassword;

@end

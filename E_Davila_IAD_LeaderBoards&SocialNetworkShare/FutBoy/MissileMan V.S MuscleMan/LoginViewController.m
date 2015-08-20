//
//  LoginViewController.m
//  FutBoy
//
//  Created by Hoa Nguyen Van on 8/19/15.
//  Copyright (c) 2015 Omar Davila. All rights reserved.
//

#import "LoginViewController.h"
#import "HighScoreTableViewController.h"

@interface LoginViewController ()

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)doLogin:(id)sender
{
    NSString* uname = self.txtLogin.text;
    NSString* pass  = self.txtPassword.text;
    [PFUser logInWithUsernameInBackground:uname password:pass
                                    block:^(PFUser* user, NSError* err){
                                        if(user){
                                            //success, user exists, logged in
                                            [self dismissViewControllerAnimated:YES completion:^{
                                                [[NSNotificationCenter defaultCenter] postNotificationName:@"LOGGED_IN" object:nil];
                                            }];
                                        }else{
                                            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Invalid username or password" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                                            [alert show];
                                        }
                                    }];

}
-(IBAction)doRegister:(id)sender
{
    NSString* uname = self.txtLogin.text;
    NSString* pass  = self.txtPassword.text;
    PFUser* user = [[PFUser alloc] init];
    user.username = uname;
    user.password = pass;
    [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError* error){
        if(!error){
            //success, registered, logged in now
            [self dismissViewControllerAnimated:YES completion:^{
                [[NSNotificationCenter defaultCenter] postNotificationName:@"LOGGED_IN" object:nil];
            }];
        }else{
            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Error registering account" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
        }
    }];
}
-(IBAction)doCancel:(id)sender
{
    self.awaitingScore = 0;
    [self dismissViewControllerAnimated:YES completion:^{}];
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
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

//
//  GameViewController.m
//  FutBoy
//
//  Created by Omar Davila on 7/6/15.
//  Copyright (c) 2015 Omar Davila. All rights reserved.
//

#import <Parse/Parse.h>
#import <Social/Social.h>
#import "GameViewController.h"
#import "GameScene.h"
#import "MenuScene.h"
#import "InstructionScene.h"
#import "ScoreManager.h"

@implementation SKScene (Unarchive)

+ (instancetype)unarchiveFromFile:(NSString *)file {
    /* Retrieve scene file path from the application bundle */
    NSString *nodePath = [[NSBundle mainBundle] pathForResource:file ofType:@"sks"];
    /* Unarchive the file to an SKScene object */
    NSData *data = [NSData dataWithContentsOfFile:nodePath
                                          options:NSDataReadingMappedIfSafe
                                            error:nil];
    NSKeyedUnarchiver *arch = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    [arch setClass:self forClassName:@"SKScene"];
    SKScene *scene = [arch decodeObjectForKey:NSKeyedArchiveRootObjectKey];
    [arch finishDecoding];
    
    return scene;
}

@end

@interface GameViewController()
{
    int awaitingScore;
    int lastScore;
}
@property(strong) GameScene* gameScene;
@property(strong) MenuScene* menuScene;
@property(strong) InstructionScene* instructionScene;

@end

@implementation GameViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [ScoreManager updateScores];
    //register for scene changing notification
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(presentScreenNotification:) name:@"CHANGE_SCENE" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loggedin) name:@"LOGGED_IN" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showHighScore) name:@"SHOW_HIGH_SCORE" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(newScoreAdded:) name:kNOTIFICATION_NEW_SCORE object:nil];
    
    // Configure the view.
    SKView * skView = (SKView *)self.view;
    skView.showsFPS = YES;
    skView.showsNodeCount = YES;
    /* Sprite Kit applies additional optimizations to improve rendering performance */
    skView.ignoresSiblingOrder = YES;
    
    // Create and configure the scene.
    self.menuScene = [MenuScene unarchiveFromFile:@"MenuScene"];
    self.menuScene.scaleMode = SKSceneScaleModeFill;
    
    self.gameScene = [GameScene unarchiveFromFile:@"GameScene"];
    self.gameScene.scaleMode = SKSceneScaleModeFill;
    
    self.instructionScene = [InstructionScene unarchiveFromFile:@"InstructionScene"];
    self.instructionScene.scaleMode = SKSceneScaleModeFill;
    // Present the menu scene first.
    [self presentScreen:SCENE_MENU];
}
- (void)loggedin{
    NSLog(@"loggedin score %d",awaitingScore);
    if(awaitingScore>0 && [PFUser currentUser]){
        int score = awaitingScore;
        awaitingScore = 0;
        dispatch_async(dispatch_get_main_queue(), ^(){
            [self onScore:score];
        });
    }else{
        awaitingScore = 0;
    }
}
-(void)newScoreAdded:(NSNotification*)notification
{
    NSNumber* nbr = notification.object;
    int score = [nbr integerValue];
    NSLog(@"New score %d",score);
    awaitingScore = 0;
    if(![PFUser currentUser]){
        awaitingScore = score;
        [self performSegueWithIdentifier:@"login" sender:self];
    }else [self onScore:score];
}
-(void)showHighScore
{
    [self performSegueWithIdentifier:@"score" sender:self];
}
-(void)onScore:(int)score
{
    if([PFUser currentUser]){
        [ScoreManager submitScore:score];
        lastScore = score;
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"GAME OVER" message:@"Do you want to share your score?" delegate:self cancelButtonTitle:@"YES" otherButtonTitles:@"NO", nil];
        [alert show];
        //[self performSegueWithIdentifier:@"score" sender:self];
        
    }
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 0){
        if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter])
        {
            SLComposeViewController *tweetSheetOBJ = [SLComposeViewController
                                                      composeViewControllerForServiceType:SLServiceTypeTwitter];
            [tweetSheetOBJ setInitialText:[NSString stringWithFormat:@"I Scored %d on FutBoy IOS Game - %@!",lastScore,[PFUser currentUser].username]];
            [self presentViewController:tweetSheetOBJ animated:YES completion:nil];
        }else{
            [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Please login to your twitter accout in Settings?" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        }
    }else{
        [self performSegueWithIdentifier:@"score" sender:self];
    }
}
/**
 * Listener for scene changing notification
 */
- (void)presentScreenNotification: (NSNotification*)notification
{
    [self presentScreen:(int)[(NSNumber*)notification.object intValue]];
}
- (void)presentScreen: (EGameScene) scene
{
    SKView * skView = (SKView *)self.view;
    SKScene* targetScene = skView.scene;
    //and display the new scene
    switch(scene){
        case SCENE_GAMEPLAY: targetScene = self.gameScene; break;
        case SCENE_MENU: targetScene = self.menuScene; break;
        case SCENE_INSTRUCTION: targetScene = self.instructionScene; break;
    }
    if(targetScene!=skView.scene){
        [skView presentScene:targetScene transition:[SKTransition fadeWithDuration:0.5]];
    }
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
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

@end

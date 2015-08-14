//
//  GameViewController.m
//  FutBoy
//
//  Created by Omar Davila on 7/6/15.
//  Copyright (c) 2015 Omar Davila. All rights reserved.
//

#import "GameViewController.h"
#import "GameScene.h"
#import "MenuScene.h"
#import "InstructionScene.h"

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
@property(strong) GameScene* gameScene;
@property(strong) MenuScene* menuScene;
@property(strong) InstructionScene* instructionScene;

@end

@implementation GameViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //register for scene changing notification
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(presentScreenNotification:) name:@"CHANGE_SCENE" object:nil];
    
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
    return UIInterfaceOrientationLandscapeLeft;
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

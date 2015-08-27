//
//  GameViewController.h
//  FutBoy
//

//  Copyright (c) 2015 Omar Davila. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SpriteKit/SpriteKit.h>

typedef enum {
    SCENE_MENU,
    SCENE_GAMEPLAY,
    SCENE_INSTRUCTION
} EGameScene;

@interface GameViewController : UIViewController
- (void)presentScreen: (EGameScene) scene;
@end

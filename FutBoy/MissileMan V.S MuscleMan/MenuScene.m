//
//  MenuScene.m
//  FutBoy
//
//  Created by Omar Davila on 7/27/15.
//  Copyright (c) 2015 Omar Davila. All rights reserved.
//

#import "GameScene.h"
#import "MenuScene.h"

@implementation MenuScene
-(void)didMoveToView:(SKView *)view {
    //get the nodes from sks
    self.nodeCreditBackground = [self childNodeWithName:@"creditBackground"];
    self.nodeCreditBackground.hidden = YES;
}
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    if(self.nodeCreditBackground.hidden){
        //if the credit dialog hasnt been pop up, handle touch for other elements
        UITouch* touch = [touches anyObject];
        CGPoint targetLocation = [touch locationInNode:self];
        SKNode *node = [self nodeAtPoint:targetLocation];
        if([node.name isEqualToString:@"play_button"]){
            [[NSNotificationCenter defaultCenter] postNotificationName:@"CHANGE_SCENE" object:[NSNumber numberWithInt:SCENE_GAMEPLAY]];
        } else if([node.name isEqualToString:@"instruction_button"]){
            [[NSNotificationCenter defaultCenter] postNotificationName:@"CHANGE_SCENE" object:[NSNumber numberWithInt:SCENE_INSTRUCTION]];
        } else if([node.name isEqualToString:@"credit_button"]){
            //user pressed on credit button, show the credit dialog (unhide it)
            self.nodeCreditBackground.hidden = NO;
        }
    }else{
        //the credit dialog has been pop up, hide it
        self.nodeCreditBackground.hidden = YES;
    }
}
@end

//
//  InstructionScene.m
//  FutBoy
//
//  Created by Omar Davila on 7/27/15.
//  Copyright (c) 2015 Omar Davila. All rights reserved.
//

#import "InstructionScene.h"

@implementation InstructionScene
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    //just back to menu for any touch
    [[NSNotificationCenter defaultCenter] postNotificationName:@"CHANGE_SCENE" object:[NSNumber numberWithInt:SCENE_MENU]];
}
@end

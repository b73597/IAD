//
//  ScoreManager.h
//  FutBoy
//
//  Created by Omar Davila on 8/19/15.
//  Copyright (c) 2015 Omar Davila. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kSCORE_UPDATED_NOTIFICATION @"FUTBOY_SCORE_UPDATED"

@interface ScoreManager : NSObject
+(NSArray*)scoreForCurrentUser;
+(NSArray*)scoreForGlobal;
+(void)submitScore:(long)score;
+(void)updateScores;
@end

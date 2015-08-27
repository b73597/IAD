//
//  Achievement.h
//  FutBoy
//
//  Created by Omar Davila on 8/25/15.
//  Copyright (c) 2015 Omar Davila. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Achievement : NSObject
+(void)unlockAchievementNamed: (NSString*)name withMessage: (NSString*)msg;
@end

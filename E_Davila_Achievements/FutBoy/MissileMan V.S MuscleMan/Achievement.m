//
//  Achievement.m
//  FutBoy
//
//  Created by Omar Davila on 8/25/15.
//  Copyright (c) 2015 Omar Davila. All rights reserved.
//

#import "Achievement.h"
#import <Parse/Parse.h>

@implementation Achievement
+(void)notifyAchievementUnlockedWithMessage: (NSString*)msg
{
    dispatch_async(dispatch_get_main_queue(), ^(){
        UIView* rootView = [UIApplication sharedApplication].keyWindow.rootViewController.view;
        CGRect frame = rootView.frame;
        frame.size.height = 80;
        UIView* infoView = [[UIView alloc] initWithFrame:frame];
        frame.origin.y = 0;
        UILabel* infoLabel = [[UILabel alloc] initWithFrame:frame];
        infoLabel.text = msg;
        infoLabel.textAlignment = NSTextAlignmentCenter;
        infoLabel.numberOfLines = 0;
        infoLabel.textColor = [UIColor whiteColor];
        [infoView addSubview:infoLabel];
        infoView.backgroundColor = [UIColor redColor];
        [rootView.window addSubview:infoView];
        
        //slide down animation
        frame.origin.y-=80;
        infoView.frame = frame;
        frame.origin.y = 0;
        [UIView animateWithDuration:0.5 animations:^(){ infoView.frame = frame; } completion:^(BOOL finished){
                //keep it for 3 seconds
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    //slide up
                    CGRect frame2 = frame;
                    frame2.origin.y -= 80;
                    [UIView animateWithDuration:0.5 animations:^(){ infoView.frame = frame2; } completion:^(BOOL finished){
                        //remove it
                        [infoView removeFromSuperview];
                    }];
                });
            }
         ];
    });
}
+(void)unlockAchievementNamed:(NSString *)name withMessage:(NSString *)msg
{
    if([PFUser currentUser]){
        //Check if user has already completed this achievement or not
        PFQuery* query = [PFQuery queryWithClassName:@"Achievement"];
        [query whereKey:@"user" equalTo:[PFUser currentUser]];
        [query whereKey:@"achievement_name" equalTo:name];
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if(!objects.count){
                //if we cant find the record, this's the first time user unlocked this achievement
                // create it!
                PFObject* obj = [PFObject objectWithClassName:@"Achievement"];
                obj[@"user"] = [PFUser currentUser];
                obj[@"achievement_name"] = name;
                [obj saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error){
                    [self notifyAchievementUnlockedWithMessage:msg];
                }];
            }
        }];
    }
}
@end

//
//  ScoreManager.m
//  FutBoy
//
//  Created by Omar Davila on 8/19/15.
//  Copyright (c) 2015 Omar Davila. All rights reserved.
//

#import "ScoreManager.h"
#import <Parse/Parse.h>

static NSMutableArray* highScoreCurrentUser;
static NSMutableArray* highScoreAllUser;
static PFObject* lastScoreAdded;

@implementation ScoreManager
+(void)initialize
{
    highScoreAllUser = [[NSMutableArray alloc] init];
    highScoreCurrentUser = [[NSMutableArray alloc] init];
    lastScoreAdded = nil;
}
+(NSArray *)scoreForCurrentUser
{
    return [NSArray arrayWithArray:highScoreCurrentUser];
}
+(NSArray *)scoreForGlobal
{
    return [NSArray arrayWithArray:highScoreAllUser];
}
+(void)updateScores
{
    NSSortDescriptor * descriptor = [[NSSortDescriptor alloc] initWithKey:@"score"
                                                                ascending:NO];
    NSSortDescriptor * descriptor2 = [[NSSortDescriptor alloc] initWithKey:@"createdAt"
                                                                ascending:YES];
    NSArray* sortDesc = [NSArray arrayWithObjects:descriptor,descriptor2, nil];
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(){
        if([PFUser currentUser]){
            PFQuery *query = [PFQuery queryWithClassName:@"Score"];
            [query whereKey:@"user" equalTo:[PFUser currentUser]];
            [query orderByDescending:@"score"];
            [query orderBySortDescriptors:sortDesc];
            [query setLimit:10];
            NSArray* objects = [query findObjects];
            [highScoreCurrentUser removeAllObjects];
            for(int i=0;i<objects.count;i++){
                PFUser* usr = [[objects objectAtIndex:i] valueForKey:@"user"];
                [usr fetch];
                [highScoreCurrentUser addObject:[NSDictionary dictionaryWithObjectsAndKeys:
                                                 usr.username, @"name",
                                                 [[objects objectAtIndex:i] valueForKey:@"score"],@"score",
                                                 [NSNumber numberWithBool:lastScoreAdded.objectId==[[objects objectAtIndex:i] valueForKey:@"objectId"]],@"isLastAdded",
                                                 nil]];
            }
        }
        PFQuery *query = [PFQuery queryWithClassName:@"Score"];
        [query orderBySortDescriptors:sortDesc];
        [query setLimit:10];
        NSArray* objects = [query findObjects];
        [highScoreAllUser removeAllObjects];
        for(int i=0;i<objects.count;i++){
            PFUser* usr = [[objects objectAtIndex:i] valueForKey:@"user"];
            [usr fetch];
            [highScoreAllUser addObject:[NSDictionary dictionaryWithObjectsAndKeys:
                                            usr.username, @"name",
                                             [[objects objectAtIndex:i] valueForKey:@"score"],@"score",
                                            [NSNumber numberWithBool:lastScoreAdded.objectId==[[objects objectAtIndex:i] valueForKey:@"objectId"]],@"isLastAdded",
                                             nil]];
        }
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kSCORE_UPDATED_NOTIFICATION object:nil];
    });
}
+(void)submitScore:(long)score
{
    if([PFUser currentUser]){
        PFObject* s = [PFObject objectWithClassName:@"Score"];
        PFACL *postACL = [PFACL ACLWithUser:[PFUser currentUser]];
        [postACL setPublicReadAccess:YES];
        [s setACL:postACL];
        [s setObject:[PFUser currentUser] forKey:@"user"];
        [s setValue:[NSNumber numberWithLong:score] forKey:@"score"];
        [s saveInBackgroundWithBlock:^(BOOL success, NSError* error){
            if(success){
                lastScoreAdded = s;
                [self updateScores];
            }
        }];
    }
}
@end

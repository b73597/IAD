//
//  GameScene.m
//  FutBoy
//
//  Created by Omar Davila on 7/6/15.
//  Copyright (c) 2015 Omar Davila. All rights reserved.
//

#import "GameScene.h"
#import "FutBoyChar.h"


#define kLastUpdatedNone 0

#define kShootButton @"SHOOT_BTN"
#define kPauseButton @"PAUSE_BTN"
#define kMenuButton @"MENU_BTN"
#define kGoalLabel @"GOAL_LBL"
#define kScoreLabel @"SCORE_LBL"
#define kStageClear @"STAGE_CLR"
#define kANIMPlayerRunning @"running_anim"

#define kMovingAnimation 0.033
#define kBallAnimation 0.1
#define kCryingAnimation 0.5
#define kShootAnimation 0.05

//player can run 0.3 height each second
#define kPlayerRunSpeed 0.3

#define kBottomLine 0.2


enum EGameState{
    STATE_IDLE = 0,
    STATE_MOVING,
    STATE_SHOOTING,
    STATE_FINISH
};

enum ECollider{
    COL_PLAYER = 1,
    COL_ENEMY  = 2
    
};

@interface GameScene()
{
    BOOL initialized;
    CFTimeInterval lastUpdated;
    enum EGameState state;
    CGPoint targetLocation;
    CGFloat ballSpeedX, ballSpeedY;
    CGFloat gravity;
    
    int nScore, nShoots;
    int nTotalScore, nTotalGames;
    
    //add 2 variables for new scoring
    int point, point2,  additionalScore;
    
    BOOL isPausing;
}
@property(strong)    SKTextureAtlas *atlas;
@property(strong)    SKSpriteNode* player;
@property(strong)    SKSpriteNode* ball;
@property(strong)    NSMutableArray* defenders;

//add 2 labels for new scoring
@property(strong)   SKLabelNode* ballScoreLabel;
@property(strong)   SKLabelNode* specialBallScoreLabel;

@property(strong)   SKLabelNode* scoreLabel;
@property(strong)   SKLabelNode* pauseBtn;
@property(strong)   SKLabelNode* menuBtn;
@property(strong)   SKLabelNode* goalLabel;
@property(strong)   SKLabelNode* stageClearLabel;

@property(strong)   SKSpriteNode* stageClearText;
@property(strong)   SKSpriteNode* stageClearCrowd;

@property(strong)   SKSpriteNode* playerMovingArrowUp;
@property(strong)   SKSpriteNode* playerMovingArrowDown;
@property(strong)   SKSpriteNode* playerMovingArrowLeft;
@property(strong)   SKSpriteNode* playerMovingArrowRight;
@property(strong)    SKAction* playerRunAction;
@property(strong)    SKAction* playSoundKick;
@property(strong)    SKAction* playSoundStart;

@end

@implementation GameScene

-(void)didMoveToView:(SKView *)view {
    /* Setup your scene here */
    // number of success game and number of games in total
    nScore = 0; nShoots = 0;
    nTotalGames = nTotalScore = 0;
    isPausing = NO;
    
    //reset the scores
    point = point2 = 0;
    additionalScore = 0;
    
    //Do not setup the scene twice
    if(self.atlas){
        [self reset];
        return;
    }
    
    srand(time(NULL));
    
    self.physicsWorld.gravity = CGVectorMake(0,0);
    self.physicsWorld.contactDelegate = self;
    
    
    //load atlas explicitly, to avoid frame rate drop in new animations
    self.atlas = [SKTextureAtlas atlasNamed:CHARACTER_ATLAS_NAME];
    
    // load background image
    SKSpriteNode *background = [SKSpriteNode spriteNodeWithTexture:CHARACTER_TEX_BACKGROUND];
    background.anchorPoint = CGPointMake(0, 0);
    background.size = self.frame.size;
    [self addChild: background];

    
    //load btn image
    SKSpriteNode *shootBtn = [SKSpriteNode spriteNodeWithTexture:CHARACTER_TEX_BUTTONS_CONTROLS_SHOOTBUTTONSPRITE];
    shootBtn.name = kShootButton;
    shootBtn.xScale = 3.0;
    shootBtn.yScale = 3.0;
    shootBtn.anchorPoint = CGPointMake(1., .5);
    shootBtn.position = CGPointMake(self.frame.size.width,self.frame.size.height*.07);
    [self addChild: shootBtn];
    
    
    SKSpriteNode *scoreBackground = [SKSpriteNode spriteNodeWithTexture:CHARACTER_TEX_FEEDBACK_SCORE_BK];
    scoreBackground.name = kGoalLabel;
    scoreBackground.anchorPoint = CGPointMake(1., 0.);
    scoreBackground.position = CGPointMake(self.frame.size.width*.1,self.frame.size.height*.05);
    [self addChild: scoreBackground];
    
    self.stageClearText = [SKSpriteNode spriteNodeWithTexture:CHARACTER_TEX_FEEDBACK_STAGE_CLEAR];
    self.stageClearText.name = kStageClear;
    self.stageClearText.position = CGPointMake(self.frame.size.width/2,self.frame.size.height*.8);
    self.stageClearText.xScale = 1.0;
    self.stageClearText.yScale = 1.0;
    [self addChild: self.stageClearText];
    
    self.stageClearCrowd = [SKSpriteNode spriteNodeWithTexture:CHARACTER_TEX_FEEDBACK_CHEER_CROWD];
    self.stageClearCrowd.name = kStageClear;
    self.stageClearCrowd.anchorPoint = CGPointMake(.5, 0);
    self.stageClearCrowd.position = CGPointMake(self.frame.size.width*.7,self.frame.size.height*.05);
    self.stageClearCrowd.xScale = 1.0;
    self.stageClearCrowd.yScale = 1.0;
    [self addChild: self.stageClearCrowd];
    
    self.scoreLabel = [[SKLabelNode alloc] init];
    self.scoreLabel.position = CGPointMake(scoreBackground.position.x-scoreBackground.size.width/2,scoreBackground.position.y+scoreBackground.size.height/2);
    self.scoreLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeCenter;
    self.scoreLabel.verticalAlignmentMode = SKLabelVerticalAlignmentModeCenter;
    [self addChild:self.scoreLabel];
    
    self.pauseBtn = [[SKLabelNode alloc] init];
    self.pauseBtn.position = CGPointMake(view.frame.size.width*.6, self.scoreLabel.position.y);
    self.pauseBtn.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeCenter;
    self.pauseBtn.verticalAlignmentMode = SKLabelVerticalAlignmentModeCenter;
    self.pauseBtn.name = kPauseButton;
    [self addChild:self.pauseBtn];
    
    self.menuBtn = [[SKLabelNode alloc] init];
    self.menuBtn.text = @"Menu";
    self.menuBtn.position = CGPointMake(self.pauseBtn.frame.origin.x+self.pauseBtn.frame.size.width+10, self.scoreLabel.position.y);
    self.menuBtn.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeCenter;
    self.menuBtn.verticalAlignmentMode = SKLabelVerticalAlignmentModeCenter;
    self.menuBtn.name = kMenuButton;
    [self addChild:self.menuBtn];
    
    //update the labels
    self.goalLabel = [[SKLabelNode alloc] init];
    self.goalLabel.position = CGPointMake(view.frame.size.width/3, self.scoreLabel.position.y);
    self.goalLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeCenter;
    self.goalLabel.verticalAlignmentMode = SKLabelVerticalAlignmentModeCenter;
    self.goalLabel.name = kGoalLabel;
    [self addChild:self.goalLabel];
    
    
    self.ballScoreLabel = [[SKLabelNode alloc] init];
    self.ballScoreLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeLeft;
    self.ballScoreLabel.verticalAlignmentMode = SKLabelVerticalAlignmentModeTop;
    self.ballScoreLabel.fontColor = [UIColor redColor];
    self.ballScoreLabel.text = @"0";
    self.ballScoreLabel.position =        CGPointMake(self.frame.size.width*.10, self.frame.size.height*.95);
    [self addChild:self.ballScoreLabel];

    self.specialBallScoreLabel = [[SKLabelNode alloc] init];
    self.specialBallScoreLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeRight;
    self.specialBallScoreLabel.verticalAlignmentMode = SKLabelVerticalAlignmentModeTop;
    self.specialBallScoreLabel.text = @"0";
    self.specialBallScoreLabel.fontColor = [UIColor redColor];
    self.specialBallScoreLabel.position = CGPointMake(self.frame.size.width*.90, self.frame.size.height*.95);
    [self addChild:self.specialBallScoreLabel];

    // load ball sprites
    self.ball = [SKSpriteNode spriteNodeWithTexture:CHARACTER_TEX_BALLANIMATION_BALL_0];
    self.ball.xScale = self.ball.yScale = 1.5;
    [self addChild:self.ball];
    
    //set up actions to move and animate to "tap" location
    SKAction* ballMovingAnimation = [SKAction animateWithTextures:CHARACTER_ANIM_BALLANIMATION_BALL timePerFrame:kMovingAnimation];
    [self.ball runAction:[SKAction repeatActionForever:ballMovingAnimation]];

    self.playerRunAction = [SKAction repeatActionForever:[SKAction animateWithTextures:CHARACTER_ANIM_RUNANIMATION_RUN timePerFrame:kMovingAnimation]];
    
    self.defenders = [[NSMutableArray alloc] init];
    
    self.playSoundKick = [SKAction playSoundFileNamed:@"kick.mp3" waitForCompletion:NO];
    self.playSoundStart = [SKAction playSoundFileNamed:@"start.mp3" waitForCompletion:NO];
    [self reset];
}
-(void)reset
{
    additionalScore = 0;
    [self.player removeFromParent];
    self.player = [SKSpriteNode spriteNodeWithTexture:CHARACTER_TEX_RUNANIMATION_RUN_2];
    self.player.anchorPoint = CGPointMake(.5,.5);
    self.player.xScale = self.player.yScale = 2.0;
    self.player.position = CGPointMake(200, 200);
    
    self.player.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:CGSizeMake(self.player.size.width*.8,self.player.size.height*.9)];
    self.player.physicsBody.dynamic = YES;
    self.player.physicsBody.categoryBitMask = COL_PLAYER;
    self.player.physicsBody.collisionBitMask = 0;
    self.player.physicsBody.contactTestBitMask = COL_ENEMY;
    self.player.physicsBody.velocity = CGVectorMake(0, 0);
    //self.player.physicsBody.affectedByGravity = NO;
    self.player.physicsBody.usesPreciseCollisionDetection = YES;
    
    //load arrow sprite, add it to player node
    self.playerMovingArrowUp = [SKSpriteNode spriteNodeWithTexture:CHARACTER_TEX_DIRARROW_UP_ARROW];
    self.playerMovingArrowUp.position = CGPointMake(0,self.player.size.height/2);
    [self.player addChild:self.playerMovingArrowUp];
    self.playerMovingArrowDown = [SKSpriteNode spriteNodeWithTexture:CHARACTER_TEX_DIRARROW_DOWN_ARROW];
    self.playerMovingArrowDown.position = CGPointMake(0,-self.player.size.height/2);
    [self.player addChild:self.playerMovingArrowDown];
    self.playerMovingArrowLeft = [SKSpriteNode spriteNodeWithTexture:CHARACTER_TEX_DIRARROW_LEFT_ARROW];
    self.playerMovingArrowLeft.position = CGPointMake(-self.player.size.width/2,0);
    [self.player addChild:self.playerMovingArrowLeft];
    self.playerMovingArrowRight = [SKSpriteNode spriteNodeWithTexture:CHARACTER_TEX_DIRARROW_RIGHT_ARROW];
    self.playerMovingArrowRight.position = CGPointMake(self.player.size.width/2,0);
    [self.player addChild:self.playerMovingArrowRight];
    
    self.playerMovingArrowUp.hidden = YES;
    self.playerMovingArrowDown.hidden = YES;
    self.playerMovingArrowLeft.hidden = YES;
    self.playerMovingArrowRight.hidden = YES;
    
    [self addChild:self.player];
    
    lastUpdated = kLastUpdatedNone;
    state = STATE_IDLE;
    gravity = -self.frame.size.height * 0.8;
    ballSpeedX = self.frame.size.width / 4;
    ballSpeedY = 0;
    [self.player removeAllActions];
    [self playerSetIDLE];
    self.ball.position = [self ballLocationForPlayerLocation:self.player.position];
    for(SKSpriteNode* node in self.defenders) [node removeFromParent];
    [self.defenders removeAllObjects];
    for(int i=0;i<3;i++){
        [self.defenders addObject:[self createDefenderAtOffset:(0.5+.3*i/2)*self.frame.size.width]];
    }
    [self runAction:self.playSoundStart];
    [self updateScore];
    [self updatePauseBtn];
    
    self.stageClearText.hidden = YES;
    self.stageClearCrowd.hidden = YES;
}
-(void)updateScore
{
    self.scoreLabel.text = [NSString stringWithFormat:@"%d / %d",nTotalScore,nTotalGames,nil]; //nScore & nShoots
    //display the score
    if(additionalScore>0){
        self.ballScoreLabel.text = [NSString stringWithFormat:@"Point: %03d+%03d",point,additionalScore];
    }else{
        self.ballScoreLabel.text = [NSString stringWithFormat:@"Point: %03d",point];
    }
    self.specialBallScoreLabel.text = [NSString stringWithFormat:@"Double Goal: %03d",point2];
}
-(void)updatePauseStateForNode: (SKView*)node status:(BOOL)isPaused
{
    for(SKView* child in node.subviews){
        [self updatePauseStateForNode:child status:isPaused];
    }
    if([node respondsToSelector:@selector(setPaused:)])
        node.paused = isPaused;
}

-(void)updatePauseBtn
{
    if(isPausing) self.pauseBtn.text = @"Resume";
    else self.pauseBtn.text = @"Pause";
    self.menuBtn.position = CGPointMake(self.pauseBtn.frame.origin.x+self.pauseBtn.frame.size.width*2, self.menuBtn.position.y);
    if(isPausing!=self.view.paused){
        if(isPausing){
            [self.pauseBtn runAction:[SKAction runBlock:^(){ [self updatePauseStateForNode: self.view status:YES]; }]];
        }else{
            lastUpdated = kLastUpdatedNone;
            [self updatePauseStateForNode: self.view status:NO];
        }
    }
}
-(CGPoint)ballLocationForPlayerLocation: (CGPoint)loc
{
    return CGPointMake(loc.x+self.player.frame.size.width*.6, loc.y-self.player.frame.size.height*.3);
}
-(SKSpriteNode*)createDefenderAtOffset: (CGFloat)x
{
    SKSpriteNode* defender = [SKSpriteNode spriteNodeWithTexture:CHARACTER_TEX_SHOOTANIMATION_SHOOT_0];
    defender.anchorPoint = CGPointMake(.5, .5);
    defender.position = CGPointMake(x, self.frame.size.height*.5);
    defender.xScale = 2; defender.yScale = 2;
    defender.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:CGSizeMake(defender.size.width*.8,defender.size.height*.9)];
    defender.xScale = -2;
    defender.physicsBody.dynamic = YES;
    defender.physicsBody.categoryBitMask = COL_ENEMY;
    defender.physicsBody.collisionBitMask = 0;
    defender.physicsBody.contactTestBitMask = COL_PLAYER;
    defender.physicsBody.usesPreciseCollisionDetection = YES;
    defender.speed = .2+.2*(rand()%1000)/1000;
    defender.physicsBody.velocity = CGVectorMake(0, self.frame.size.height * defender.speed);
    [self addChild:defender];
    
    SKAction* defenderMovingAnimation = [SKAction animateWithTextures:CHARACTER_ANIM_RUNANIMATION_RUN timePerFrame:kBallAnimation];
    
    [defender runAction:[SKAction repeatActionForever:defenderMovingAnimation]];
    return defender;
}

-(void)playerSetIDLE
{
    if(state==STATE_MOVING) state = STATE_IDLE;
    self.player.physicsBody.velocity = CGVectorMake(0, 0);
    [self.player removeActionForKey:kANIMPlayerRunning];
    self.player.texture = CHARACTER_TEX_RUNANIMATION_RUN_2;
    self.goalLabel.text = [@"Stage " stringByAppendingFormat:@"%d-%d", nTotalGames+1, nShoots+1];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch* touch = [touches anyObject];
    targetLocation = [touch locationInNode:self];
    SKNode *node = [self nodeAtPoint:targetLocation];
    if([node.name isEqualToString:kPauseButton]){
        isPausing = !isPausing;
        [self updatePauseBtn];
        return;
    }
    if([node.name isEqualToString:kMenuButton]){
        [[NSNotificationCenter defaultCenter] postNotificationName:@"CHANGE_SCENE" object:[NSNumber numberWithInt:SCENE_MENU]];
        return;
    }
    if(isPausing || state >= STATE_SHOOTING){
        return;
    }
    if([node.name isEqualToString:kShootButton]){
        [self runAction:self.playSoundKick];
        state = STATE_SHOOTING;
        [self.player runAction:[SKAction animateWithTextures:CHARACTER_ANIM_SHOOTANIMATION_SHOOT timePerFrame:kShootAnimation]];
    }
    if(state >= STATE_MOVING) return;
    state = STATE_MOVING;
    [self.player runAction:self.playerRunAction withKey:kANIMPlayerRunning];
    
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch* touch = [touches anyObject];
    targetLocation = [touch locationInNode:self];
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if(state == STATE_FINISH){
        UITouch* touch = [touches anyObject];
        targetLocation = [touch locationInNode:self];
        SKNode *node = [self nodeAtPoint:targetLocation];
        if([node.name isEqualToString:kShootButton]){
            [self reset];
            return;
        }
    }else{
        [self playerSetIDLE];
    }
}
-(void)didBeginContact:(SKPhysicsContact *)contact
{
    if(!isPausing && state < STATE_SHOOTING){
        state = STATE_FINISH;
        self.player.physicsBody.velocity = CGVectorMake(0, 0);
        [self.player runAction:[SKAction repeatActionForever:[SKAction animateWithTextures:CHARACTER_ANIM_CRYANIMATION_CRY timePerFrame:kCryingAnimation]]];
        [self endGame:NO];
    }
}

//if finger going outside of screen, phone call comes in etc, just stop the player animation
-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self playerSetIDLE];
}
-(void)endGame: (BOOL)isWin
{
    BOOL isEndOfMatch = NO;
    int __points_saved = 0;
    nShoots ++;
    if(isWin) nScore++;
    if(isWin) self.goalLabel.text = @"GOAL!!!";
    //updating second point system
    if(isWin){
        if(self.player.position.x>self.frame.size.width*.5){
            point2+=additionalScore*2;
            point +=additionalScore*2;
        }else{
            point+=additionalScore;
        }
    }
    //win-lose states check final win per 3 shoots
    // end game, reset it
    if(nShoots == 3){
        nShoots = 0;
        __points_saved = point;
        point = point2 = 0;
        nTotalGames++;
        self.stageClearText.hidden = NO;
        //if we scored more than 2 goals, it's a win game, set the croud to be visible, and change isWin to the result of 3-match
        if(nScore>=2){
            nTotalScore++;
            self.stageClearCrowd.hidden = NO;
            isWin = YES;
            isEndOfMatch = YES;
        }else{
            isWin = NO;
        }
        [self.player removeAllActions];
        
        nScore = 0;
        
        if(isWin){
            [self.player runAction:[SKAction repeatActionForever:[SKAction animateWithTextures:CHARACTER_ANIM_SHOOTANIMATION_SHOOT timePerFrame:kShootAnimation]]];
        }else{
            [self.player runAction:[SKAction repeatActionForever:[SKAction animateWithTextures:CHARACTER_ANIM_CRYANIMATION_CRY timePerFrame:kCryingAnimation]]];
        }
    }
    
    //updating animation for the defender according to win or not
    for(SKSpriteNode* def in self.defenders){
        [def removeAllActions];
        def.physicsBody.velocity = CGVectorMake(0, 0);
        if(!isWin){
            [def runAction:[SKAction repeatActionForever:[SKAction animateWithTextures:CHARACTER_ANIM_SHOOTANIMATION_SHOOT timePerFrame:kShootAnimation]]];
        }else{
            [def runAction:[SKAction repeatActionForever:[SKAction animateWithTextures:CHARACTER_ANIM_CRYANIMATION_CRY timePerFrame:kCryingAnimation]]];
        }
    }
    [self updateScore];
    
    if(isEndOfMatch){
        [[NSNotificationCenter defaultCenter] postNotificationName:kNOTIFICATION_NEW_SCORE object:[NSNumber numberWithInteger:__points_saved]];
    }
}
-(void)update:(CFTimeInterval)currentTime {
    if(state < STATE_FINISH){
        for(SKNode* defender in self.defenders){
            if(defender.position.y <= self.frame.size.height*.2) defender.physicsBody.velocity = CGVectorMake(0, self.frame.size.height * defender.speed);
            else if(defender.position.y >= self.frame.size.height*.9) defender.physicsBody.velocity = CGVectorMake(0, -self.frame.size.height * defender.speed);
        }
    }
    if(state == STATE_SHOOTING){
        if(lastUpdated!=kLastUpdatedNone){
            self.ball.position = CGPointMake(self.ball.position.x + ballSpeedX * (currentTime-lastUpdated), self.ball.position.y + ballSpeedY * (lastUpdated-currentTime));
            ballSpeedY -= gravity * (currentTime-lastUpdated);
            if(self.ball.position.y < self.frame.size.height * kBottomLine){
                ballSpeedY = -ballSpeedY;
            }
            BOOL isWin = NO;
            enum EGameState oldState = state;
            for(SKSpriteNode* def in self.defenders){
                if(ABS(def.position.x-self.ball.position.x)<def.size.width/2 &&
                   ABS(def.position.y-self.ball.position.y)<def.size.height/2){
                    state = STATE_FINISH;
                    [self.player removeAllActions];
                    [self.player runAction:[SKAction repeatActionForever:[SKAction animateWithTextures:CHARACTER_ANIM_CRYANIMATION_CRY timePerFrame:kCryingAnimation]]];
                    isWin = NO;
                    break;
                }
            }
            if(state < STATE_FINISH){
                if(self.ball.position.x >= self.frame.size.width*.95){
                    state = STATE_FINISH;
                    isWin = YES;
                    [self.player removeAllActions];
                    
                    //displays GOAL feedback when ball >9.5/10 of screen width
                    [self.goalLabel runAction:[SKAction runBlock:^(){ [self updatePauseStateForNode: self.view status:YES]; }]];
                    
                    // displays stage clear message
                    [self.stageClearLabel runAction:[SKAction runBlock:^(){ [self updatePauseStateForNode: self.view status:YES]; }]];

                }
            }
            if(oldState!=state && state == STATE_FINISH){
                [self endGame:isWin];
            }
        }
        self.playerMovingArrowUp.hidden = YES;
        self.playerMovingArrowDown.hidden = YES;
        self.playerMovingArrowLeft.hidden = YES;
        self.playerMovingArrowRight.hidden = YES;
    } else if(state == STATE_MOVING){
        CGVector movingVector = CGVectorMake(targetLocation.x-self.player.position.x, targetLocation.y-self.player.position.y);
        self.player.physicsBody.velocity = movingVector;
        self.ball.position = [self ballLocationForPlayerLocation:self.player.position];
        additionalScore=self.player.position.x;
        [self updateScore];
        //set the visibility of the arrows according to size of the speed vector along axists
        self.playerMovingArrowUp.hidden = !(movingVector.dy > ABS(movingVector.dx) / 3);
        self.playerMovingArrowDown.hidden = !(movingVector.dy < -ABS(movingVector.dx) / 3);
        self.playerMovingArrowLeft.hidden = !(movingVector.dx < -ABS(movingVector.dy)/3);
        self.playerMovingArrowRight.hidden = !(movingVector.dx > ABS(movingVector.dy)/3);
    } else {
        self.playerMovingArrowUp.hidden = YES;
        self.playerMovingArrowDown.hidden = YES;
        self.playerMovingArrowLeft.hidden = YES;
        self.playerMovingArrowRight.hidden = YES;
    }
    lastUpdated = currentTime;
}

@end

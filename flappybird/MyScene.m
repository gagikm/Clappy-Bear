//
//  MyScene.m
//  flappybird
//
//  Created by Gagik Movsisyan on 8/23/14.
//  Copyright (c) 2014 Gagik Movsisyan. All rights reserved.
//

#import "MyScene.h"
#import "StartGameLayer.h"
#import "GameOverLayer.h"
#import "Score.h"

#define TIME 1.2
#define MINIMUM_PILLER_HEIGHT 70.0f
#define GAP_BETWEEN_TOP_AND_BOTTOM_PILLER 120.0f

#define PILLARS     @"Pillars"
#define UPWARD_PILLER @"longColorfulRoyce"//"Upward_Royce_pixelated"
#define Downward_PILLER @"colorfulroyce 2"//"Downward_Royce_pixelated"


#define BOTTOM_BACKGROUND_Z_POSITION    100
#define START_GAME_LAYER_Z_POSITION     150
#define GAME_OVER_LAYER_Z_POSITION      200


static const uint32_t pillarCategory            =  0x1 << 0;
static const uint32_t flappyBirdCategory        =  0x1 << 1;
static const uint32_t bottomBackgroundCategory  =  0x1 << 2;

static const float BG_VELOCITY = (TIME * 60);

static inline CGPoint CGPointAdd(const CGPoint a, const CGPoint b)
{
    return CGPointMake(a.x + b.x, a.y + b.y);
}

static inline CGPoint CGPointMultiplyScalar(const CGPoint a, const CGFloat b)
{
    return CGPointMake(a.x * b, a.y * b);
}

@interface MyScene() <SKPhysicsContactDelegate,
StartGameLayerDelegate,
GameOverLayerDelegate>
{
    NSTimeInterval _dt;
    float bottomScrollerHeight;
    
    BOOL _gameStarted;
    BOOL _gameOver;
    
    StartGameLayer* _startGameLayer;
    GameOverLayer* _gameOverLayer;
    
    
//    int _score;
}
@property (weak,nonatomic) IBOutlet SKView * gameView;
@property (weak,nonatomic) IBOutlet UIView * getReadyView;

@property (nonatomic) SKSpriteNode* backgroundImageNode;
@property (nonatomic) SKSpriteNode* flappyBird;

@property (nonatomic) NSTimeInterval lastSpawnTimeInterval;
@property (nonatomic) NSTimeInterval lastUpdateTimeInterval;
@property (nonatomic) NSArray* flappyBirdFrames;
@property (nonatomic) NSInteger score;

@end
@implementation MyScene
SKLabelNode * scoreLabel;
//UIView * flash;
-(id)initWithSize:(CGSize)size
{
 

    if (self = [super initWithSize:size])
    {
        //Initialize the static background
        [self initializeBackGround:size];
        
        //Initialize moving background
        [self initalizingScrollingBackground];
        
        //Initialize Bird
        [self initializeBird];
        
        [self initializeStartGameLayer];
        [self initializeGameOverLayer];
        
        //Set gravity to 0 so that bird remains in its position in start page
        self.physicsWorld.gravity = CGVectorMake(0, 0.0);
        
        //To detect collision detection
        self.physicsWorld.contactDelegate = self;
        
        _gameOver = NO;
        _gameStarted = NO;
        [self showStartGameLayer];
    }
    return self;
}

- (void) initializeBackGround:(CGSize) sceneSize
{
    int i = 0;
    if (i%2 == 0)
    self.backgroundImageNode = [SKSpriteNode spriteNodeWithImageNamed:@"UCLA_silhouette_stars"];
    else
    self.backgroundImageNode = [SKSpriteNode spriteNodeWithImageNamed:@"UC_lahouette_day"];
    i++;

    self.backgroundImageNode.size = sceneSize;
    self.backgroundImageNode.position = CGPointMake(self.backgroundImageNode.size.width/2, self.frame.size.height/2);
    [self addChild:self.backgroundImageNode];
}

//-(void)initalizingScrollingBackground
//{
//    for (int i = 0; i < 2; i++)
//    {
//        SKSpriteNode *bg = [SKSpriteNode spriteNodeWithImageNamed:@"Bottom_Scroller"];
//        bottomScrollerHeight = bg.size.height;
//        bg.position = CGPointMake(i * bg.size.width, 0);
//        bg.anchorPoint = CGPointZero;
//        bg.name = @"bg";
//        
//        [self addChild:bg];
//    }
//}



-(void)initalizingScrollingBackground
{
    
    for (int i = 0; i < 2; i++)
    {
        SKSpriteNode *bg = [SKSpriteNode spriteNodeWithImageNamed:@"Bottom_Scroller"];
        bg.zPosition = BOTTOM_BACKGROUND_Z_POSITION;
        bottomScrollerHeight = bg.size.height;
        bg.position = CGPointMake((i * bg.size.width) + (bg.size.width * 0.5f) - 1, bg.size.height * 0.5f);
        bg.name = @"bg";
        
        /*
         * Create a physics and specify its geometrical shape so that collision algorithm can work more prominently
         */
        bg.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:bg.size];
        
        //Category to which this object belongs to
        bg.physicsBody.categoryBitMask = bottomBackgroundCategory;
        
        //To notify intersection with objects
        bg.physicsBody.contactTestBitMask = flappyBirdCategory;
        
        //To detect collision with category of objects
        bg.physicsBody.collisionBitMask = 0;
        
        /*
         * Has to be explicitely mentioned. If not mentioned, bg starts moving down because of gravity.
         */
        bg.physicsBody.affectedByGravity = NO;
        [self addChild:bg];
    }
}
//- (void)initializeBird
//{
//    self.flappyBird = [SKSpriteNode spriteNodeWithImageNamed:@"Yellow_Bird_Wing_Down"];
//    self.flappyBird.position = CGPointMake(self.backgroundImageNode.size.width * 0.3f, self.frame.size.height * 0.6f);
//    
//    /*
//     * Create a physics and specify its geometrical shape so that collision algorithm
//     * can work more prominently
//     */
//    _flappyBird.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:_flappyBird.size];
//    _flappyBird.physicsBody.dynamic = YES;
//    
//    //Tell SpriteKit to detect very precise collision detection
//    _flappyBird.physicsBody.usesPreciseCollisionDetection = YES;
//    
//    //Category to which this object belongs to
//    _flappyBird.physicsBody.categoryBitMask = flappyBirdCategory;
//    
//    //To notify intersection with objects
//    _flappyBird.physicsBody.contactTestBitMask = pillarCategory;
//    
//    //To detect collision with category of objects
//    _flappyBird.physicsBody.collisionBitMask = 0;
//    
//    [self addChild:self.flappyBird];
//}

- (void)initializeBird
{
    
    NSMutableArray *flappyBirdFrames = [NSMutableArray array];
    for (int i = 0; i < 58; i++)
    {
        NSString* textureName = nil;
        switch (i)
        {
            case 0:
            {
                //                textureName = @"Yellow_Bird_Wing_Up";
                textureName = @"Clappy_Bear_Open2";         //Ahhh..
                break;
            }
            case 1:
            {
                //                textureName = @"Yellow_Bird_Wing_Straight";
                textureName = @"Clappy_Bear_Open";           //..hhh..
                
                break;
            }
            case 2:
            {
                //                textureName = @"Yellow_Bird_Wing_Down";
                textureName = @"Clappy_Bear_Open2";         //...hhh..
                
                break;
            }
                
            case 3:
            {
                //                textureName = @"Yellow_Bird_Wing_Up";
                textureName = @"Clappy_Bear_Open";         //...hhh
                break;
            }
            case 4:
            {
                //                textureName = @"Yellow_Bird_Wing_Straight";
                textureName = @"Clappy_Bear_Closed";           //1
                
                break;
            }
            case 5:
            {
                //                textureName = @"Yellow_Bird_Wing_Down";
                textureName = @"Clappy_Bear_Open";
                
                break;
            }
                
            case 6:
            {
                //                textureName = @"Yellow_Bird_Wing_Straight";
                textureName = @"Clappy_Bear_Closed";           //2
                
                break;
            }
            case 7:
            {
                //                textureName = @"Yellow_Bird_Wing_Down";
                textureName = @"Clappy_Bear_Open";
                
                break;
            }
            case 8:
            {
                //                textureName = @"Yellow_Bird_Wing_Straight";
                textureName = @"Clappy_Bear_Closed";       //3
                
                break;
            }
            case 9:
            {
                //                textureName = @"Yellow_Bird_Wing_Down";
                textureName = @"Clappy_Bear_Open";
                
                break;
            }
            case 10:
            {
                //                textureName = @"Yellow_Bird_Wing_Straight";
                textureName = @"Clappy_Bear_Closed";       //4
                
                break;
            }
            case 11:
            {
                //                textureName = @"Yellow_Bird_Wing_Down";
                textureName = @"Clappy_Bear_Open";
                
                break;
            }
            case 12:
            {
                //                textureName = @"Yellow_Bird_Wing_Straight";
                textureName = @"Clappy_Bear_Closed";       //5
                
                break;
            }
            case 13:
            {
                //                textureName = @"Yellow_Bird_Wing_Down";
                textureName = @"Clappy_Bear_Open";
                
                break;
            }
            case 14:
            {
                //                textureName = @"Yellow_Bird_Wing_Straight";
                textureName = @"Clappy_Bear_Closed";           //6
                
                break;
            }
            case 15:
            {
                //                textureName = @"Yellow_Bird_Wing_Down";
                textureName = @"Clappy_Bear_Open";
                
                break;
            }
            case 16:
            {
                //                textureName = @"Yellow_Bird_Wing_Straight";
                textureName = @"Clappy_Bear_Closed";           //7
                
                break;
            }
            case 17:
            {
                //                textureName = @"Yellow_Bird_Wing_Down";
                textureName = @"Clappy_Bear_Open";
                
                break;
            }
            case 18:
            {
                //                textureName = @"Yellow_Bird_Wing_Straight";
                textureName = @"Clappy_Bear_Closed";           //8
                
                break;
            }
            case 19:
            {
                //                textureName = @"Yellow_Bird_Wing_Down";
                textureName = @"Clappy_Bear_Open";
                
                break;
            }
            case 20:
            {
                //                textureName = @"Yellow_Bird_Wing_Down";
                textureName = @"Clappy_Bear_Right";        //U!
                
                break;
            }
            case 21:
            {
                //                textureName = @"Yellow_Bird_Wing_Straight";
                textureName = @"Clappy_Bear_Closed";           //1
                
                break;
            }
            case 22:
            {
                //                textureName = @"Yellow_Bird_Wing_Down";
                textureName = @"Clappy_Bear_Open";
                
                break;
            }
            case 23:
            {
                //                textureName = @"Yellow_Bird_Wing_Straight";
                textureName = @"Clappy_Bear_Closed";           //2
                
                break;
            }
            case 24:
            {
                //                textureName = @"Yellow_Bird_Wing_Down";
                textureName = @"Clappy_Bear_Open";
                
                break;
            }
            case 25:
            {
                //                textureName = @"Yellow_Bird_Wing_Straight";
                textureName = @"Clappy_Bear_Closed";           //3
                
                break;
            }
            case 26:
            {
                //                textureName = @"Yellow_Bird_Wing_Down";
                textureName = @"Clappy_Bear_Open";
                
                break;
            }
            case 27:
            {
                //                textureName = @"Yellow_Bird_Wing_Down";
                textureName = @"Clappy_Bear_Left";         //C!
                
                break;
            }
            case 28:
            {
                //                textureName = @"Yellow_Bird_Wing_Straight";
                textureName = @"Clappy_Bear_Closed";           //1
                
                break;
            }
            case 29:
            {
                //                textureName = @"Yellow_Bird_Wing_Down";
                textureName = @"Clappy_Bear_Open";
                
                break;
            }
            case 30:
            {
                //                textureName = @"Yellow_Bird_Wing_Straight";
                textureName = @"Clappy_Bear_Closed";           //2
                
                break;
            }
            case 31:
            {
                //                textureName = @"Yellow_Bird_Wing_Down";
                textureName = @"Clappy_Bear_Open";
                
                break;
            }
            case 32:
            {
                //                textureName = @"Yellow_Bird_Wing_Straight";
                textureName = @"Clappy_Bear_Closed";           //3
                
                break;
            }
            case 33:
            {
                //                textureName = @"Yellow_Bird_Wing_Down";
                textureName = @"Clappy_Bear_Open";
                
                break;
            }
            case 34:
            {
                //                textureName = @"Yellow_Bird_Wing_Down";
                textureName = @"Clappy_Bear_Right";         //L!
                
                break;
            }
            case 35:
            {
                //                textureName = @"Yellow_Bird_Wing_Straight";
                textureName = @"Clappy_Bear_Closed";           //1
                
                break;
            }
            case 36:
            {
                //                textureName = @"Yellow_Bird_Wing_Down";
                textureName = @"Clappy_Bear_Open";
                
                break;
            }
            case 37:
            {
                //                textureName = @"Yellow_Bird_Wing_Straight";
                textureName = @"Clappy_Bear_Closed";           //2
                
                break;
            }
            case 38:
            {
                //                textureName = @"Yellow_Bird_Wing_Down";
                textureName = @"Clappy_Bear_Open";
                
                break;
            }
            case 39:
            {
                //                textureName = @"Yellow_Bird_Wing_Straight";
                textureName = @"Clappy_Bear_Closed";           //3
                
                break;
            }
            case 40:
            {
                //                textureName = @"Yellow_Bird_Wing_Down";
                textureName = @"Clappy_Bear_Open";
                
                break;
            }
            case 41:
            {
                //                textureName = @"Yellow_Bird_Wing_Down";
                textureName = @"Clappy_Bear_Left";         //A!
                
                break;
            }
            case 42:
            {
                //                textureName = @"Yellow_Bird_Wing_Straight";
                textureName = @"Clappy_Bear_Closed";           //1
                
                break;
            }
            case 43:
            {
                //                textureName = @"Yellow_Bird_Wing_Down";
                textureName = @"Clappy_Bear_Open";
                
                break;
            }
            case 44:
            {
                //                textureName = @"Yellow_Bird_Wing_Straight";
                textureName = @"Clappy_Bear_Closed";           //2
                
                break;
            }
            case 45:
            {
                //                textureName = @"Yellow_Bird_Wing_Down";
                textureName = @"Clappy_Bear_Open";
                
                break;
            }
            case 46:
            {
                //                textureName = @"Yellow_Bird_Wing_Straight";
                textureName = @"Clappy_Bear_Closed";           //3
                
                break;
            }
            case 47:
            {
                //                textureName = @"Yellow_Bird_Wing_Down";
                textureName = @"Clappy_Bear_Open";
                
                break;
            }
            case 48:
            {
                //                textureName = @"Yellow_Bird_Wing_Down";
                textureName = @"Clappy_Bear_Right";         //U
                
                break;
            }
            case 49:
            {
                //                textureName = @"Yellow_Bird_Wing_Down";
                textureName = @"Clappy_Bear_Left";         //C
                
                break;
            }
            case 50:
            {
                //                textureName = @"Yellow_Bird_Wing_Down";
                textureName = @"Clappy_Bear_Right";         //L
                
                break;
            }
            case 51:
            {
                //                textureName = @"Yellow_Bird_Wing_Down";
                textureName = @"Clappy_Bear_Left";         //A
                
                break;
            }
            case 52:
            {
                //                textureName = @"Yellow_Bird_Wing_Down";
                textureName = @"Clappy_Bear_fistDown";
                
                break;
            }
            case 53:
                {
                    //                textureName = @"Yellow_Bird_Wing_Down";
                    textureName = @"Clappy_Bear_Right";
                    
                    break;
                }
            case 54:
                {
                    //                textureName = @"Yellow_Bird_Wing_Down";
                    textureName = @"Clappy_Bear_fistDown";
                    
                    break;
                }
            case 55:
                {
                    //                textureName = @"Yellow_Bird_Wing_Down";
                    textureName = @"Clappy_Bear_Right";         //FIGHT
                    
                    break;
                }
            case 56:
                {
                    //                textureName = @"Yellow_Bird_Wing_Down";
                    textureName = @"Clappy_Bear_fistDown";
                    
                    break;
                }
            case 57:
                {
                    //                textureName = @"Yellow_Bird_Wing_Down";
                    textureName = @"Clappy_Bear_Right";         //FIGHT
                    
                    break;
                }
            case 58:
            {
                //                textureName = @"Yellow_Bird_Wing_Down";
                textureName = @"Clappy_Bear_fistDown";
                
                break;
            }
            case 59:
            {
                //                textureName = @"Yellow_Bird_Wing_Down";
                textureName = @"Clappy_Bear_Right";         //FIGHT
                
                break;
            }
            default:
                break;
            }
        
        
        
        SKTexture* texture = [SKTexture textureWithImageNamed:textureName];
        [flappyBirdFrames addObject:texture];
    }
    
    

    [self setFlappyBirdFrames:flappyBirdFrames];
    
    self.flappyBird = [SKSpriteNode spriteNodeWithTexture:[_flappyBirdFrames objectAtIndex:1]];
    self.flappyBird.position = CGPointMake(self.backgroundImageNode.size.width * 0.3f, self.frame.size.height * 0.6f);

    /*
     * Create a physics and specify its geometrical shape so that collision algorithm
     * can work more prominently
     */
    SKSpriteNode *sprite = [SKSpriteNode spriteNodeWithImageNamed:@"Clappy_Bear_Left.png"];
    
    CGFloat offsetX = sprite.frame.size.width * sprite.anchorPoint.x;
    CGFloat offsetY = sprite.frame.size.height * sprite.anchorPoint.y;
    
    CGMutablePathRef path = CGPathCreateMutable();
    
    CGPathMoveToPoint(path, NULL, 20 - offsetX, 3 - offsetY);
    CGPathAddLineToPoint(path, NULL, 39 - offsetX, 1 - offsetY);
    CGPathAddLineToPoint(path, NULL, 59 - offsetX, 20 - offsetY);
    CGPathAddLineToPoint(path, NULL, 59 - offsetX, 29 - offsetY);
    CGPathAddLineToPoint(path, NULL, 39 - offsetX, 33 - offsetY);
    CGPathAddLineToPoint(path, NULL, 4 - offsetX, 29 - offsetY);
    CGPathAddLineToPoint(path, NULL, 4 - offsetX, 17 - offsetY);
    
    CGPathCloseSubpath(path);
    
    sprite.physicsBody = [SKPhysicsBody bodyWithPolygonFromPath:path];
    
    _flappyBird.physicsBody = [SKPhysicsBody bodyWithPolygonFromPath:path];
    //Category to which this object belongs to
    _flappyBird.physicsBody.categoryBitMask = flappyBirdCategory;
    
    //To notify intersection with objects
    _flappyBird.physicsBody.contactTestBitMask = pillarCategory | bottomBackgroundCategory;
    
    //To detect collision with category of objects
    _flappyBird.physicsBody.collisionBitMask = 0;
    
    [self addChild:self.flappyBird];
}

- (void) flyingBird
{
    
    //This is our general runAction method to make our flappy bird fly.
    [_flappyBird runAction:[SKAction repeatActionForever:
                            [SKAction animateWithTextures:_flappyBirdFrames
                                             timePerFrame:0.15f
                                                   resize:NO
                                                  restore:NO]] withKey:@"flyingFlappyBird"];
    return;
}


- (void) initializeStartGameLayer
{
    self.getReadyView.alpha = 1;

//    [self runAction:[SKAction playSoundFileNamed:@"openapp.wav" waitForCompletion:YES]];
    [self runAction:[SKAction repeatActionForever:[SKAction playSoundFileNamed:@"combinedsongs.mp3" waitForCompletion:YES]] withKey:@"fightsong"];
    _startGameLayer = [[StartGameLayer alloc]initWithSize:self.size];
    _startGameLayer.userInteractionEnabled = YES;
    _startGameLayer.zPosition = START_GAME_LAYER_Z_POSITION;
    _startGameLayer.delegate = self;

}

- (void) initializeGameOverLayer
{
    _gameOverLayer = [[GameOverLayer alloc]initWithSize:self.size];
    _gameOverLayer.userInteractionEnabled = YES;
    _gameOverLayer.zPosition = GAME_OVER_LAYER_Z_POSITION;
    _gameOverLayer.delegate = self;
}

- (void) showStartGameLayer
{
    //Remove currently exising on pillars from scene and purge them
    for (int i = self.children.count - 1; i >= 0; i--)
    {
        SKNode* childNode = [self.children objectAtIndex:i];
        if(childNode.physicsBody.categoryBitMask == pillarCategory)
        {
            [childNode removeFromParent];
        }
    }
    
    //Move Flappy Bird node to center of the scene
    self.flappyBird.position = CGPointMake(self.backgroundImageNode.size.width * 0.30f, self.frame.size.height * 0.55f);
    
    [_gameOverLayer removeFromParent];
    
    _flappyBird.hidden = NO;
    [self flyingBird];
    [self addChild:_startGameLayer];
}

- (void) showGameOverLayer
{
    //Remove currently exising on pillars from scene and purge them
    for (int i = self.children.count - 1; i >= 0; i--)
    {
        SKNode* childNode = [self.children objectAtIndex:i];
        if(childNode.physicsBody.categoryBitMask == pillarCategory)
        {
            [childNode removeAllActions];
        }
    }
    
    [_flappyBird removeAllActions];
    _flappyBird.physicsBody.velocity = CGVectorMake(0, 0);
    self.physicsWorld.gravity = CGVectorMake(0, 0.0);
    _flappyBird.hidden = NO;
    
    
    // Set scores
//    self.currentScore.text = @"%li", self.score;
//    self.bestScoreLabel.text = @"%li",(long)[Score bestScore];
    

    _gameOver = YES;
    _gameStarted = NO;
    
    _dt = 0;
    _lastUpdateTimeInterval = 0;
    _lastSpawnTimeInterval = 0;
    
    [_startGameLayer removeFromParent];
    [self addChild:_gameOverLayer];
}


- (SKSpriteNode*) createPillerWithUpwardDirection:(BOOL) isUpwards
{
    NSString* pillerImageName = nil;
    if (isUpwards)
    {
        pillerImageName = UPWARD_PILLER;
    }
    else
    {
        pillerImageName = Downward_PILLER;
    }
    
    SKSpriteNode * piller = [SKSpriteNode spriteNodeWithImageNamed:pillerImageName];
    piller.name = PILLARS;
    
    /*
     * Create a physics and specify its geometrical shape so that collision algorithm
     * can work more prominently
     */
    piller.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:piller.size];
    piller.physicsBody.dynamic = YES;
    
    //Category to which this object belongs to
    piller.physicsBody.categoryBitMask = pillarCategory;
    
    //To notify intersection with objects
    piller.physicsBody.contactTestBitMask = flappyBirdCategory;
    
    //To detect collision with category of objects. Default all categories
    piller.physicsBody.collisionBitMask = 0;
    
    /*
     * Has to be explicitely mentioned. If not mentioned, pillar starts moving down becuase of gravity.
     */
    piller.physicsBody.affectedByGravity = NO;
    
    [self addChild:piller];
    
    return piller;
}

- (void)addAPiller
{
    //Create Upward directed pillar
    SKSpriteNode* upwardPiller = [self createPillerWithUpwardDirection:YES];
    
    int minY = MINIMUM_PILLER_HEIGHT;
    int maxY = self.frame.size.height - bottomScrollerHeight - GAP_BETWEEN_TOP_AND_BOTTOM_PILLER - MINIMUM_PILLER_HEIGHT;
    int rangeY = maxY - minY;
    
    float upwardPillerY = ((arc4random() % rangeY) + minY) - upwardPiller.size.height;
    upwardPillerY += bottomScrollerHeight;
    upwardPillerY += upwardPiller.size.height * 0.5f;
    
    /*Set position of pillar start position outside the screen so that we can be
     sure that image is created before it comes inside screen visibility area
     */
    upwardPiller.position = CGPointMake(self.frame.size.width + upwardPiller.size.width/2, upwardPillerY);
    
    //Create Downward directed pillar
    SKSpriteNode* downwardPiller = [self createPillerWithUpwardDirection:NO];
    float downloadPillerY = upwardPillerY + upwardPiller.size.height + GAP_BETWEEN_TOP_AND_BOTTOM_PILLER;
    downwardPiller.position = CGPointMake(upwardPiller.position.x, downloadPillerY);
    
    /*
     * Create Upward Piller actions.
     * First action has to be the movement of pillar. Right to left.
     * Once first action is complete, remove that node from Scene
     */
    SKAction * upwardPillerActionMove = [SKAction moveTo:CGPointMake(-upwardPiller.size.width/2, upwardPillerY) duration:(TIME * 2)];
    SKAction * upwardPillerActionMoveDone = [SKAction removeFromParent];
    [upwardPiller runAction:[SKAction sequence:@[upwardPillerActionMove, upwardPillerActionMoveDone]]];
    
    // Create Downward Piller actions
    SKAction * downwardPillerActionMove = [SKAction moveTo:CGPointMake(-downwardPiller.size.width/2, downloadPillerY) duration:(TIME * 2)];
    SKAction * downwardPillerActionMoveDone = [SKAction removeFromParent];
    [downwardPiller runAction:[SKAction sequence:@[downwardPillerActionMove, downwardPillerActionMoveDone]]];
}
- (void)moveBottomScroller
{
    [self enumerateChildNodesWithName:@"bg" usingBlock: ^(SKNode *node, BOOL *stop)
     {
         SKSpriteNode * bg = (SKSpriteNode *) node;
         CGPoint bgVelocity = CGPointMake(-BG_VELOCITY -35, 0);
         CGPoint amtToMove = CGPointMultiplyScalar(bgVelocity,_dt);
         bg.position = CGPointAdd(bg.position, amtToMove);
         
         //Checks if bg node is completely scrolled of the screen, if yes then put it at the end of the other node
         if (bg.position.x -170 <= -bg.size.width)
         {
             bg.position = CGPointMake(bg.position.x + bg.size.width*2,
                                       bg.position.y);
         }
         
         [bg removeFromParent];
         [self addChild:bg];        //Ordering is not possible. so this is a hack
     }];
}



- (void)updateWithTimeSinceLastUpdate:(CFTimeInterval)timeSinceLast
{
    self.lastSpawnTimeInterval += timeSinceLast;
    if (self.lastSpawnTimeInterval > TIME)
    {
        self.lastSpawnTimeInterval = 0;
        [self addAPiller];
    }
}

- (void)update:(NSTimeInterval)currentTime
{
    if(_gameOver == NO)
    {
        if (self.lastUpdateTimeInterval)
        {
            _dt = currentTime - _lastUpdateTimeInterval;
        }
        else
        {
            _dt = 0;
        }
        
        CFTimeInterval timeSinceLast = currentTime - self.lastUpdateTimeInterval;
        self.lastUpdateTimeInterval = currentTime;
        if (timeSinceLast > TIME)
        {
            timeSinceLast = 1.0 / (TIME * 60.0);
            self.lastUpdateTimeInterval = currentTime;
        }
        
        [self moveBottomScroller];
        [self updateScore];

        
        if(_gameStarted)
        {
            [self updateWithTimeSinceLastUpdate:timeSinceLast];
        }
    }
}
#pragma mark - Update Score
- (void) updateScore
{
    [self enumerateChildNodesWithName:PILLARS usingBlock:^(SKNode *node, BOOL *stop)
     {
         if(_flappyBird.position.x > node.position.x)
         {
             node.name = @"";    //Reset the name to empty name so as to not track the pillar once it has passed beyond the bird's position
             
//             ++_score;
             self.score++;
             if(self.score/2 == 25)
             {
                 scoreLabel.fontColor = [SKColor blueColor ];

             }
             if(self.score/2 == 50)
             {
                 scoreLabel.fontColor = [SKColor greenColor ];
                 
             }
             if(self.score/2 == 75)
             {
                 scoreLabel.fontColor = [SKColor orangeColor ];
                 
             }
             if(self.score/2 == 100)
             {
                 scoreLabel.fontColor = [SKColor redColor ];
                 
             }
             
             
             /* Since there are 2 pillars(Top and bottom), we will this function will be fired 2 times.
              * So we take a reminder by dividing the current score with 2
              */
             if (self.score % 2 == 0)
             {
                 NSLog(@"Score: %ld", (long)self.score/2);
             }
             scoreLabel.text = [NSString stringWithFormat:@"%ld",(long)self.score/2];

            
             *stop = YES;    //To stop enumerating
         }
     }];
}

- (void)pillar:(SKSpriteNode *)pillar didCollideWithBird:(SKSpriteNode *)bird
{
    [self showGameOverLayer];
    
}

- (void)didBeginContact:(SKPhysicsContact *)contact
{
//    flash = [[UIView alloc] initWithFrame:self.view.frame];
//    flash.backgroundColor = [UIColor whiteColor];
//    flash.alpha = .9;
//    [self.view insertSubview:flash aboveSubview:self.view];
    
    [self shakeFrame];

    SKPhysicsBody *firstBody, *secondBody;
    
    if (contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask)
    {
        firstBody = contact.bodyA;
        secondBody = contact.bodyB;
    }
    else
    {
        firstBody = contact.bodyB;
        secondBody = contact.bodyA;
    }
    
    if ((firstBody.categoryBitMask & pillarCategory) != 0 &&
        (secondBody.categoryBitMask & flappyBirdCategory) != 0)
    {
        [self removeActionForKey:@"fightsong"];

        [self pillar:(SKSpriteNode *) firstBody.node didCollideWithBird:(SKSpriteNode *) secondBody.node];
    }
    
    else if ((firstBody.categoryBitMask & flappyBirdCategory) != 0 &&
             (secondBody.categoryBitMask & bottomBackgroundCategory) != 0)
    {
        [self removeActionForKey:@"fightsong"];

        [self flappyBird:(SKSpriteNode *)firstBody.node didCollideWithBottomScoller:(SKSpriteNode *)secondBody.node];
    }
    
    //[Score registerScore:self.score];

    
}

- (void)flappyBird:(SKSpriteNode *)bird didCollideWithBottomScoller:(SKSpriteNode *)bottomBackground
{
    [self showGameOverLayer];
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    _flappyBird.physicsBody.velocity = CGVectorMake(0, 250);
}



- (void) startGame
{
    
    [self createScore];
    _score = 0;
    _gameStarted = YES;
    
    [_startGameLayer removeFromParent];
    [_gameOverLayer removeFromParent];

    self.flappyBird.position = CGPointMake(self.backgroundImageNode.size.width * 0.3f, self.frame.size.height * 0.65f);
    
    //To have Gravity effect on Bird so that bird flys down when not tapped
    self.physicsWorld.gravity = CGVectorMake(0, -5.0);
}
- (void) createScore
{
    self.score = 0;
    scoreLabel = [SKLabelNode labelNodeWithFontNamed:@"Helvetica-Bold"];
    scoreLabel.text = @"0";
    scoreLabel.fontColor = [SKColor blackColor];
    scoreLabel.fontSize = 35;
    scoreLabel.position = CGPointMake(CGRectGetMidX(self.frame) + 1 , self.frame.size.height * 0.36f);
    scoreLabel.alpha = 1;
    [self addChild:scoreLabel];
}

- (void) shakeFrame
{
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"position"];
    [animation setDuration:0.05];
    [animation setRepeatCount:4];
    [animation setAutoreverses:YES];
    [animation setFromValue:[NSValue valueWithCGPoint:
                             CGPointMake([self.view  center].x - 4.0f, [self.view  center].y)]];
    [animation setToValue:[NSValue valueWithCGPoint:
                           CGPointMake([self.view  center].x + 4.0f, [self.view  center].y)]];
    [[self.view layer] addAnimation:animation forKey:@"position"];
}
- (void)startGameLayer:(StartGameLayer *)sender tapRecognizedOnButton:(StartGameLayerButtonType)startGameLayerButton
{
    _gameOver = NO;
    _gameStarted = YES;
    
    [scoreLabel removeFromParent];

    [self startGame];
}

- (void)gameOverLayer:(GameOverLayer *)sender tapRecognizedOnButton:(GameOverLayerButtonType)gameOverLayerButtonType
{
    _gameOver = NO;
    _gameStarted = NO;
    [self showStartGameLayer];
}




@end




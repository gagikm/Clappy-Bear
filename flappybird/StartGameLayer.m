//
//  StartGameLayer.m
//  flappybird
//
//  Created by Gagik Movsisyan on 8/24/14.
//  Copyright (c) 2014 Gagik Movsisyan. All rights reserved.
//

#import "StartGameLayer.h"

@interface StartGameLayer()
@property (nonatomic, retain) SKSpriteNode* playButton;
@end
@implementation StartGameLayer

- (id)initWithSize:(CGSize)size
{
    if(self = [super initWithSize:size])
    {
        SKSpriteNode* startGameText = [SKSpriteNode spriteNodeWithImageNamed:@"ClappyBearText"];
        startGameText.position = CGPointMake(size.width * 0.5f, size.height * 0.8f);
        [self addChild:startGameText];
        
        SKSpriteNode* playButton = [SKSpriteNode spriteNodeWithImageNamed:@"taptap"];
        playButton.position = CGPointMake(size.width * 0.5f, size.height * 0.55f);
        [self addChild:playButton];
        
        [self setPlayButton:playButton];
    }
    
    return self;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInNode:self];
    
    if ([_playButton containsPoint:location])
    {
        if([self.delegate respondsToSelector:@selector(startGameLayer:tapRecognizedOnButton:)])
        {
            [self.delegate startGameLayer:self tapRecognizedOnButton:StartGameLayerPlayButton];
        }
    }
}

@end
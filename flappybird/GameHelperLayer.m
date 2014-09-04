//
//  GameHelperLayer.m
//  flappybird
//
//  Created by Gagik Movsisyan on 8/24/14.
//  Copyright (c) 2014 Gagik Movsisyan. All rights reserved.
//

#import "GameHelperLayer.h"

@implementation GameHelperLayer

- (id)initWithSize:(CGSize)size
{
    self = [super init];
    if (self)
    {
        SKSpriteNode *node = [SKSpriteNode spriteNodeWithColor:[UIColor colorWithWhite:1.0 alpha:0.0] size:size];
        node.anchorPoint = CGPointZero;
        [self addChild:node];
        node.zPosition = -1;
        node.name = @"transparent";
    }
    return self;
}

@end

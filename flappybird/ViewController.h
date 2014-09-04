//
//  ViewController.h
//  flappybird
//

//  Copyright (c) 2014 Gagik Movsisyan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SpriteKit/SpriteKit.h>
#import <iAd/iAd.h>


@interface ViewController : UIViewController <ADBannerViewDelegate>
@property (weak,nonatomic) IBOutlet UILabel * currentScore;
@property (weak,nonatomic) IBOutlet UILabel * bestScoreLabel;

@end

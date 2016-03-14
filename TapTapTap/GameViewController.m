//
//  GameViewController.m
//  TapTapTap
//
//  Created by Anasue on 10/21/15.
//  Copyright (c) 2015 Anasue. All rights reserved.
//

#import "GameViewController.h"
#import "GameScene.h"
#import "AFViewShaker.h"

@import AVFoundation;

@interface SKScene ()
@property (nonatomic,weak) AVAudioEngine * backgroundMusicPlayer;

@end


@implementation SKScene (Unarchive)

+ (instancetype)unarchiveFromFile:(NSString *)file {
    /* Retrieve scene file path from the application bundle */
    NSString *nodePath = [[NSBundle mainBundle] pathForResource:file ofType:@"sks"];
    /* Unarchive the file to an SKScene object */
    NSData *data = [NSData dataWithContentsOfFile:nodePath
                                          options:NSDataReadingMappedIfSafe
                                            error:nil];
    NSKeyedUnarchiver *arch = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    [arch setClass:self forClassName:@"SKScene"];
    SKScene *scene = [arch decodeObjectForKey:NSKeyedArchiveRootObjectKey];
    [arch finishDecoding];
    
    return scene;
}

@end

@implementation GameViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    NSError *error;
    NSURL * backgroundMusicURL = [[NSBundle mainBundle] URLForResource:@"background-music-aac" withExtension:@"caf"];
        AVAudioEngine * backgroundMusicPlayer = [[AVAudioEngine alloc] init];
//        backgroundMusicPlayer.numberOfLoops = -1;
//        [backgroundMusicPlayer prepareToPlay];
//        [self.backgroundMusicPlayer play];
    
    
    // Configure the view.
    SKView * skView = (SKView *)self.view;
    skView.showsFPS = YES;
    skView.showsNodeCount = YES;
    /* Sprite Kit applies additional optimizations to improve rendering performance */
    skView.ignoresSiblingOrder = YES;
    
    // Create and configure the scene.
    GameScene *scene = [GameScene unarchiveFromFile:@"GameScene"];
    scene.scaleMode = SKSceneScaleModeAspectFill;
    [skView presentScene:scene];
}

//- (BOOL)shouldAutorotate
//{
//    return YES;
//}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return UIInterfaceOrientationMaskAllButUpsideDown;
    } else {
        return UIInterfaceOrientationMaskAll;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)shake
{
    AFViewShaker * viewShaker = [[AFViewShaker alloc] initWithView:self.view];
    [viewShaker shakeWithDuration:0.6 completion:^{
    }];
}

@end

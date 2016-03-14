//
//  GameScene.m
//  TapTapTap
//
//  Created by Anasue on 10/21/15.
//  Copyright (c) 2015 Anasue. All rights reserved.
//
#import <UIKit/UIKit.h>
#import "GameScene.h"
#import "AFViewShaker.h"

typedef NS_ENUM(NSInteger, GameState) {
    GameStateStart = 0,
    GameStateRuning,
    GameStateOver,
    GameStateNextLevel
};

@interface GameScene()<SKPhysicsContactDelegate,SKSceneDelegate>
{
    UIColor *_currentColor;
}
@property (nonatomic, strong) SKSpriteNode *circle;
@property (nonatomic, strong) SKSpriteNode *stick;
@property (nonatomic, strong) SKSpriteNode *dot;
@property (nonatomic, assign,getter=movingClockwise) BOOL moveClockwise;
@property (nonatomic, strong) UIBezierPath *path;
/**
 *  判断是否相撞
 */
@property (nonatomic, assign,getter=isintersected) BOOL intersected;
@property (nonatomic, weak) UILabel *label;
@property (nonatomic, weak) UILabel *level;
@property (nonatomic, assign) int index;
@property (nonatomic, assign) int newLevel;
@property (nonatomic, strong) SKSpriteNode *lockView;
@property (nonatomic, assign) GameState gameState;
@end

@implementation GameScene

-(void)didMoveToView:(SKView *)view {
    
    [self loadView];
    self.index = 1;
    self.newLevel = 1;
    self.gameState = GameStateStart;
    [self addLabel];
    _currentColor = self.backgroundColor;
}

#pragma mark - 添加控件
- (void)loadView
{
    //添加中心圆
    SKSpriteNode *circle = [[SKSpriteNode alloc]initWithImageNamed:@"Circle"];
    circle.size = CGSizeMake(300, 300);
    circle.position = CGPointMake(self.frame.size.width * 0.5, self.frame.size.height * 0.5);
    [self addChild:circle];
    self.circle = circle;
    //添加棍子
    SKSpriteNode *stick = [[SKSpriteNode alloc]initWithImageNamed:@"Person"];
    stick.size = CGSizeMake(40, 9);
    stick.position = CGPointMake(self.frame.size.width * 0.5, self.frame.size.height * 0.5 + 120);
    stick.zRotation = 3.14 / 2;
    stick.zPosition = 2.0;
    [self addChild:stick];
    self.stick = stick;
    //添加圆点
    [self addDot];
    //添加锁
    SKSpriteNode *lockView = [[SKSpriteNode alloc]initWithImageNamed:@"Lock"];
    lockView.size = CGSizeMake(225, 225);
    lockView.position = CGPointMake(self.frame.size.width * 0.5, self.frame.size.height * 0.5 + 200);
    [self addChild:lockView];
    self.lockView = lockView;
}

- (void)addLabel
{
    //添加游戏关数
    UILabel *label = [[UILabel alloc]init];
    if (self.gameState == GameStateNextLevel) {
        if (self.newLevel > self.index) {
            label.text = [NSString stringWithFormat:@"%d",self.newLevel];
            }
        }else{
            label.text = [NSString stringWithFormat:@"%d",self.index];
    }
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont fontWithName:@"ArialRoundedMTBold" size:90];
    label.textColor = [UIColor whiteColor];
    CGFloat labelW = 110;
    CGFloat labelH = 110;
    CGFloat labelX = (self.view.frame.size.width * 0.5 - labelW * 0.5);
    CGFloat labelY = (self.view.frame.size.height * 0.5 - labelH * 0.5);
    label.frame = CGRectMake(labelX, labelY, labelW, labelH);
    [self.view addSubview:label];
    self.label = label;
    
    //添加关数
    UILabel *level = [[UILabel alloc]init];
    level.text = [NSString stringWithFormat:@"Level: %@",self.label.text];
    level.font = [UIFont fontWithName:@"ArialRoundedMTBold" size:30];
    level.textColor = [UIColor whiteColor];
    CGFloat levelX = 10;
    CGFloat levelY = -5;
    CGFloat levelW = 150;
    CGFloat levelH = 100;
    level.frame = CGRectMake(levelX, levelY, levelW, levelH);
    [self.view addSubview:level];
    self.level = level;
}

- (void)addDot
{
    SKSpriteNode *dot = [[SKSpriteNode alloc]initWithImageNamed:@"Dot"];
    dot.size = CGSizeMake(30, 30);
    dot.zPosition = 0.5;
    CGFloat dx = self.stick.position.x - self.frame.size.width * 0.5;
    CGFloat dy = self.stick.position.y - self.frame.size.height * 0.5;
    CGFloat rad = atan2f(dy, dx);
    if (self.moveClockwise == YES) {
        CGFloat tempAngle = [self randomWithMin:(rad + 1.0) Max:(rad + 2.5)];
        UIBezierPath *path2 = [UIBezierPath bezierPathWithArcCenter:CGPointMake(self.frame.size.width * 0.5, self.frame.size.height * 0.5) radius:120 startAngle:-tempAngle endAngle:tempAngle + (CGFloat)(M_PI * 4)clockwise:YES];
        dot.position = path2.currentPoint;
    }else if (self.moveClockwise == NO){
        CGFloat tempAngle = [self randomWithMin:(rad - 1.0) Max:(rad - 2.5)];
        UIBezierPath *path2 = [UIBezierPath bezierPathWithArcCenter:CGPointMake(self.frame.size.width * 0.5, self.frame.size.height * 0.5) radius:120 startAngle:-tempAngle endAngle:tempAngle + (CGFloat)(M_PI * 4)clockwise:YES];
        dot.position = path2.currentPoint;
    }
    [self addChild:dot];
    self.dot = dot;
}

#pragma mark - 点击事件
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    switch (self.gameState) {
        case GameStateStart:{
            CGFloat dotCenterX = self.dot.position.x;
            CGFloat stickCenterX = self.stick.position.x;
            if (dotCenterX > stickCenterX) {
                [self moveClockWise];
            }else if (dotCenterX < stickCenterX){
                [self moveClockBack];
            }
            self.moveClockwise = YES;
        }
            break;
        case GameStateRuning:{
            [self dotTouched];
        }
            break;
        case GameStateOver:{
            [self removeAllActions];
            [self reloadGame];
        }
            break;
        case GameStateNextLevel:{
            [self removeAllActions];
            [self nextLevel];
        }
            break;
            
        default:
            break;
    }
}

#pragma mark - 杆子转动
/**
 *  顺时针转动
 */
- (void)moveClockWise
{
    self.gameState = GameStateRuning;
    self.moveClockwise = YES;
    CGFloat dx = self.stick.position.x - self.frame.size.width * 0.5;
    CGFloat dy = self.stick.position.y - self.frame.size.height * 0.5;
    CGFloat rad = atan2f(dy, dx);
    self.path = [UIBezierPath bezierPathWithArcCenter:CGPointMake(self.frame.size.width * 0.5, self.frame.size.height * 0.5) radius:120 startAngle:rad endAngle:rad +(CGFloat)(M_PI *4)  clockwise:YES];
    SKAction *action = [SKAction followPath:self.path.CGPath asOffset:NO orientToPath:YES speed:250];
    [self.stick runAction:[SKAction repeatActionForever:action].reversedAction];
}

/**
 *  逆时针转动
 */
- (void)moveClockBack
{
    self.gameState = GameStateRuning;
    self.moveClockwise = NO;
    CGFloat dx = self.stick.position.x - self.frame.size.width * 0.5;
    CGFloat dy = self.stick.position.y - self.frame.size.height * 0.5;
    CGFloat rad = atan2f(dy, dx);
    self.path = [UIBezierPath bezierPathWithArcCenter:CGPointMake(self.frame.size.width * 0.5, self.frame.size.height * 0.5) radius:120 startAngle:rad endAngle:rad +(CGFloat)(M_PI *4)  clockwise:YES];
    SKAction *action = [SKAction followPath:self.path.CGPath asOffset:NO orientToPath:YES speed:250];
    [self.stick runAction:[SKAction repeatActionForever:action]];
}

#pragma mark - 杆子与球相撞
- (void)dotTouched
{
    if (self.intersected == YES) {
        self.intersected = NO;
        [self.dot removeFromParent];
        [self addDot];
        if (self.moveClockwise == YES) {
            [self moveClockBack];
            self.moveClockwise = NO;
        }else if (self.moveClockwise == NO){
            [self moveClockWise];
            self.moveClockwise = YES;
        }
        //改变数字
        self.newLevel--;
        self.label.text = [NSString stringWithFormat:@"%d",self.newLevel];
        if (self.newLevel <= 0) {
            self.gameState = GameStateNextLevel;
            [self gameover];
        }
    }else{
        self.intersected = YES;
        [self gameWrong];
    }
}

- (void)update:(NSTimeInterval)currentTime
{
    if ([self.stick intersectsNode:self.dot]) {
        self.intersected = YES;
        }else {
            if (self.intersected == YES) {
                if (![self.stick intersectsNode:self.dot]) {
                    [self shake];
                    [self gameWrong];
            }
        }
    }
}

- (void)gameWrong
{
    self.gameState = GameStateOver;
    [self.stick removeAllActions];
    self.backgroundColor = [UIColor colorWithRed:235/255.0 green:69/255.0 blue:84/255.0 alpha:1.0];
    [self shake];
}

- (void)gameover
{
    [self.stick removeAllActions];
    [UIView animateWithDuration:1.5 delay:5.0 usingSpringWithDamping:0.2 initialSpringVelocity:10 options:UIViewAnimationOptionAllowAnimatedContent animations:^{
        [self.dot removeFromParent];
        self.lockView.position = CGPointMake(self.frame.size.width * 0.5, self.frame.size.height * 0.5 + 260);
    } completion:^(BOOL finished) {
    }];
}

/**
 *  下一关
 */
- (void)nextLevel
{
    [self removeAllChildren];
    [self.label removeFromSuperview];
    [self.level removeFromSuperview];
    self.moveClockwise = NO;
    self.intersected = NO;
    [self loadView];
    self.index ++;
    self.newLevel +=self.index;
    [self addLabel];
    self.label.text = [NSString stringWithFormat:@"%d",self.newLevel];
    self.level.text = [NSString stringWithFormat:@"Level: %@",self.label.text];
    if ((self.newLevel  - 1)% 5 == 0) {
        self.backgroundColor = [SKColor colorWithRed:arc4random_uniform(256)/255.0 green:arc4random_uniform(256)/255.0 blue:arc4random_uniform(256)/255.0 alpha:1.0];
        _currentColor = self.backgroundColor;
    }else{
        self.backgroundColor = _currentColor;
    }
    self.gameState = GameStateStart;
}

/**
 *  重启游戏
 */
- (void)reloadGame
{
    [self removeAllChildren];
    [self.label removeFromSuperview];
    [self.level removeFromSuperview];
    self.moveClockwise = NO;
    self.intersected = NO;
    [self loadView];
    [self addLabel];
    if (self.newLevel < self.index) {
        self.label.text = [NSString stringWithFormat:@"%d",self.index];
        self.newLevel = self.index;
    }else{
        self.label.text = [NSString stringWithFormat:@"%d",self.newLevel];
    }
    self.gameState = GameStateStart;
    self.backgroundColor = _currentColor;
}



#pragma mark - 私有方法
- (CGFloat)randomWithMin:(CGFloat)min Max:(CGFloat)max
{
    CGFloat random = (CGFloat)arc4random()/0xFFFFFFFF;
    return random *(max - min) + min;
}

- (void)shake
{
    AFViewShaker * viewShaker = [[AFViewShaker alloc] initWithView:self.view];
    [viewShaker shakeWithDuration:0.6 completion:^{
    }];
}



- (void)shakeNode: (SKNode *)node {
    
    // Reset the camera's position
    
    node.position = CGPointZero;
    
    // Cancel any existing shake actions
    
    [node removeActionForKey:@"shake"];
    
    // The number of individual movements that the shake will be made up of
    
    int shakeSteps = 15;
    
    // How "big" the shake is
    
    float shakeDistance = 20;
    
    // How long the shake should go on for
    
    float shakeDuration = 0.25;
    
    // An array to store the individual movement in
    
    NSMutableArray *shakeActions = [NSMutableArray array];
    
    // Start at shakeSteps, and step down to 0
    
    for (int i = shakeSteps; i > 0; i-- ) {
        
        // How long this specific shake movement will take
        
        float shakeMovementDuration = shakeDuration / shakeSteps;
        
        float shakeAmount = i / (float)shakeSteps;
        
        CGPoint shakePositon = node.position;
        
        shakePositon.x += (arc4random_uniform(shakeDistance *2) - shakeDistance) * shakeAmount;
        
        shakePositon.y += (arc4random_uniform(shakeDistance * 2)- shakeDistance) * shakeAmount;
        
        
        SKAction * shakeMovementAction = [SKAction moveTo:shakePositon duration:shakeMovementDuration];
        
        
        [shakeActions addObject:shakeMovementAction];
        
        
    }
    
    
    SKAction * shakeSequence = [SKAction sequence: shakeActions];
    
    
    [node runAction: shakeSequence withKey:@"shake"];
    
    
}


// 在这个方法中，添加点东西。
-(id)initWithSize:(CGSize)size {
    
    
    if (self = [super initWithSize:size]) {
        
        /* Setup your scene here */
        // [self addChild:myLabel]; 　// 把这一句注释掉，不然会出错。因为等会要把myLabel这
        //个node 加入cameraNode. 不能同时成为两个人的孩子吧！ 开始添加东西了。
        
        
        
        SKNode *cameraNode = [[SKNode alloc]init];//创建一个空的SKNode 对象
        [cameraNode addChild:self.lockView]; //如果scene中还有其它的node，都加入到cameraNode//中来，一起摇。
        [self addChild: cameraNode];//cameraNode 加入到myScene
        [self shakeNode:cameraNode]; // 让我们摇摆吧。
        
        
    }
    
    
    return self;
    
    
    
}



@end
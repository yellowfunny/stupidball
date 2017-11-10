//
//  GameViewController.m
//  StupidBall
//
//  Created by Funny LI on 28/10/2016.
//  Copyright © 2016 Funny LI. All rights reserved.
//

#import "GameViewController.h"

@interface GameViewController ()

@property (strong, nonatomic) UIView *ball;
@property (strong, nonatomic) UIView *leftTunnel1;
@property (strong, nonatomic) UIView *leftTunnel2;
@property (strong, nonatomic) UIView *rightTunnel1;
@property (strong, nonatomic) UIView *rightTunnel2;

@property (strong, nonatomic) NSTimer *fallingTimer;
@property (strong, nonatomic) NSTimer *risingTimer;
@property (strong, nonatomic) NSTimer *shiftingTimer;

@property (weak, nonatomic) IBOutlet UILabel *scoreLabel;
@property (weak, nonatomic) IBOutlet UILabel *tapLabel;
@property (weak, nonatomic) IBOutlet UILabel *bestScoreLabel;
@property (weak, nonatomic) IBOutlet UILabel *gameOverLabel;
@property (weak, nonatomic) IBOutlet UIButton *restartButton;



@property (strong, nonatomic) NSMutableArray *tunnels;

@end

@implementation GameViewController

float deltaX = 0;
float deltaY = 0;
float ACCELERATION_FACTOR = 18.0;

const int SCORE_LABEL_HEIGHT = 45;
const float GRAVITY = 2;
const float IMPULSE = 75;

CGFloat SCREEN_HEIGHT;
CGFloat SCREEN_WIDTH;
CGFloat TUNNEL_HEIGHT;
CGFloat TUNNEL_WIDTH;
CGFloat RADIUS;

float minGapDistance;
float tunnelSpeed = 4.0;

bool isFirstTap = YES;
bool isPassed_1 = NO;
bool isPassed_2 = NO;
float speed_t1 = 0.0;
float speed_t2 = 0.0;
int direction_t1;
int direction_t2;
int totalScore = 0;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    SCREEN_WIDTH = [UIScreen mainScreen].bounds.size.width;
    SCREEN_HEIGHT = [UIScreen mainScreen].bounds.size.height;
    
    TUNNEL_WIDTH = SCREEN_WIDTH;
    TUNNEL_HEIGHT = SCREEN_HEIGHT * 0.03;
    
    RADIUS = SCREEN_HEIGHT * 0.025;
    
    minGapDistance = RADIUS * 4.5;
    
    self.gameOverLabel.hidden = YES;
    self.bestScoreLabel.hidden = YES;
    self.restartButton.hidden = YES;
    
    [self initBall];
    [self initTunnels];
    [self startAccelerometer];
}

-(BOOL)prefersStatusBarHidden{
    return YES;
}

#pragma mark - Init
- (void)initBall{
    _ball = [[UIView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/2 - RADIUS, SCREEN_HEIGHT/5,RADIUS*2,RADIUS*2)];
    
    _ball.alpha = 0.5;
    _ball.layer.cornerRadius = RADIUS;
    _ball.backgroundColor = [UIColor blackColor];
    [self.view addSubview:_ball];
    
}

- (void)initTunnels{
    
    _leftTunnel1 = [[UIView alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT + TUNNEL_HEIGHT, TUNNEL_WIDTH, TUNNEL_HEIGHT)];
    _leftTunnel2 = [[UIView alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT + TUNNEL_HEIGHT + SCREEN_HEIGHT/2, TUNNEL_WIDTH, TUNNEL_HEIGHT)];
    
    _rightTunnel1 = [[UIView alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT + TUNNEL_HEIGHT, TUNNEL_WIDTH, TUNNEL_HEIGHT)];
    _rightTunnel2 = [[UIView alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT + TUNNEL_HEIGHT + SCREEN_HEIGHT/2, TUNNEL_WIDTH, TUNNEL_HEIGHT)];
    
    _leftTunnel1.backgroundColor = [UIColor blackColor];
    _leftTunnel2.backgroundColor = [UIColor blackColor];
    _rightTunnel1.backgroundColor = [UIColor blackColor];
    _rightTunnel2.backgroundColor = [UIColor blackColor];
    
    _tunnels = [[NSMutableArray alloc]init];
    
    [self.tunnels addObject:_leftTunnel1];
    [self.tunnels addObject:_leftTunnel2];
    [self.tunnels addObject:_rightTunnel1];
    [self.tunnels addObject:_rightTunnel2];
    
    [self.view addSubview:_leftTunnel1];
    [self.view addSubview:_leftTunnel2];
    [self.view addSubview:_rightTunnel1];
    [self.view addSubview:_rightTunnel2];
    
    [self.view bringSubviewToFront:self.scoreLabel];
    
    for (int i = 1; i < 3; i++) {
        [self changeTunnelPosition:i];
        [self randTunnelDirection:i];
        [self changeTunnelSpeed:i];
    }

    
    
}

- (void)startTimers{
    
    [self startFallingTimer];
    [self startRisingTimer];
    [self startShiftingTimer];
    
}

- (void)startFallingTimer{
    
    _fallingTimer = [NSTimer scheduledTimerWithTimeInterval:0.02
                                                     target:self
                                                   selector:@selector(falling)
                                                   userInfo:nil
                                                    repeats:YES];
}

- (void)startRisingTimer{
    
    _risingTimer = [NSTimer scheduledTimerWithTimeInterval:0.02
                                                    target:self
                                                  selector:@selector(rising)
                                                  userInfo:nil
                                                   repeats:YES];
}

- (void)startShiftingTimer{
    
    _shiftingTimer = [NSTimer scheduledTimerWithTimeInterval:0.02
                                                      target:self
                                                    selector:@selector(shifting)
                                                    userInfo:nil
                                                     repeats:YES];
}

- (void)stopTimers{

    [self.fallingTimer invalidate];
    [self.risingTimer invalidate];
    [self.shiftingTimer invalidate];
}

- (void) startAccelerometer{
    [[UIAccelerometer sharedAccelerometer] setUpdateInterval:0.02];
    [[UIAccelerometer sharedAccelerometer] setDelegate:self];
}

- (void)accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)acceleration{
    deltaX = (int) (acceleration.x * ACCELERATION_FACTOR);
}

#pragma mark - Periodical action
- (void)falling{
    
    int newX = self.ball.center.x + deltaX;
    int newY = self.ball.center.y - deltaY/10;
    
    if (newX > SCREEN_WIDTH - RADIUS) {
        newX = SCREEN_WIDTH - RADIUS;
    }
    if (newX < RADIUS) {
        newX = RADIUS;
    }
    if (newY > SCREEN_HEIGHT - RADIUS) {
        newY = SCREEN_HEIGHT - RADIUS;
        deltaY = -deltaY/2;
        //[self gameOver];
    }
    if (newY <= SCORE_LABEL_HEIGHT +  RADIUS) {
        newY = SCORE_LABEL_HEIGHT +  RADIUS + 1.0;
        deltaY = -deltaY/2;
    }
    
    self.ball.center = CGPointMake(newX, newY);
    //[self.ball setFrame:CGRectMake(newX-RADIUS, newY-RADIUS, RADIUS*2, RADIUS*2)];
    deltaY -= GRAVITY;
    
    [self collisionDetect];
    [self updateScore];
    
}

- (void)rising{
    
    for(UIView *tunnel in self.tunnels){
        float y = tunnel.center.y - tunnelSpeed;
        
        if(y < SCORE_LABEL_HEIGHT - TUNNEL_HEIGHT/2){
            y = SCREEN_HEIGHT + TUNNEL_HEIGHT;
            if(tunnel == self.leftTunnel1)
                [self changeTunnelPosition:1];
            else if(tunnel == self.leftTunnel2)
                [self changeTunnelPosition:2];
        }
        
        tunnel.center = CGPointMake(tunnel.center.x,y);
        
    }
    
}

- (void)shifting{
    
    for(UIView *tunnel in self.tunnels){
        
        float x = tunnel.center.x;
        
        if (tunnel == self.leftTunnel1) {
            
            x = tunnel.center.x + speed_t1 * direction_t1;
            if (x < -TUNNEL_WIDTH/2 + 5) {
                direction_t1 = -direction_t1;
            }
            
        }else if(tunnel == self.rightTunnel1) {
            
            x = tunnel.center.x + speed_t1 * direction_t1;
            if (x > TUNNEL_WIDTH/2 + SCREEN_WIDTH - 5) {
                direction_t1 = -direction_t1;
            }
            
        }else if(tunnel == self.leftTunnel2) {
            
            x = tunnel.center.x + speed_t2 * direction_t2;
            if (x < -TUNNEL_WIDTH/2 + 5) {
                direction_t2 = -direction_t2;
            }
            
        }else if(tunnel == self.rightTunnel2) {
            
            x = tunnel.center.x + speed_t2 * direction_t2;
            if (x > TUNNEL_WIDTH/2 + SCREEN_WIDTH - 5) {
                direction_t2 = -direction_t2;
            }
        }
        
        tunnel.center = CGPointMake(x,tunnel.center.y);
    }
    
    
    
}

#pragma mark - Game
- (void)changeTunnelPosition:(int)tunnelId{
    
    float xPositionLeft = arc4random() % (int)(TUNNEL_WIDTH/2) - TUNNEL_WIDTH/2 + 30.0;
    float gap = arc4random() % 25 + minGapDistance;
    float xPositionRight = xPositionLeft + TUNNEL_WIDTH + gap;
    
    switch (tunnelId) {
        case 1:
            self.leftTunnel1.center = CGPointMake(xPositionLeft, self.leftTunnel1.center.y);
            self.rightTunnel1.center = CGPointMake(xPositionRight, self.rightTunnel1.center.y);
            isPassed_1 = NO;
            [self changeTunnelSpeed:1];
            [self randTunnelDirection:1];
            break;
        case 2:
            self.leftTunnel2.center = CGPointMake(xPositionLeft, self.leftTunnel2.center.y);
            self.rightTunnel2.center = CGPointMake(xPositionRight, self.rightTunnel2.center.y);
            isPassed_2 = NO;
            [self changeTunnelSpeed:2];
            [self randTunnelDirection:2];
        default:
            break;
    }
    
}

- (void)changeTunnelSpeed:(int)tunnelId{
    
    float speed;
    
    if(totalScore <= 8)
        speed = 0.0;
    else
        speed = arc4random()%4;
    
    switch (tunnelId) {
        case 1:
            speed_t1 = speed;
            break;
        case 2:
            speed_t2 = speed;
        default:
            break;
    }
    
    tunnelSpeed = 3.0 + (float)totalScore/20;
    
    if(tunnelSpeed > 5.0)
        tunnelSpeed = 5.0;
    
    minGapDistance = RADIUS * (4.5 - (float)totalScore/20);
    
    if(minGapDistance < RADIUS * 3.0)
        minGapDistance = RADIUS * 3.0;
    
}

-(void)randTunnelDirection:(int)tunnelId{
    
    int temp = arc4random() % 2;
    int direction;
    
    if (temp % 2 == 0)
        direction = 1;
    else
        direction = -1;
    
    switch (tunnelId) {
        case 1:
            direction_t1 = direction;
            break;
        case 2:
            direction_t2 = direction;
        default:
            break;
    }
}

-(void)collisionDetect{
    
    for(UIView *tunnel in self.tunnels){
        
        if (CGRectIntersectsRect(tunnel.frame, self.ball.frame)) {
            [self gameOver];
        }
    }
}

-(void)updateScore{
    
    if (self.ball.center.y > self.leftTunnel1.center.y && !isPassed_1) {
        totalScore += 1;
        [self.scoreLabel setText:[NSString stringWithFormat:@"Score: %d",totalScore]];
        isPassed_1 = YES;
    }
    
    if (self.ball.center.y > self.leftTunnel2.center.y && !isPassed_2) {
        totalScore += 1;
        [self.scoreLabel setText:[NSString stringWithFormat:@"Score: %d",totalScore]];
        isPassed_2 = YES;
    }
    
}

-(void)gameOver{
    
    self.ball.hidden = YES;
    self.scoreLabel.hidden = YES;
    for(UIView *tunnel in self.tunnels){
        tunnel.hidden = YES;
    }
    
    self.gameOverLabel.hidden = NO;
    
    int bestScore = (int)[[NSUserDefaults standardUserDefaults] integerForKey:@"BestScore"];
    
    if (totalScore > bestScore) {
        bestScore = totalScore;
        [[NSUserDefaults standardUserDefaults] setInteger:bestScore forKey:@"BestScore"];
    }
    
    [self.bestScoreLabel setText:[NSString stringWithFormat:@"Your Score: %d\nBest Score: %d",totalScore, bestScore]];
    
    self.restartButton.hidden = NO;
    
    self.bestScoreLabel.hidden = NO;
    
    [self stopTimers];
}


#pragma mark - Button actions

- (IBAction)tap:(UITapGestureRecognizer *)sender {
    
    if(isFirstTap){
        [self startTimers];
        [self startAccelerometer];
        
        self.tapLabel.hidden = YES;
        isFirstTap = NO;
        
        deltaY = IMPULSE - 20;
    }else
        deltaY = IMPULSE;
}

- (IBAction)restart:(UIButton *)sender {
    
    deltaX = 0;
    deltaY = 0;
    totalScore = 0;
    
    [self.scoreLabel setText:[NSString stringWithFormat:@"Score: 0"]];
    
    self.gameOverLabel.hidden = YES;
    self.bestScoreLabel.hidden = YES;
    self.restartButton.hidden = YES;
    
    self.scoreLabel.hidden = NO;
    self.ball.hidden = NO;
    for(UIView *tunnel in self.tunnels){
        tunnel.hidden = NO;
    }
    
    self.ball.center = CGPointMake(SCREEN_WIDTH/2 - RADIUS,SCREEN_HEIGHT/6);
    self.leftTunnel1.center = CGPointMake(0, SCREEN_HEIGHT+TUNNEL_HEIGHT);
    self.rightTunnel1.center = CGPointMake(0, SCREEN_HEIGHT+TUNNEL_HEIGHT);
    self.leftTunnel2.center = CGPointMake(0, SCREEN_HEIGHT+TUNNEL_HEIGHT + SCREEN_HEIGHT/2);
    self.rightTunnel2.center = CGPointMake(0, SCREEN_HEIGHT+TUNNEL_HEIGHT + SCREEN_HEIGHT/2);
    
    [self startTimers];
    
    for (int i = 1; i < 3; i++) {
        [self changeTunnelPosition:i];
        [self randTunnelDirection:i];
        [self changeTunnelSpeed:i];
    }
    
}



@end

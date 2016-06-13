//
//  MatchViewController.m
//  PubNubPong
//
//  Created by Jordan Zucker on 6/13/16.
//  Copyright © 2016 Jordan Zucker. All rights reserved.
//

#import <PubNub/PubNub.h>
#import "MatchViewController.h"
#import "PNPPaddleView.h"
#import "PNPBallView.h"

@interface MatchViewController () <
                                    PNObjectEventListener,
                                    UICollisionBehaviorDelegate
                                    >
@property (nonatomic, strong) PubNub *client;
@property (nonatomic, strong) PNPPaddleView *myPaddle;
@property (nonatomic, strong) PNPPaddleView *opponentPaddle;
@property (nonatomic, strong) PNPBallView *ballView;
@property (nonatomic, strong) UIDynamicAnimator *animator;
@property (nonatomic, strong) UIPushBehavior *pusher;
@property (nonatomic, strong) UICollisionBehavior *collider;
@property (nonatomic, strong) UIDynamicItemBehavior *paddleDynamicProperties;
@property (nonatomic, strong) UIDynamicItemBehavior *ballDynamicProperties;
@property (nonatomic, strong) UIAttachmentBehavior *attacher;
@property (nonatomic, weak) NSTimer *animationTimer;
@end

@implementation MatchViewController

#pragma mark - Initializers

- (instancetype)initWithPubNubClient:(PubNub *)client {
    self = [super init];
    if (self) {
        NSParameterAssert(client);
        _client = client;
        [_client addListener:self];
    }
    return self;
}

+ (instancetype)matchViewControllerWithClient:(PubNub *)client {
    return [[self alloc] initWithPubNubClient:client];
}

- (void)loadView {
    UIView *mainView = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    mainView.backgroundColor = [UIColor blackColor];
    self.myPaddle = [PNPPaddleView paddleWithLength:120.0 andUniqueIdentifier:self.client.uuid];
    [mainView addSubview:self.myPaddle];
    self.ballView = [PNPBallView ballWithSideLength:16.0];
    [mainView addSubview:self.ballView];
    self.view = mainView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
//    self.myPaddle = [PNPPaddleView paddleWithLength:120.0 andUniqueIdentifier:self.client.uuid];
//    [self.view addSubview:self.myPaddle];
//    self.ballView = [PNPBallView ballWithSideLength:16.0];
//    [self.view addSubview:self.ballView];
    self.ballView.center = self.view.center;
    [self.client subscribeToChannels:@[@"pubnubpong"] withPresence:YES];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    NSLog(@"%s", __PRETTY_FUNCTION__);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // Reset with double tap gesture
    UITapGestureRecognizer *doubleTapGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(reset)];
    doubleTapGR.numberOfTapsRequired = 2;
    doubleTapGR.numberOfTouchesRequired = 2;
    [self.view addGestureRecognizer:doubleTapGR];
    
    UITapGestureRecognizer *tapGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped:)];
    [self.view addGestureRecognizer:tapGR];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self _initBehaviors];
}

#pragma mark - Animation Timer

- (void)startAnimationTimer {
    self.animationTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(animationTimerTriggered:) userInfo:nil repeats:YES];
}

- (void)cancelAnimationTimer {
    [self.animationTimer invalidate];
    self.animationTimer = nil;
}

- (void)animationTimerTriggered:(NSTimer *)animationTimer {

}

#pragma mark - Orientation

- (BOOL)shouldAutorotate {
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskLandscape;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationLandscapeLeft;
}

#pragma mark - Animations

- (void)_initBehaviors {
    self.animator = [[UIDynamicAnimator alloc] initWithReferenceView:self.view];
    
    // Start ball off with a push
    self.pusher = [[UIPushBehavior alloc] initWithItems:@[self.ballView]
                                                   mode:UIPushBehaviorModeInstantaneous];
    self.pusher.pushDirection = CGVectorMake(0.5, 1.0);
    self.pusher.active = YES; // Because push is instantaneous, it will only happen once
    self.pusher.magnitude = 0.1;
    [self.animator addBehavior:self.pusher];
    
    // Step 1: Add collisions
    self.collider = [[UICollisionBehavior alloc] initWithItems:@[self.ballView, self.myPaddle]];
    self.collider.collisionDelegate = self;
    self.collider.collisionMode = UICollisionBehaviorModeEverything;
    self.collider.translatesReferenceBoundsIntoBoundary = YES;
    [self.animator addBehavior:self.collider];
    
    // Step 2: Remove rotation
    self.ballDynamicProperties = [[UIDynamicItemBehavior alloc]
                                  initWithItems:@[self.ballView]];
    self.ballDynamicProperties.allowsRotation = NO;
    [self.animator addBehavior:self.ballDynamicProperties];
    
    self.paddleDynamicProperties = [[UIDynamicItemBehavior alloc]
                                    initWithItems:@[self.myPaddle]];
    self.paddleDynamicProperties.allowsRotation = NO;
    [self.animator addBehavior:self.paddleDynamicProperties];
    
    // Step 3: Heavy paddle
    self.paddleDynamicProperties.density = 1000.0f;
    
    // Step 4: Better collisions, no friction
    self.ballDynamicProperties.elasticity = 1.0;
    self.ballDynamicProperties.friction = 0.0;
    self.ballDynamicProperties.resistance = 0.0;
    
    // Step 5: Move paddle
    CGPoint anchor = CGPointMake(CGRectGetMidX(self.myPaddle.frame), CGRectGetMidY(self.myPaddle.frame));
    self.attacher = [[UIAttachmentBehavior alloc] initWithItem:self.myPaddle
                                              attachedToAnchor:anchor];
    [self.animator addBehavior:self.attacher];
}

#pragma mark - Actions

- (void)tapped:(UIGestureRecognizer *)gr {
    CGPoint anchorPoint = [gr locationInView:self.view];
    NSString *anchorPointString = NSStringFromCGPoint(anchorPoint);
    NSLog(@"%@", anchorPointString);
    NSDictionary *anchorPointDictionary = @{
                                            @"x": [NSString stringWithFormat:@"%f", anchorPoint.x],
                                            @"y": [NSString stringWithFormat:@"%f", anchorPoint.y]
                                            };
    NSDictionary *message = @{
                              self.myPaddle.uniqueIdentifier: anchorPointDictionary
                              };
    [self.client publish:message toChannel:@"pubnubpong" withCompletion:^(PNPublishStatus * _Nonnull status) {
        NSLog(@"status: %@", status.debugDescription);
    }];
    self.attacher.anchorPoint = anchorPoint;
}

- (void)reset {
    [self.animator removeAllBehaviors];
    self.collider = nil;
    self.pusher = nil;
    self.ballDynamicProperties = nil;
    self.paddleDynamicProperties = nil;
    self.attacher = nil;
    
    [self _initBehaviors];
}

#pragma mark - Ball Reactions


#pragma mark - PNObjectEventListener

- (void)client:(PubNub *)client didReceiveStatus:(PNStatus *)status {
    if (status.isError) {
        NSLog(@"Client (%@) received error status: %@", client, status.debugDescription);
    }
}

- (void)client:(PubNub *)client didReceiveMessage:(PNMessageResult *)message {
//    NSString *senderUniqueIdentifier = message.data.
//    if ([message.data.message.envelope.senderUniqueIdentifier isEqualToString:self.opponentPaddle.uniqueIdentifier]) {
//        NSDictionary *anchorPointDictionary = message.data.message[]
//        self.opponentPaddle.center =
//    }
    if (message.data.message[self.opponentPaddle.uniqueIdentifier]) {
        NSDictionary *updatedCenterDictionary = message.data.message[self.opponentPaddle.uniqueIdentifier];
        CGPoint updatedCenter = CGPointMake([updatedCenterDictionary[@"x"] floatValue], [updatedCenterDictionary[@"y"] floatValue]);
        self.opponentPaddle.center = updatedCenter;
        [self.view setNeedsLayout];
    }
}

- (void)client:(PubNub *)client didReceivePresenceEvent:(PNPresenceEventResult *)event {
    // make sure we don't add a paddle on our own join
    if (
        [event.data.presenceEvent isEqualToString:@"join"] &&
        ![event.data.presence.uuid isEqualToString:self.client.uuid]
        ) {
        self.opponentPaddle = [PNPPaddleView paddleWithLength:120.0f andUniqueIdentifier:event.data.presence.uuid];
        [self.view addSubview:self.opponentPaddle];
    }
}

@end

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
@property (nonatomic, strong) PNPPaddleView *mainPlayerPaddle;
@property (nonatomic, strong) PNPBallView *ballView;
@property (nonatomic, strong) UIDynamicAnimator *animator;
@property (nonatomic, strong) UIPushBehavior *pusher;
@property (nonatomic, strong) UICollisionBehavior *collider;
@property (nonatomic, strong) UIDynamicItemBehavior *paddleDynamicProperties;
@property (nonatomic, strong) UIDynamicItemBehavior *ballDynamicProperties;
@property (nonatomic, strong) UIAttachmentBehavior *attacher;
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
    self.mainPlayerPaddle = [PNPPaddleView paddleWithLength:120.0];
    [mainView addSubview:self.mainPlayerPaddle];
    self.ballView = [PNPBallView ballWithSideLength:16.0];
    [mainView addSubview:self.ballView];
    self.view = mainView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
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
    self.collider = [[UICollisionBehavior alloc] initWithItems:@[self.ballView, self.mainPlayerPaddle]];
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
                                    initWithItems:@[self.mainPlayerPaddle]];
    self.paddleDynamicProperties.allowsRotation = NO;
    [self.animator addBehavior:self.paddleDynamicProperties];
    
    // Step 3: Heavy paddle
    self.paddleDynamicProperties.density = 1000.0f;
    
    // Step 4: Better collisions, no friction
    self.ballDynamicProperties.elasticity = 1.0;
    self.ballDynamicProperties.friction = 0.0;
    self.ballDynamicProperties.resistance = 0.0;
    
    // Step 5: Move paddle
    CGPoint anchor = CGPointMake(CGRectGetMidX(self.mainPlayerPaddle.frame), CGRectGetMidY(self.mainPlayerPaddle.frame));
    self.attacher = [[UIAttachmentBehavior alloc] initWithItem:self.mainPlayerPaddle
                                              attachedToAnchor:anchor];
    [self.animator addBehavior:self.attacher];
}

#pragma mark - Actions

- (void)tapped:(UIGestureRecognizer *)gr {
    self.attacher.anchorPoint = [gr locationInView:self.view];
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

#pragma mark - PNObjectEventListener

- (void)client:(PubNub *)client didReceiveStatus:(PNStatus *)status {
    
}

- (void)client:(PubNub *)client didReceiveMessage:(PNMessageResult *)message {
    
}

- (void)client:(PubNub *)client didReceivePresenceEvent:(PNPresenceEventResult *)event {
    
}

@end

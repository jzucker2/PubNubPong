//
//  MatchViewController.m
//  PubNubPong
//
//  Created by Jordan Zucker on 6/16/16.
//  Copyright © 2016 Jordan Zucker. All rights reserved.
//

#import <PubNub/PubNub.h>
#import "PNPMatchmaker.h"
#import "PNPMatchUpdater.h"
#import "MatchViewController.h"
#import "PNPPlayer.h"
#import "PNPPaddleView.h"
#import "PNPBallView.h"

@interface MatchViewController () <
                                    PNPMatchUpdaterDelegate,
                                    UICollisionBehaviorDelegate
                                    >
@property (nonatomic, strong) PubNub *client;
@property (nonatomic, strong) PNPMatchUpdater *updater;
@property (nonatomic, strong) PNPPlayer *localPlayer;
@property (nonatomic, strong) PNPPlayer *opponentPlayer;
@property (nonatomic, strong) PNPPaddleView *myPaddle;
@property (nonatomic, strong) PNPPaddleView *opponentPaddle;
@property (nonatomic, strong) PNPBallView *ballView;
@property (nonatomic, strong) UIDynamicAnimator *animator;
@property (nonatomic, strong) UIPushBehavior *pusher;
@property (nonatomic, strong) UICollisionBehavior *collider;
@property (nonatomic, strong) UIDynamicItemBehavior *myPaddleDynamicProperties;
@property (nonatomic, strong) UIDynamicItemBehavior *opponentPaddleDynamicProperties;
@property (nonatomic, strong) UIDynamicItemBehavior *ballDynamicProperties;
@property (nonatomic, strong) UIAttachmentBehavior *myAttacher;
@property (nonatomic, strong) UIAttachmentBehavior *opponentAttacher;
@end

@implementation MatchViewController

- (instancetype)initWithClient:(PubNub *)client matchProposal:(PNPMatchProposal *)matchProposal matchUpdater:(PNPMatchUpdater *)matchUpdater {
    self = [super init];
    if (self) {
        _client = client;
        _updater = matchUpdater;
        _updater.delegate = self;
        _localPlayer = matchUpdater.localPlayer;
        _opponentPlayer = matchUpdater.opponentPlayer;
    }
    return self;
}

+ (instancetype)matchViewControllerWithClient:(PubNub *)client matchProposal:(PNPMatchProposal *)matchProposal matchUpdater:(PNPMatchUpdater *)matchUpdater {
    return [[self alloc] initWithClient:client matchProposal:matchProposal matchUpdater:matchUpdater];
}

#pragma mark - View

- (void)loadView {
    UIView *mainView = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    mainView.backgroundColor = [UIColor blackColor];
    self.myPaddle = [PNPPaddleView paddleWithLength:120.0 andUniqueIdentifier:self.localPlayer.uniqueIdentifier];
    [mainView addSubview:self.myPaddle];
    self.ballView = [PNPBallView ballWithSideLength:16.0];
    [mainView addSubview:self.ballView];
    self.opponentPaddle = [PNPPaddleView paddleWithLength:120.0 andUniqueIdentifier:self.opponentPlayer.uniqueIdentifier];
    [mainView addSubview:self.opponentPaddle];
    self.view = mainView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.ballView.center = self.view.center;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - View Lifecyle

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
//    // Reset with double tap gesture
//    UITapGestureRecognizer *doubleTapGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(reset)];
//    doubleTapGR.numberOfTapsRequired = 2;
//    doubleTapGR.numberOfTouchesRequired = 2;
//    [self.view addGestureRecognizer:doubleTapGR];
    
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
    NSMutableArray *items = [@[self.ballView, self.myPaddle] mutableCopy];
    if (self.opponentPaddle) {
        [items addObject:self.opponentPaddle];
    }
    self.collider = [[UICollisionBehavior alloc] initWithItems:items.copy];
    self.collider.collisionDelegate = self;
    self.collider.collisionMode = UICollisionBehaviorModeEverything;
    self.collider.translatesReferenceBoundsIntoBoundary = YES;
    [self.animator addBehavior:self.collider];
    
    // Step 2: Remove rotation
    self.ballDynamicProperties = [[UIDynamicItemBehavior alloc]
                                  initWithItems:@[self.ballView]];
    self.ballDynamicProperties.allowsRotation = NO;
    [self.animator addBehavior:self.ballDynamicProperties];
    
    self.myPaddleDynamicProperties = [[UIDynamicItemBehavior alloc]
                                      initWithItems:@[self.myPaddle]];
    self.myPaddleDynamicProperties.allowsRotation = NO;
    [self.animator addBehavior:self.myPaddleDynamicProperties];
    
    if (self.opponentPaddle) {
        self.opponentPaddleDynamicProperties = [[UIDynamicItemBehavior alloc] initWithItems:@[self.opponentPaddle]];
        self.opponentPaddleDynamicProperties.allowsRotation = NO;
        self.opponentPaddleDynamicProperties.density = 1000.0f;
        [self.animator addBehavior:self.opponentPaddleDynamicProperties];
    }
    
    // Step 3: Heavy paddle
    self.myPaddleDynamicProperties.density = 1000.0f;
    
    // Step 4: Better collisions, no friction
    self.ballDynamicProperties.elasticity = 1.0;
    self.ballDynamicProperties.friction = 0.0;
    self.ballDynamicProperties.resistance = 0.0;
    
    // Step 5: Move paddle
    CGPoint anchor = CGPointMake(CGRectGetMidX(self.myPaddle.frame), CGRectGetMidY(self.myPaddle.frame));
    self.myAttacher = [[UIAttachmentBehavior alloc] initWithItem:self.myPaddle
                                                attachedToAnchor:anchor];
    [self.animator addBehavior:self.myAttacher];
    
    CGPoint opponentAnchor = CGPointMake(CGRectGetMidX(self.opponentPaddle.frame), CGRectGetMidY(self.opponentPaddle.frame));
    self.opponentAttacher = [[UIAttachmentBehavior alloc] initWithItem:self.opponentPaddle
                                                attachedToAnchor:opponentAnchor];
    [self.animator addBehavior:self.opponentAttacher];
}

#pragma mark - Actions

- (void)tapped:(UIGestureRecognizer *)gr {
    CGPoint anchorPoint = [gr locationInView:self.view];
    //    NSString *anchorPointString = NSStringFromCGPoint(anchorPoint);
    //    NSLog(@"%@", anchorPointString);
    //    NSDictionary *anchorPointDictionary = @{
    //                                            @"x": [NSString stringWithFormat:@"%f", anchorPoint.x],
    //                                            @"y": [NSString stringWithFormat:@"%f", anchorPoint.y]
    //                                            };
    //    NSDictionary *message = @{
    //                              self.myPaddle.uniqueIdentifier: anchorPointDictionary
    //                              };
    //    [self.client publish:message toChannel:@"pubnubpong" withCompletion:^(PNPublishStatus * _Nonnull status) {
    //        NSLog(@"status: %@", status.debugDescription);
    //    }];
    self.myAttacher.anchorPoint = anchorPoint;
    [self.updater updateLocalPlayerPosition:anchorPoint];
}

#pragma mark - PNPMatchUpdaterDelegate

- (void)matchUpdater:(PNPMatchUpdater *)matchUpdater receivedUpdate:(PNPMatchUpdate *)matchUpdate {
    // only update opponent
    if (![matchUpdate.player isLocalPlayerForClient:self.client]) {
        self.opponentAttacher.anchorPoint = matchUpdate.position;
//        [self.view setNeedsLayout];
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

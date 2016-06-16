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

#pragma mark - PNPMatchUpdaterDelegate

- (void)matchUpdater:(PNPMatchUpdater *)matchUpdater receivedUpdate:(PNPMatchUpdate *)matchUpdate {
    
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

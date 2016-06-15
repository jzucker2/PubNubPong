//
//  LobbyViewController.m
//  PubNubPong
//
//  Created by Jordan Zucker on 6/14/16.
//  Copyright © 2016 Jordan Zucker. All rights reserved.
//

#import "LobbyViewController.h"
#import "PNPConstants.h"
#import "PNPLobby.h"
#import "PNPPlayer.h"
#import "PNPMatchmaker.h"

@interface LobbyViewController () <
                                    PNPLobbyDelegate,
                                    PNPMatchmakerDelegate
                                    >
//@property (nonatomic, strong) PubNub *client;
@property (nonatomic, strong) PNPLobby *lobby;
@property (nonatomic, strong) PNPMatchmaker *matchmaker;
@property (nonatomic, strong) UIButton *proposeGameButton;
@property (nonatomic, strong) UILabel *playersLabel;
@property (nonatomic, strong) UILabel *numberOfPlayersLabel;

@end

@implementation LobbyViewController

- (instancetype)initWithLobby:(PNPLobby *)lobby andMatchmaker:(PNPMatchmaker *)matchmaker {
    NSParameterAssert(lobby);
    NSParameterAssert(matchmaker);
    self = [super init];
    if (self) {
        _lobby = lobby;
        _lobby.delegate = self;
        
    }
    return self;
}

+ (instancetype)lobbyViewControllerWithLobby:(PNPLobby *)lobby andMatchmaker:(PNPMatchmaker *)matchmaker {
    return [[self alloc] initWithLobby:lobby andMatchmaker:matchmaker];
}

- (void)loadView {
    UIView *mainView = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    mainView.backgroundColor = [UIColor lightGrayColor];
    self.view = mainView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.proposeGameButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.proposeGameButton setTitle:@"Propose Game" forState:UIControlStateNormal];
    [self.proposeGameButton sizeToFit];
    self.proposeGameButton.center = self.view.center;
    [self.proposeGameButton addTarget:self action:@selector(proposeGameButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    self.proposeGameButton.enabled = NO;
    [self.view addSubview:self.proposeGameButton];
    
    self.playersLabel = [[UILabel alloc] init];
    self.playersLabel.text = @"Players in lobby:";
    [self.playersLabel sizeToFit];
    self.playersLabel.center = CGPointMake(self.proposeGameButton.center.x - 50.0, self.proposeGameButton.center.y - 100.0);
    [self.view addSubview:self.playersLabel];
    
    self.numberOfPlayersLabel = [[UILabel alloc] init];
    self.numberOfPlayersLabel.frame = CGRectOffset(self.playersLabel.frame, self.playersLabel.frame.size.width + 50.0, 0.0);
    [self.view addSubview:self.numberOfPlayersLabel];
    [self updateNumberOfPlayersLabelWithCount:0];
    
    [self.view setNeedsLayout];
    
    [self.lobby updateAllPlayersInLobby];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Logic


#pragma mark - UIActions

- (void)proposeGameButtonTapped:(UIButton *)sender {
    [self.matchmaker proposeMatchToPlayer:self.lobby.randomPlayerFromLobby];
}

- (void)updateNumberOfPlayersLabelWithCount:(NSInteger)count {
    self.numberOfPlayersLabel.text = [NSString stringWithFormat:@"%ld", (long)count];
    self.proposeGameButton.enabled = ((count == 0) ? NO : YES);
}

#pragma mark - PNPLobbyDelegate

- (void)lobby:(PNPLobby *)lobby updatedAllPlayers:(NSArray<PNPPlayer *> *)updatedAllPlayers {
    [self updateNumberOfPlayersLabelWithCount:updatedAllPlayers.count];
}

#pragma mark - PNPMatchmakerDelegate

- (void)matchmaker:(PNPMatchmaker *)matchmaker receivedMatchProposal:(PNPMatchProposal *)proposal {
    
}


//- (instancetype)initWithClient:(PubNub *)client {
//    NSParameterAssert(client);
//    self = [super init];
//    if (self) {
//        _client = client;
//        [_client addListener:self];
//        [_client subscribeToChannels:@[kPNPLobbyChannel] withPresence:YES];
//    }
//    return self;
//}
//
//+ (instancetype)lobbyViewControllerWithClient:(PubNub *)client {
//    return [[self alloc] initWithClient:client];
//}
//
//- (void)loadView {
//    UIView *mainView = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
//    mainView.backgroundColor = [UIColor lightGrayColor];
//    self.view = mainView;
//}
//
//- (void)viewDidLoad {
//    [super viewDidLoad];
//    // Do any additional setup after loading the view.
//    self.proposeGameButton = [UIButton buttonWithType:UIButtonTypeCustom];
//    [self.proposeGameButton setTitle:@"Start Game" forState:UIControlStateNormal];
//    [self.proposeGameButton sizeToFit];
//    self.proposeGameButton.center = self.view.center;
//    [self.proposeGameButton addTarget:self action:@selector(proposeGameButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
//    self.proposeGameButton.enabled = NO;
//    [self.view addSubview:self.proposeGameButton];
//    
//    self.playersLabel = [[UILabel alloc] init];
//    self.playersLabel.text = @"Players in lobby:";
//    [self.playersLabel sizeToFit];
//    self.playersLabel.center = CGPointMake(self.proposeGameButton.center.x - 50.0, self.proposeGameButton.center.y - 100.0);
//    [self.view addSubview:self.playersLabel];
//    
//    self.numberOfPlayersLabel = [[UILabel alloc] init];
//    self.numberOfPlayersLabel.frame = CGRectOffset(self.playersLabel.frame, self.playersLabel.frame.size.width + 50.0, 0.0);
//    [self.view addSubview:self.numberOfPlayersLabel];
//    [self updateNumberOfPlayersLabelWithCount:0];
//    
//    [self.view setNeedsLayout];
//    
//    [self updateAllPlayersInLobby];
//}
//
//- (void)didReceiveMemoryWarning {
//    [super didReceiveMemoryWarning];
//    // Dispose of any resources that can be recreated.
//}
//
//#pragma mark - Logic
//
//- (void)startRandomGame {
//    if (self.allPlayers) {
//        for (id player in self.allPlayers) {
//            NSLog(@"player: %@", player);
//        }
//    }
//}
//
//- (void)startGame {
//    [self startRandomGame];
//}
//
//- (void)updateAllPlayersInLobby {
//    PNPWeakify(self);
//    [self.client hereNowForChannel:kPNPLobbyChannel withVerbosity:PNHereNowUUID completion:^(PNPresenceChannelHereNowResult * _Nullable result, PNErrorStatus * _Nullable status) {
//        if (status.isError) {
//            return;
//        }
//        PNPStrongify(self);
//        self.allPlayers = result.data.uuids;
//        [self updateNumberOfPlayersLabelWithCount:result.data.occupancy.integerValue];
//    }];
//}
//
//#pragma mark - UIActions
//
//- (void)proposeGameButtonTapped:(UIButton *)sender {
//    [self startGame];
//}
//
//- (void)updateNumberOfPlayersLabelWithCount:(NSInteger)count {
//    self.numberOfPlayersLabel.text = [NSString stringWithFormat:@"%ld", (long)count];
//    self.proposeGameButton.enabled = ((count == 0) ? NO : YES);
//}
//
//#pragma mark - PNObjectEventListener
//
//- (void)client:(PubNub *)client didReceiveStatus:(PNStatus *)status {
//    if (status.isError) {
//        NSLog(@"client (%@) received error status: %@", client, status.debugDescription);
//        return;
//    }
//}
//
//- (void)client:(PubNub *)client didReceiveMessage:(PNMessageResult *)message {
//    
//}
//
//- (void)client:(PubNub *)client didReceivePresenceEvent:(PNPresenceEventResult *)event {
//    // let's just update after every presence event
//    [self updateAllPlayersInLobby];
//    // need to update after our own join
////    if ([event.data.presenceEvent isEqualToString:@"join"]) {
////        if ([event.data.presence.uuid isEqualToString:self.client.uuid]) {
////            // we receive our own join
////            [self updateAllPlayersInLobby];
////        }
////    }
//}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

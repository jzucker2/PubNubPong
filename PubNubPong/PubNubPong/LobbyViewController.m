//
//  LobbyViewController.m
//  PubNubPong
//
//  Created by Jordan Zucker on 6/14/16.
//  Copyright © 2016 Jordan Zucker. All rights reserved.
//

#import <PubNub/PubNub.h>
#import "LobbyViewController.h"
#import "PNPConstants.h"

@interface LobbyViewController () <
                                    PNObjectEventListener
                                    >
@property (nonatomic, strong) PubNub *client;
@property (nonatomic, strong) UIButton *startGameButton;
@property (nonatomic, strong) UILabel *playersLabel;
@property (nonatomic, strong) UILabel *numberOfPlayersLabel;

@end

@implementation LobbyViewController

- (instancetype)initWithClient:(PubNub *)client {
    NSParameterAssert(client);
    self = [super init];
    if (self) {
        _client = client;
        [_client addListener:self];
        [_client subscribeToChannels:@[kPNPLobbyChannel] withPresence:YES];
    }
    return self;
}

+ (instancetype)lobbyViewControllerWithClient:(PubNub *)client {
    return [[self alloc] initWithClient:client];
}

- (void)loadView {
    UIView *mainView = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    mainView.backgroundColor = [UIColor lightGrayColor];
    self.view = mainView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.startGameButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.startGameButton setTitle:@"Start Game" forState:UIControlStateNormal];
    [self.startGameButton sizeToFit];
    self.startGameButton.center = self.view.center;
    [self.startGameButton addTarget:self action:@selector(startGameButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.startGameButton];
    
    self.playersLabel = [[UILabel alloc] init];
    self.playersLabel.text = @"Players in lobby:";
    [self.playersLabel sizeToFit];
    self.playersLabel.center = CGPointMake(self.startGameButton.center.x - 50.0, self.startGameButton.center.y - 100.0);
    [self.view addSubview:self.playersLabel];
    
    self.numberOfPlayersLabel = [[UILabel alloc] init];
    self.numberOfPlayersLabel.frame = CGRectOffset(self.playersLabel.frame, self.playersLabel.frame.size.width + 50.0, 0.0);
    [self.view addSubview:self.numberOfPlayersLabel];
    [self updateNumberOfPlayersLabelWithCount:0];
    
    [self.view setNeedsLayout];
    
    [self updateAllPlayersInLobby];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Logic

- (void)startGame {
    
}

- (void)updateAllPlayersInLobby {
    PNPWeakify(self);
    [self.client hereNowForChannel:kPNPLobbyChannel withVerbosity:PNHereNowUUID completion:^(PNPresenceChannelHereNowResult * _Nullable result, PNErrorStatus * _Nullable status) {
        if (status.isError) {
            return;
        }
        PNPStrongify(self);
        [self updateNumberOfPlayersLabelWithCount:result.data.occupancy.integerValue];
    }];
}

#pragma mark - UIActions

- (void)startGameButtonTapped:(UIButton *)sender {
    
}

- (void)updateNumberOfPlayersLabelWithCount:(NSInteger)count {
    self.numberOfPlayersLabel.text = [NSString stringWithFormat:@"%ld", (long)count];
}

#pragma mark - PNObjectEventListener

- (void)client:(PubNub *)client didReceiveStatus:(PNStatus *)status {
    if (status.isError) {
        NSLog(@"client (%@) received error status: %@", client, status.debugDescription);
        return;
    }
}

- (void)client:(PubNub *)client didReceiveMessage:(PNMessageResult *)message {
    
}

- (void)client:(PubNub *)client didReceivePresenceEvent:(PNPresenceEventResult *)event {
    // let's just update after every presence event
    [self updateAllPlayersInLobby];
    // need to update after our own join
//    if ([event.data.presenceEvent isEqualToString:@"join"]) {
//        if ([event.data.presence.uuid isEqualToString:self.client.uuid]) {
//            // we receive our own join
//            [self updateAllPlayersInLobby];
//        }
//    }
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

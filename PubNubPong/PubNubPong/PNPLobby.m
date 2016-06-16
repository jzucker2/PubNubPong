//
//  PNPLobby.m
//  PubNubPong
//
//  Created by Jordan Zucker on 6/15/16.
//  Copyright © 2016 Jordan Zucker. All rights reserved.
//

#import <PubNub/PubNub.h>
#import "PNPConstants.h"
#import "PNPPlayer.h"
#import "PNPLobby.h"

@interface PNPLobby () <
                        PNObjectEventListener
                        >
@property (nonatomic, strong) PNPPlayer *localPlayer;
@property (nonatomic, strong) PubNub *client;
@property (nonatomic, strong, readwrite) NSArray<PNPPlayer *> *allPlayers;

@end

@implementation PNPLobby

- (instancetype)initWithLocalPlayer:(PNPPlayer *)localPlayer andClient:(PubNub *)client {
    self = [super init];
    if (self) {
        _localPlayer = localPlayer;
        _client = client;
        [_client addListener:self];
//        [_client subscribeToChannels:@[kPNPLobbyChannel] withPresence:YES];
        _allPlayers = @[];
    }
    return self;
}

+ (instancetype)lobbyWithLocalPlayer:(PNPPlayer *)localPlayer andClient:(PubNub *)client {
    return [[self alloc] initWithLocalPlayer:localPlayer andClient:client];
}

- (void)dealloc {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    [self.client unsubscribeFromChannels:@[kPNPLobbyChannel] withPresence:YES];
}

#pragma mark - Actions

- (void)updateAllPlayersInLobby {
    PNPWeakify(self);
    [self.client hereNowForChannel:kPNPLobbyChannel withVerbosity:PNHereNowState completion:^(PNPresenceChannelHereNowResult * _Nullable result, PNErrorStatus * _Nullable status) {
        if (status.isError) {
            return;
        }
        PNPStrongify(self);
        __block NSMutableArray *updatedAllPlayers = [NSMutableArray array];
        [result.data.uuids enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSLog(@"obj: %@", obj);
            NSDictionary *lobbyMember = (NSDictionary *)obj;
            PNPPlayer *player = [PNPPlayer playerWithUniqueIdentifier:lobbyMember[@"uuid"]];
            [updatedAllPlayers addObject:player];
        }];
        self.allPlayers = updatedAllPlayers.copy;
        [self.delegate lobby:self updatedAllPlayers:self.allPlayers];
    }];
}

- (PNPPlayer *)randomPlayerFromLobby {
    return self.allNonLocalPlayers.firstObject;
}

- (NSArray<PNPPlayer *> *)allNonLocalPlayers {
    NSString *localPlayerUniqueIdentifier = self.localPlayer.uniqueIdentifier;
#warning check this predicate
    NSPredicate *nonLocalPlayersPredicate = [NSPredicate predicateWithFormat:@"self.uniqueIdentifier != %@", localPlayerUniqueIdentifier];
    return [self.allPlayers filteredArrayUsingPredicate:nonLocalPlayersPredicate];
}

- (void)joinLobby {
    [self.client subscribeToChannels:@[kPNPLobbyChannel] withPresence:YES];
}

- (void)leaveLobby {
    self.allPlayers = @[];
    [self.client unsubscribeFromChannels:@[kPNPLobbyChannel] withPresence:YES];
    [self.delegate lobby:self updatedAllPlayers:self.allPlayers];
}

- (BOOL)localPlayerIsInLobby {
    return (
//            [self playerIsInLobby:self.localPlayer] &&
            [self.client.channels containsObject:kPNPLobbyChannel]
            );
}

- (BOOL)playerIsInLobby:(PNPPlayer *)player {
    return [self.allPlayers containsObject:player];
}

#pragma mark - PNObjectEventListener

- (void)client:(PubNub *)client didReceiveStatus:(PNStatus *)status {
    if (status.isError) {
        NSLog(@"self(%@): client (%@) received error status: %@", self, client, status.debugDescription);
        return;
    }
    NSLog(@"%s status: %@", __PRETTY_FUNCTION__, status.debugDescription);
    if (
        (status.operation == PNSubscribeOperation)
        ) {
//        NSLog(@"status: %@", status.debugDescription);
    }
}

- (void)client:(PubNub *)client didReceivePresenceEvent:(PNPresenceEventResult *)event {
    if ([event.data.subscribedChannel isEqualToString:kPNPLobbyChannel]) {
        [self updateAllPlayersInLobby];
    }
}

@end

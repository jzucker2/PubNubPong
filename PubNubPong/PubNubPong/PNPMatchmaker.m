//
//  PNPMatchmaker.m
//  PubNubPong
//
//  Created by Jordan Zucker on 6/15/16.
//  Copyright © 2016 Jordan Zucker. All rights reserved.
//

#import <PubNub/PubNub.h>
#import "PNPConstants.h"
#import "PNPMatchmaker.h"
#import "PNPPlayer.h"

@interface PNPMatchProposal ()
@property (nonatomic, strong, readwrite) PNPPlayer *creator;
@property (nonatomic, strong, readwrite) PNPPlayer *opponent;
@property (nonatomic, copy, readwrite) NSString *matchChannelName;

@end

@implementation PNPMatchProposal

- (instancetype)initWithCreator:(PNPPlayer *)creator andOpponent:(PNPPlayer *)opponent andMatchChannelName:(NSString *)matchChannelName {
    self = [super init];
    if (self) {
        _creator = creator;
        _opponent = opponent;
        _matchChannelName = matchChannelName;
    }
    return self;
}

+ (instancetype)proposalWithCreator:(PNPPlayer *)creator andOpponent:(PNPPlayer *)opponent andMatchChannelName:(NSString *)matchChannelName {
    return [[self alloc] initWithCreator:creator andOpponent:opponent andMatchChannelName:matchChannelName];
}

- (instancetype)initWithPubNubMessageResult:(PNMessageResult *)pubNubMessageResult {
    NSParameterAssert(pubNubMessageResult);
    NSDictionary *payload = pubNubMessageResult.data.message;
    NSParameterAssert([payload[@"type"] isEqualToString:@"proposal"]);
    PNPPlayer *creator = [[PNPPlayer alloc] initWithPubNubMessageResult:payload[@"creator"]];
    PNPPlayer *opponent = [[PNPPlayer alloc] initWithPubNubMessageResult:payload[@"opponent"]];
    self = [self initWithCreator:creator andOpponent:opponent andMatchChannelName:payload[@"matchChannelName"]];
    return self;
}

+ (instancetype)proposalFromPubNubMessageResult:(PNMessageResult *)pubNubMessageResult {
    return [[self alloc] initWithPubNubMessageResult:pubNubMessageResult];
}

- (id)JSONFormattedMessage {
    return @{
             @"type": @"proposal",
             @"creator": self.creator.JSONFormattedMessage,
             @"opponent": self.opponent.JSONFormattedMessage,
             @"matchChannelName": self.matchChannelName,
             };
}

+ (BOOL)canBeInitializedWithPubNubMessageResult:(PNMessageResult *)pubNubMessageResult {
    if ([pubNubMessageResult.data.message[@"type"] isEqualToString:@"proposal"]) {
        return YES;
    }
    return NO;
}

@end

@interface PNPMatchmaker () <
                            PNObjectEventListener
                            >
@property (nonatomic, strong) PNPPlayer *localPlayer;
@property (nonatomic, strong) PubNub *client;
@property (nonatomic, assign, getter=isProposing) BOOL proposing;
@end

@implementation PNPMatchmaker

- (instancetype)initWithLocalPlayer:(PNPPlayer *)localPlayer andClient:(PubNub *)client {
    self = [super init];
    if (self) {
        _proposing = NO;
        _localPlayer = localPlayer;
        _client = client;
        [_client addListener:self];
    }
    return self;
}

+ (instancetype)matchmakerWithLocalPlayer:(PNPPlayer *)localPlayer andClient:(PubNub *)client {
    return [[self alloc] initWithLocalPlayer:localPlayer andClient:client];
}

- (BOOL)proposeMatchToPlayer:(PNPPlayer *)opponent {
    if (
        [opponent isEqual:self.localPlayer] ||
        self.isProposing
        ) {
        return NO;
    }
    NSString *matchChannelName = [NSUUID UUID].UUIDString;
    PNPMatchProposal *proposal = [PNPMatchProposal proposalWithCreator:self.localPlayer andOpponent:opponent andMatchChannelName:matchChannelName];
    self.proposing = YES;
    [self.client publish:proposal.JSONFormattedMessage toChannel:kPNPLobbyChannel withCompletion:^(PNPublishStatus * _Nonnull status) {
        
    }];
    return YES;
}

#pragma mark - PNObjectEventListener

- (void)client:(PubNub *)client didReceiveStatus:(PNStatus *)status {
    
}

- (void)client:(PubNub *)client didReceiveMessage:(PNMessageResult *)message {
    if ([PNPMatchProposal canBeInitializedWithPubNubMessageResult:message]) {
        [self.delegate matchmaker:self receivedMatchProposal:[PNPMatchProposal proposalFromPubNubMessageResult:message]];
    }
}

- (void)client:(PubNub *)client didReceivePresenceEvent:(PNPresenceEventResult *)event {
    
}

@end

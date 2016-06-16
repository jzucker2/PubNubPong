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

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    NSParameterAssert(dictionary);
    NSParameterAssert([dictionary[@"type"] isEqualToString:@"proposal"]);
    PNPPlayer *creator = [[PNPPlayer alloc] initWithDictionary:dictionary[@"creator"]];
    PNPPlayer *opponent = [[PNPPlayer alloc] initWithDictionary:dictionary[@"opponent"]];
    self = [self initWithCreator:creator andOpponent:opponent andMatchChannelName:dictionary[@"matchChannelName"]];
    return self;
}

+ (instancetype)proposalFromDictionary:(NSDictionary *)dictionary {
    return [[self alloc] initWithDictionary:dictionary];
}

- (id)JSONFormattedMessage {
    return @{
             @"type": @"proposal",
             @"creator": self.creator.JSONFormattedMessage,
             @"opponent": self.opponent.JSONFormattedMessage,
             @"matchChannelName": self.matchChannelName,
             };
}

+ (BOOL)canBeInitializedWithDictionary:(NSDictionary *)dictionary {
    if ([dictionary[@"type"] isEqualToString:@"proposal"]) {
        return YES;
    }
    return NO;
}

@end

@interface PNPMatchProposalReply ()
@property (nonatomic, copy, readwrite) NSString *matchChannelName;
@property (nonatomic, strong, readwrite) PNPPlayer *opponentPlayer;
@property (nonatomic, assign, readwrite) BOOL reply;

@end

@implementation PNPMatchProposalReply

- (instancetype)initReply:(BOOL)reply withOpponentPlayer:(PNPPlayer *)opponentPlayer andMatchChannelName:(NSString *)matchChannelName {
    self = [super init];
    if (self) {
        _matchChannelName = matchChannelName;
        _opponentPlayer = opponentPlayer;
        _reply = reply;
    }
    return self;
}

+ (instancetype)reply:(BOOL)reply withOpponentPlayer:(PNPPlayer *)opponentPlayer andMatchChannelName:(NSString *)matchChannelName {
    return [[self alloc] initReply:reply withOpponentPlayer:opponentPlayer andMatchChannelName:matchChannelName];
}

- (instancetype)initReply:(BOOL)reply withMatchProposal:(PNPMatchProposal *)matchProposal {
    self = [self initReply:reply withOpponentPlayer:matchProposal.opponent andMatchChannelName:matchProposal.matchChannelName];
    return self;
}

+ (instancetype)reply:(BOOL)reply withProposal:(PNPMatchProposal *)matchProposal {
    return [[self alloc] initReply:reply withMatchProposal:matchProposal];
}

+ (BOOL)canBeInitializedWithDictionary:(NSDictionary *)dictionary {
    if ([dictionary[@"type"] isEqualToString:@"reply"]) {
        return YES;
    }
    return NO;
}

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    NSParameterAssert(dictionary);
    NSParameterAssert([dictionary[@"type"] isEqualToString:@"reply"]);
    NSParameterAssert(dictionary[@"reply"]);
    PNPPlayer *opponentPlayer = [[PNPPlayer alloc] initWithDictionary:dictionary[@"opponent"]];
    BOOL reply = [dictionary[@"reply"] boolValue];
    NSString *matchChannelName = dictionary[@"matchChannelName"];
    return [[self class] reply:reply withOpponentPlayer:opponentPlayer andMatchChannelName:matchChannelName];
}

- (id)JSONFormattedMessage {
    return @{
             @"type": @"reply",
             @"opponent": self.opponentPlayer.JSONFormattedMessage,
             @"matchChannelName": self.matchChannelName,
             @"reply": @(self.reply),
             };
}

@end

@interface PNPMatchmaker () <
                            PNObjectEventListener
                            >
@property (nonatomic, strong) PNPPlayer *localPlayer;
@property (nonatomic, strong) PubNub *client;
@property (nonatomic, assign, readwrite) PNPMatchmakerState state;
@end

@implementation PNPMatchmaker

- (instancetype)initWithLocalPlayer:(PNPPlayer *)localPlayer andClient:(PubNub *)client {
    self = [super init];
    if (self) {
        _state = PNPMatchmakerStateOpen;
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
//    if (
//        [opponent isEqual:self.localPlayer] ||
//        self.state == PNPMatchmakerStateProposing ||
//        self.state == PNPMatchmakerStateAccepted
//        ) {
//        return NO;
//    }
    NSString *matchChannelName = [NSUUID UUID].UUIDString;
    PNPMatchProposal *proposal = [PNPMatchProposal proposalWithCreator:self.localPlayer andOpponent:opponent andMatchChannelName:matchChannelName];
    self.state = PNPMatchmakerStateProposing;
    [self.client subscribeToChannels:@[matchChannelName] withPresence:YES];
    [self.client publish:proposal.JSONFormattedMessage toChannel:kPNPLobbyChannel withCompletion:^(PNPublishStatus * _Nonnull status) {
        
    }];
    return YES;
}

- (BOOL)replyToMatchProposal:(PNPMatchProposal *)matchProposal withDecision:(BOOL)willPlay {
//    if (
//        [matchProposal.opponent isEqual:self.localPlayer] ||
//        self.state == PNPMatchmakerStateAccepted
//        ) {
//        return NO;
//    }
    PNPMatchProposalReply *reply = [PNPMatchProposalReply reply:willPlay withProposal:matchProposal];
    [self.client publish:reply.JSONFormattedMessage toChannel:kPNPLobbyChannel withCompletion:^(PNPublishStatus * _Nonnull status) {
        
    }];
    return YES;
}

#pragma mark - PNObjectEventListener

- (void)client:(PubNub *)client didReceiveStatus:(PNStatus *)status {
    
}

- (void)client:(PubNub *)client didReceiveMessage:(PNMessageResult *)message {
    if (
//        (self.state == PNPMatchmakerStateOpen) &&
        [PNPMatchProposal canBeInitializedWithDictionary:message.data.message]
        ) {
        [self.delegate matchmaker:self receivedMatchProposal:[PNPMatchProposal proposalFromDictionary:message.data.message]];
        return;
    }
    if (
//        (self.state == PNPMatchmakerStateProposing) &&
        [PNPMatchProposalReply canBeInitializedWithDictionary:message.data.message]
        ) {
        PNPMatchProposalReply *reply = [[PNPMatchProposalReply alloc] initWithDictionary:message.data.message];
        self.state = (reply.reply ? PNPMatchmakerStateAccepted : PNPMatchmakerStateOpen);
        [self.delegate matchmaker:self receivedMatchProposalReply:reply];
        return;
    }
}

- (void)client:(PubNub *)client didReceivePresenceEvent:(PNPresenceEventResult *)event {
    
}

@end

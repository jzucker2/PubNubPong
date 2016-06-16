//
//  PNPMatchUpdater.m
//  PubNubPong
//
//  Created by Jordan Zucker on 6/16/16.
//  Copyright © 2016 Jordan Zucker. All rights reserved.
//

#import <PubNub/PubNub.h>
#import "PNPMatchUpdater.h"
#import "PNPPlayer.h"
#import "PNPMatchmaker.h"

//@interface PNPMatchUpdateComponent ()
//@property (nonatomic, strong, readwrite) PNPPlayer *player;
//@property (nonatomic, assign, readwrite) CGPoint position;
//@end
//
//@implementation PNPMatchUpdateComponent
//
//- (instancetype)initWithPosition:(CGPoint)position andPlayer:(PNPPlayer *)player {
//    self = [super init];
//    if (self) {
//        _player = player;
//        _position = position;
//    }
//    return self;
//}
//
//+ (instancetype)componentWithPosition:(CGPoint)position andPlayer:(PNPPlayer *)player {
//    return [[self alloc] initWithPosition:position andPlayer:player];
//}
//
//- (id)JSONFormattedMessage {
//    return @{
//             @"type": @"updateComponent",
//             @"player": self.player.JSONFormattedMessage,
//             @"x": [NSString stringWithFormat:@"%f", self.position.x],
//             @"y": [NSString stringWithFormat:@"%f", self.position.y],
//             };
//}
//
//- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
//    NSParameterAssert(dictionary[@"type"]);
//    NSParameterAssert(dictionary[@"x"]);
//    NSParameterAssert(dictionary[@"y"]);
//    NSParameterAssert(dictionary[@"player"]);
//    CGPoint position = CGPointMake([dictionary[@"x"] floatValue],  [dictionary[@"y"] floatValue]);
//    PNPPlayer *player = [[PNPPlayer alloc] initWithDictionary:dictionary[@"player"]];
//    self = [self initWithPosition:position andPlayer:player];
//    return self;
//}
//
//+ (BOOL)canBeInitializedWithDictionary:(NSDictionary *)dictionary {
//    if ([dictionary[@"type"] isEqualToString:@"updateComponent"]) {
//        return YES;
//    }
//    return NO;
//}
//
//@end

@interface PNPMatchUpdate ()
@property (nonatomic, strong, readwrite) PNPPlayer *player;
@property (nonatomic, assign, readwrite) CGPoint position;

@end

@implementation PNPMatchUpdate

- (instancetype)initWithPosition:(CGPoint)position andPlayer:(PNPPlayer *)player {
    self = [super init];
    if (self) {
        _player = player;
        _position = position;
    }
    return self;
}

+ (instancetype)updateWithPosition:(CGPoint)position andPlayer:(PNPPlayer *)player {
    return [[self alloc] initWithPosition:position andPlayer:player];
}

- (id)JSONFormattedMessage {
    return @{
             @"type": @"update",
             @"player": self.player.JSONFormattedMessage,
             @"x": [NSString stringWithFormat:@"%f", self.position.x],
             @"y": [NSString stringWithFormat:@"%f", self.position.y],
             };
}

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    NSParameterAssert(dictionary[@"type"]);
    NSParameterAssert(dictionary[@"x"]);
    NSParameterAssert(dictionary[@"y"]);
    NSParameterAssert(dictionary[@"player"]);
    CGPoint position = CGPointMake([dictionary[@"x"] floatValue],  [dictionary[@"y"] floatValue]);
    PNPPlayer *player = [[PNPPlayer alloc] initWithDictionary:dictionary[@"player"]];
    self = [self initWithPosition:position andPlayer:player];
    return self;
}

+ (BOOL)canBeInitializedWithDictionary:(NSDictionary *)dictionary {
    if ([dictionary[@"type"] isEqualToString:@"update"]) {
        return YES;
    }
    return NO;
}

@end

@interface PNPMatchUpdater () <
                                PNObjectEventListener
                                >
@property (nonatomic, strong, readwrite) PNPPlayer *localPlayer;
@property (nonatomic, strong, readwrite) PNPPlayer *opponentPlayer;
@property (nonatomic, copy, readwrite) NSString *matchChannelName;
@property (nonatomic, strong) PubNub *client;

@end

@implementation PNPMatchUpdater

- (instancetype)initWithClient:(PubNub *)client andMatchProposal:(PNPMatchProposal *)matchProposal{
    self = [super init];
    if (self) {
        _client = client;
        [_client addListener:self];
        PNPPlayer *localPlayer = nil;
        PNPPlayer *opponent = nil;
        
        if ([matchProposal.creator isLocalPlayerForClient:_client]) {
            localPlayer = matchProposal.creator;
            opponent = matchProposal.opponent;
        } else {
            localPlayer = matchProposal.opponent;
            opponent = matchProposal.creator;
        }
        _localPlayer = localPlayer;
        _opponentPlayer = opponent;
        _matchChannelName = matchProposal.matchChannelName;
        [_client subscribeToChannels:@[_matchChannelName] withPresence:YES];
    }
    return self;
}

+ (instancetype)matchUpdaterWithClient:(PubNub *)client andMatchProposal:(PNPMatchProposal *)matchProposal {
    return [[self alloc] initWithClient:client andMatchProposal:matchProposal];
}

- (void)updateLocalPlayerPosition:(CGPoint)position {
    PNPMatchUpdate *update = [PNPMatchUpdate updateWithPosition:position andPlayer:self.localPlayer];
    [self.client publish:update.JSONFormattedMessage toChannel:self.matchChannelName withCompletion:^(PNPublishStatus * _Nonnull status) {
        
    }];
}

#pragma mark - PNObjectEventListener

- (void)client:(PubNub *)client didReceiveMessage:(PNMessageResult *)message {
#warning also check channel
    if ([PNPMatchUpdate canBeInitializedWithDictionary:message.data.message]) {
        PNPMatchUpdate *update = [[PNPMatchUpdate alloc] initWithDictionary:message.data.message];
        // don't update with local player
        if (![update.player isEqualToPlayer:self.localPlayer]) {
            [self.delegate matchUpdater:self receivedUpdate:update];
        }
    }
}


@end

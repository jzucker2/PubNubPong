//
//  PNPLobby.h
//  PubNubPong
//
//  Created by Jordan Zucker on 6/15/16.
//  Copyright © 2016 Jordan Zucker. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PNPPlayer;
@class PubNub;

@protocol PNPLobbyDelegate;

@interface PNPLobby : NSObject

- (instancetype)initWithLocalPlayer:(PNPPlayer *)localPlayer andClient:(PubNub *)client;
+ (instancetype)lobbyWithLocalPlayer:(PNPPlayer *)localPlayer andClient:(PubNub *)client;

@property (nonatomic, weak) id<PNPLobbyDelegate> delegate;
@property (nonatomic, strong, readonly) NSArray<PNPPlayer *> *allPlayers;
@property (nonatomic, strong, readonly) NSArray<PNPPlayer *> *allNonLocalPlayers;

- (void)updateAllPlayersInLobby;
- (PNPPlayer *)randomPlayerFromLobby;

@end

@protocol PNPLobbyDelegate <NSObject>

- (void)lobby:(PNPLobby *)lobby updatedAllPlayers:(NSArray<PNPPlayer *> *)updatedAllPlayers;

@end

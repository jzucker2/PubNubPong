//
//  PNPMatchmaker.h
//  PubNubPong
//
//  Created by Jordan Zucker on 6/15/16.
//  Copyright © 2016 Jordan Zucker. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JSONFormatting.h"

@class PNPPlayer;
@class PubNub;
@class PNMessageResult;

@protocol PNPMatchmakerDelegate;

@interface PNPMatchProposal : NSObject <JSONFormatting>

@property (nonatomic, strong, readonly) PNPPlayer *creator;
@property (nonatomic, strong, readonly) PNPPlayer *opponent;
@property (nonatomic, copy, readonly) NSString *matchChannelName;

- (instancetype)initWithCreator:(PNPPlayer *)creator andOpponent:(PNPPlayer *)opponent andMatchChannelName:(NSString *)matchChannelName;
+ (instancetype)proposalWithCreator:(PNPPlayer *)creator andOpponent:(PNPPlayer *)opponent andMatchChannelName:(NSString *)matchChannelName;
- (instancetype)initWithPubNubMessageResult:(PNMessageResult *)pubNubMessageResult;
+ (instancetype)proposalFromPubNubMessageResult:(PNMessageResult *)pubNubMessageResult;

@end

@interface PNPMatchmaker : NSObject

- (instancetype)initWithLocalPlayer:(PNPPlayer *)localPlayer andClient:(PubNub *)client;
+ (instancetype)matchmakerWithLocalPlayer:(PNPPlayer *)localPlayer andClient:(PubNub *)client;

- (BOOL)proposeMatchToPlayer:(PNPPlayer *)opponent; // if yes, then match has been proposed, if no then match was not proposed

@property (nonatomic, weak) id<PNPMatchmakerDelegate> delegate;

@end

@protocol PNPMatchmakerDelegate <NSObject>

- (void)matchmaker:(PNPMatchmaker *)matchmaker receivedMatchProposal:(PNPMatchProposal *)proposal;

@end

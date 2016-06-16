//
//  PNPMatchUpdater.h
//  PubNubPong
//
//  Created by Jordan Zucker on 6/16/16.
//  Copyright © 2016 Jordan Zucker. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JSONFormatting.h"

@class PNPPlayer;
@class PubNub;

//@interface PNPMatchUpdateComponent : NSObject <JSONFormatting>
//@property (nonatomic, strong, readonly) PNPPlayer *player;
//@property (nonatomic, assign, readonly) CGPoint position;
//- (instancetype)initWithPosition:(CGPoint)position andPlayer:(PNPPlayer *)player;
//+ (instancetype)componentWithPosition:(CGPoint)position andPlayer:(PNPPlayer *)player;
//
//@end

@interface PNPMatchUpdate : NSObject <JSONFormatting>
//@property (nonatomic, strong, readonly) PNPMatchUpdateComponent *localPlayer;
//@property (nonatomic, strong, readonly) PNPMatchUpdateComponent *opponentPlayer;
@property (nonatomic, strong, readonly) PNPPlayer *player;
@property (nonatomic, assign, readonly) CGPoint position;
- (instancetype)initWithPosition:(CGPoint)position andPlayer:(PNPPlayer *)player;
+ (instancetype)updateWithPosition:(CGPoint)position andPlayer:(PNPPlayer *)player;
@end

@protocol PNPMatchUpdaterDelegate;

@interface PNPMatchUpdater : NSObject

@property (nonatomic, strong, readonly) PNPPlayer *localPlayer;
@property (nonatomic, strong, readonly) PNPPlayer *opponentPlayer;
@property (nonatomic, weak) id<PNPMatchUpdaterDelegate> delegate;

- (instancetype)initWithClient:(PubNub *)client localPlayer:(PNPPlayer *)localPlayer andOpponent:(PNPPlayer *)opponentPlayer;
+ (instancetype)matchUpdaterWithClient:(PubNub *)client localPlayer:(PNPPlayer *)localPlayer andOpponent:(PNPPlayer *)opponentPlayer;

// publish method?
- (void)updateLocalPlayerPosition:(CGPoint)position;
@end

@protocol PNPMatchUpdaterDelegate <NSObject>

- (void)matchUpdater:(PNPMatchUpdater *)matchUpdater receivedUpdate:(PNPMatchUpdate *)matchUpdate;

@end

//
//  PNPMessenger.h
//  PubNubPong
//
//  Created by Jordan Zucker on 6/13/16.
//  Copyright © 2016 Jordan Zucker. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol JSONFormatting <NSObject>
- (id)JSONFormattedMessage;
@end

@class PNPPaddleView;
@class PNPBallView;
@class PubNub;
@class PNMessageResult;

@interface PNPMessageComponent : NSObject <JSONFormatting>
@property (nonatomic, copy, readonly) NSString *uniqueIdentifier;
@property (nonatomic, assign, readonly) CGPoint position;
- (instancetype)initWithPosition:(CGPoint)position andUniqueIdentifier:(NSString *)uniqueIdentifier;
+ (instancetype)componentWithJSONDictionary:(NSDictionary *)dictionary andUniqueIdentifier:(NSString *)uniqueIdentifier;
@end

@interface PNPMessage : NSObject <JSONFormatting>
@property (nonatomic, strong, readonly) PNPMessageComponent *myPaddle;
@property (nonatomic, strong, readonly) PNPMessageComponent *opponentPaddle;
@property (nonatomic, strong, readonly) PNPMessageComponent *ball;
- (instancetype)initWithMyPosition:(PNPMessageComponent *)myPaddlePosition opponentPosition:(PNPMessageComponent *)opponentPaddlePosition ballPosition:(PNPMessageComponent *)ballPosition;
+ (instancetype)messageWithMyPosition:(PNPMessageComponent *)myPaddlePosition opponentPosition:(PNPMessageComponent *)opponentPaddlePosition ballPosition:(PNPMessageComponent *)ballPosition;
@end

@protocol PNPMessengerDelegate;

@interface PNPMessenger : NSObject

@property (nonatomic, strong, readonly) PNPPaddleView *myPaddle;
@property (nonatomic, strong, readonly) PNPPaddleView *opponentPaddle;
@property (nonatomic, strong, readonly) PNPBallView *ball;
@property (nonatomic, strong, readonly) PubNub *client;
@property (nonatomic, weak) id<PNPMessengerDelegate> delegate;

- (instancetype)initWithClient:(PubNub *)client myPaddle:(PNPPaddleView *)myPaddle opponentPaddle:(PNPPaddleView *)opponentPaddle andBall:(PNPBallView *)ball;
- (void)publishMyAnchorPoint:(CGPoint)anchorPoint onChannel:(NSString *)channelName;

@end

@protocol PNPMessengerDelegate <NSObject>

- (void)messenger:(PNPMessenger *)messenger receivedMessage:(PNPMessage *)message;

@end

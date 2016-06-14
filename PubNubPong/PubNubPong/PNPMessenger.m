//
//  PNPMessenger.m
//  PubNubPong
//
//  Created by Jordan Zucker on 6/13/16.
//  Copyright © 2016 Jordan Zucker. All rights reserved.
//

#import <PubNub/PubNub.h>
#import "PNPMessenger.h"
#import "PNPBallView.h"
#import "PNPPaddleView.h"

@interface PNPMessageComponent ()
@property (nonatomic, copy, readwrite) NSString *uniqueIdentifier;
@property (nonatomic, assign, readwrite) CGPoint position;
@end

@implementation PNPMessageComponent

- (instancetype)initWithPosition:(CGPoint)position andUniqueIdentifier:(NSString *)uniqueIdentifier {
    self = [super init];
    if (self) {
        _uniqueIdentifier = uniqueIdentifier.copy;
        _position = position;
    }
    return self;
}

+ (instancetype)componentWithJSONDictionary:(NSDictionary *)dictionary andUniqueIdentifier:(NSString *)uniqueIdentifier {
    NSParameterAssert(uniqueIdentifier);
    NSParameterAssert(dictionary);
    NSParameterAssert(dictionary[uniqueIdentifier]);
    NSDictionary *positionDict = dictionary[uniqueIdentifier];
    NSParameterAssert([positionDict isKindOfClass:[NSDictionary class]]);
    NSParameterAssert(positionDict[@"x"] && positionDict[@"y"]);
    CGPoint position = CGPointMake([positionDict[@"x"] floatValue],  [positionDict[@"y"] floatValue]);
    return [[self alloc] initWithPosition:position andUniqueIdentifier:uniqueIdentifier];
}

- (id)JSONFormattedMessage {
    return @{
             self.uniqueIdentifier: @{
                     @"x": [NSString stringWithFormat:@"%f", self.position.x],
                     @"y": [NSString stringWithFormat:@"%f", self.position.y]
                     },
             };
}

@end

@interface PNPMessage ()
@property (nonatomic, strong, readwrite) PNPMessageComponent *myPaddle;
@property (nonatomic, strong, readwrite) PNPMessageComponent *opponentPaddle;
@property (nonatomic, strong, readwrite) PNPMessageComponent *ball;
@end

@implementation PNPMessage

- (instancetype)initWithMyPosition:(PNPMessageComponent *)myPaddlePosition opponentPosition:(PNPMessageComponent *)opponentPaddlePosition ballPosition:(PNPMessageComponent *)ballPosition {
    self = [super init];
    if (self) {
        _myPaddle = myPaddlePosition;
        _opponentPaddle = opponentPaddlePosition;
        _ball = ballPosition;
    }
    return self;
}

+ (instancetype)messageWithMyPosition:(PNPMessageComponent *)myPaddlePosition opponentPosition:(PNPMessageComponent *)opponentPaddlePosition ballPosition:(PNPMessageComponent *)ballPosition {
    return [[self alloc] initWithMyPosition:myPaddlePosition opponentPosition:opponentPaddlePosition ballPosition:ballPosition];
}

- (id)JSONFormattedMessage {
    NSMutableDictionary *messageDict = [NSMutableDictionary dictionary];
    if (self.myPaddle) {
        [messageDict addEntriesFromDictionary:[self.myPaddle JSONFormattedMessage]];
    }
    if (self.opponentPaddle) {
        [messageDict addEntriesFromDictionary:[self.opponentPaddle JSONFormattedMessage]];
    }
    if (self.ball) {
        [messageDict addEntriesFromDictionary:[self.ball JSONFormattedMessage]];
    }
    return messageDict.copy;
}

@end

@interface PNPMessenger () <
                            PNObjectEventListener
                            >

@property (nonatomic, strong, readwrite) PNPPaddleView *myPaddle;
@property (nonatomic, strong, readwrite) PNPPaddleView *opponentPaddle;
@property (nonatomic, strong, readwrite) PNPBallView *ball;
@property (nonatomic, strong, readwrite) PubNub *client;
@end;

@implementation PNPMessenger

- (instancetype)initWithClient:(PubNub *)client myPaddle:(PNPPaddleView *)myPaddle opponentPaddle:(PNPPaddleView *)opponentPaddle andBall:(PNPBallView *)ball {
    self = [super init];
    if (self) {
        _client = client;
        [_client addListener:self];
        _myPaddle = myPaddle;
        _opponentPaddle = opponentPaddle;
        _ball = ball;
    }
    return self;
}

- (void)publishMyAnchorPoint:(CGPoint)anchorPoint onChannel:(NSString *)channelName {
    PNPMessageComponent *myPosition = [[PNPMessageComponent alloc] initWithPosition:anchorPoint andUniqueIdentifier:self.client.uuid];
    PNPMessage *message = [PNPMessage messageWithMyPosition:myPosition opponentPosition:nil ballPosition:nil];
    [self.client publish:message.JSONFormattedMessage toChannel:channelName withCompletion:^(PNPublishStatus * _Nonnull status) {
        if (status.isError) {
            NSLog(@"status: %@", status.debugDescription);
        }
    }];
}

- (PNPMessage *)messageWithPubNubMessageResult:(PNMessageResult *)pubNubMessageResult {
    PNPMessage *message = nil;
    if (self.opponentPaddle) {
        NSString *opponentUniqueIdentifier = self.opponentPaddle.uniqueIdentifier;
        if (pubNubMessageResult.data.message[opponentUniqueIdentifier]) {
            PNPMessageComponent *opponentPosition = [PNPMessageComponent componentWithJSONDictionary:pubNubMessageResult.data.message andUniqueIdentifier:opponentUniqueIdentifier];
            message = [PNPMessage messageWithMyPosition:nil opponentPosition:opponentPosition ballPosition:nil];
        }
    }
    return message;
}

#pragma mark - PNObjectEventListener

- (void)client:(PubNub *)client didReceiveMessage:(PNMessageResult *)message {
    PNPMessage *translatedMessage = [self messageWithPubNubMessageResult:message];
    if (translatedMessage) {
        [self.delegate messenger:self receivedMessage:translatedMessage];
    }
}

@end

//
//  PNPPlayer.m
//  PubNubPong
//
//  Created by Jordan Zucker on 6/15/16.
//  Copyright © 2016 Jordan Zucker. All rights reserved.
//

#import <PubNub/PubNub.h>
#import "PNPPlayer.h"

@interface PNPPlayer ()
@property (nonatomic, copy, readwrite) NSString *uniqueIdentifier;

@end

@implementation PNPPlayer

- (instancetype)initWithUniqueIdentifier:(NSString *)uniqueIdentifier {
    NSParameterAssert(uniqueIdentifier);
    self = [super init];
    if (self) {
        _uniqueIdentifier = uniqueIdentifier;
    }
    return self;
}

+ (instancetype)playerWithUniqueIdentifier:(NSString *)uniqueIdentifier {
    return [[self alloc] initWithUniqueIdentifier:uniqueIdentifier];
}

- (instancetype)initWithPubNubMessageResult:(PNMessageResult *)pubNubMessageResult {
    NSParameterAssert(pubNubMessageResult);
    NSDictionary *payload = pubNubMessageResult.data.message;
    NSParameterAssert(payload);
    NSParameterAssert([payload[@"type"] isEqualToString:@"player"]);
    self = [self initWithUniqueIdentifier:payload[@"uniqueIdentifier"]];
    return self;
}

- (id)JSONFormattedMessage {
    return @{
             @"type": @"player",
             @"uniqueIdentifier": self.uniqueIdentifier,
             };
}

@end

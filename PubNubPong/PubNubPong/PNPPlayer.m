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

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    NSParameterAssert(dictionary);
    NSParameterAssert([dictionary[@"type"] isEqualToString:@"player"]);
    self = [self initWithUniqueIdentifier:dictionary[@"uniqueIdentifier"]];
    return self;
}

- (id)JSONFormattedMessage {
    return @{
             @"type": @"player",
             @"uniqueIdentifier": self.uniqueIdentifier,
             };
}

- (NSUInteger)hash {
//    return [self.item hash] ^ [self.uniqueIdentifier hash];
    return [self.uniqueIdentifier hash];
}

- (BOOL)isLocalPlayerForClient:(PubNub *)client {
    if (!client) {
        return NO;
    }
    return [self.uniqueIdentifier isEqualToString:client.uuid];
}

- (BOOL)isEqualToPlayer:(PNPPlayer *)player {
    if (!player) {
        return NO;
    }
    
    BOOL haveEqualIdentifiers = [self.uniqueIdentifier isEqualToString:player.uniqueIdentifier];
    
    return haveEqualIdentifiers;
}

- (BOOL)isEqual:(id)object {
    if (self == object) {
        return YES;
    }
    
    if (![object isKindOfClass:[PNPPlayer class]]) {
        return NO;
    }
    
    return [self isEqualToPlayer:object];
}

@end

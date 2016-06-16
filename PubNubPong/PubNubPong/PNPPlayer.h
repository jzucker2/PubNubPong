//
//  PNPPlayer.h
//  PubNubPong
//
//  Created by Jordan Zucker on 6/15/16.
//  Copyright © 2016 Jordan Zucker. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JSONFormatting.h"

@class PubNub;

@interface PNPPlayer : NSObject <JSONFormatting>

- (instancetype)initWithUniqueIdentifier:(NSString *)uniqueIdentifier;
+ (instancetype)playerWithUniqueIdentifier:(NSString *)uniqueIdentifier;

- (BOOL)isLocalPlayerForClient:(PubNub *)client;

- (BOOL)isEqualToPlayer:(PNPPlayer *)player;

@property (nonatomic, copy, readonly) NSString *uniqueIdentifier;

@end

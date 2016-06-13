//
//  PNPMessage.m
//  PubNubPong
//
//  Created by Jordan Zucker on 6/13/16.
//  Copyright © 2016 Jordan Zucker. All rights reserved.
//

#import "PNPMessage.h"

@implementation PNPMessage

- (instancetype)initWithPubNubMessage:(id)pubNubMessage {
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (id)JSONFormat {
    return @{
             @"point": @"point"
             };
}

@end

//
//  JSONFormatting.h
//  PubNubPong
//
//  Created by Jordan Zucker on 6/15/16.
//  Copyright © 2016 Jordan Zucker. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PNMessageResult;

@protocol JSONFormatting <NSObject>

- (id)JSONFormattedMessage;

@optional
- (instancetype)initWithPubNubMessageResult:(PNMessageResult *)pubNubMessageResult;
+ (BOOL)canBeInitializedWithPubNubMessageResult:(PNMessageResult *)pubNubMessageResult;

@end

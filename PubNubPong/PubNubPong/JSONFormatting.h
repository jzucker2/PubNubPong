//
//  JSONFormatting.h
//  PubNubPong
//
//  Created by Jordan Zucker on 6/15/16.
//  Copyright © 2016 Jordan Zucker. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol JSONFormatting <NSObject>

- (id)JSONFormattedMessage;

@optional
- (instancetype)initWithDictionary:(NSDictionary *)dictionary;
+ (BOOL)canBeInitializedWithDictionary:(NSDictionary *)dictionary;

@end

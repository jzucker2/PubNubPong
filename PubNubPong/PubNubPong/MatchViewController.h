//
//  MatchViewController.h
//  PubNubPong
//
//  Created by Jordan Zucker on 6/13/16.
//  Copyright © 2016 Jordan Zucker. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PubNub;

@interface MatchViewController : UIViewController

- (instancetype)initWithPubNubClient:(PubNub *)client;
+ (instancetype)matchViewControllerWithClient:(PubNub *)client;

@end

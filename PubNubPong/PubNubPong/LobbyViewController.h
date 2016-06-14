//
//  LobbyViewController.h
//  PubNubPong
//
//  Created by Jordan Zucker on 6/14/16.
//  Copyright © 2016 Jordan Zucker. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PubNub;

@interface LobbyViewController : UIViewController

- (instancetype)initWithClient:(PubNub *)client;
+ (instancetype)lobbyViewControllerWithClient:(PubNub *)client;

@end

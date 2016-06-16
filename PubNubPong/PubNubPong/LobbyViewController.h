//
//  LobbyViewController.h
//  PubNubPong
//
//  Created by Jordan Zucker on 6/14/16.
//  Copyright © 2016 Jordan Zucker. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PubNub;
@class PNPLobby;
@class PNPMatchmaker;

@interface LobbyViewController : UIViewController

- (instancetype)initWithClient:(PubNub *)client lobby:(PNPLobby *)lobby andMatchmaker:(PNPMatchmaker *)matchmaker;
+ (instancetype)lobbyViewControllerWithClient:(PubNub *)client lobby:(PNPLobby *)lobby andMatchmaker:(PNPMatchmaker *)matchmaker;

@end

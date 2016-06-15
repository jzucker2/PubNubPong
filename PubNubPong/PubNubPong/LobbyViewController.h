//
//  LobbyViewController.h
//  PubNubPong
//
//  Created by Jordan Zucker on 6/14/16.
//  Copyright © 2016 Jordan Zucker. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PNPLobby;
@class PNPMatchmaker;

@interface LobbyViewController : UIViewController

- (instancetype)initWithLobby:(PNPLobby *)lobby andMatchmaker:(PNPMatchmaker *)matchmaker;
+ (instancetype)lobbyViewControllerWithLobby:(PNPLobby *)lobby andMatchmaker:(PNPMatchmaker *)matchmaker;

@end

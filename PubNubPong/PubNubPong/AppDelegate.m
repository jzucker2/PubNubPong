//
//  AppDelegate.m
//  PubNubPong
//
//  Created by Jordan Zucker on 6/13/16.
//  Copyright © 2016 Jordan Zucker. All rights reserved.
//

#import <PubNub/PubNub.h>
#import "AppDelegate.h"
//#import "MatchViewController.h"
//#import "ChooseUsernameViewController.h"
#import "LobbyViewController.h"
#import "PNPConstants.h"
#import "PNPPlayer.h"
#import "PNPLobby.h"
#import "PNPMatchmaker.h"

@interface AppDelegate ()
@property (nonatomic, strong, readwrite) PubNub *client;
@property (nonatomic, strong) PNPPlayer *localPlayer;
@property (nonatomic, strong) PNPLobby *lobby;
@property (nonatomic, strong) PNPMatchmaker *matchmaker;
@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    PNConfiguration *config = [PNConfiguration configurationWithPublishKey:kPNPPubKey subscribeKey:kPNPSubKey];
    // need to configure heartbeat
//    config.subscribeMaximumIdleTime = 30.0f;
    // let's be aggressive with presence timeouts so the lobby doesn't get stale, this will also help with games too
    config.presenceHeartbeatValue = 30.0f;
    config.presenceHeartbeatInterval = 15.0f;
    config.heartbeatNotificationOptions = PNHeartbeatNotifyAll;
    self.client = [PubNub clientWithConfiguration:config];
    
    self.localPlayer = [PNPPlayer playerWithUniqueIdentifier:self.client.uuid];
//    MatchViewController *matchViewController = [MatchViewController matchViewControllerWithClient:self.client];
//    ChooseUsernameViewController *usernameViewController = [ChooseUsernameViewController usernameViewControllerWithClient:self.client];
    self.lobby = [PNPLobby lobbyWithLocalPlayer:self.localPlayer andClient:self.client];
    
    self.matchmaker = [PNPMatchmaker matchmakerWithLocalPlayer:self.localPlayer andClient:self.client];
    
    LobbyViewController *lobbyViewController = [LobbyViewController lobbyViewControllerWithLobby:self.lobby andMatchmaker:self.matchmaker];
    self.window.rootViewController = lobbyViewController;
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    [self.client unsubscribeFromAll];
}

@end

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

@interface AppDelegate () <
                            PNObjectEventListener
                            >
@property (nonatomic, strong, readwrite) PubNub *client;
@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    PNConfiguration *config = [PNConfiguration configurationWithPublishKey:kPNPPubKey subscribeKey:kPNPSubKey];
    config.heartbeatNotificationOptions = PNHeartbeatNotifyAll;
    // need to configure heartbeat
    self.client = [PubNub clientWithConfiguration:config];
    [self.client addListener:self];
    
//    MatchViewController *matchViewController = [MatchViewController matchViewControllerWithClient:self.client];
//    ChooseUsernameViewController *usernameViewController = [ChooseUsernameViewController usernameViewControllerWithClient:self.client];
    LobbyViewController *lobbyViewController = [LobbyViewController lobbyViewControllerWithClient:self.client];
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

#pragma mark - PNObjectEventListener

- (void)client:(PubNub *)client didReceiveStatus:(PNStatus *)status {
    if (status.isError) {
        NSLog(@"Client (%@) received error status: %@", client, status.debugDescription);
    }
}

@end

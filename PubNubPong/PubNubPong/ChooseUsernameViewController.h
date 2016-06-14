//
//  ChooseUsernameViewController.h
//  PubNubPong
//
//  Created by Jordan Zucker on 6/14/16.
//  Copyright © 2016 Jordan Zucker. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PubNub;

@interface ChooseUsernameViewController : UIViewController

- (instancetype)initWithClient:(PubNub *)client;
+ (instancetype)usernameViewControllerWithClient:(PubNub *)client;

@end

//
//  MatchViewController.h
//  PubNubPong
//
//  Created by Jordan Zucker on 6/16/16.
//  Copyright © 2016 Jordan Zucker. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PubNub;
@class PNPMatchUpdater;
@class PNPMatchProposal;

@interface MatchViewController : UIViewController

- (instancetype)initWithClient:(PubNub *)client matchProposal:(PNPMatchProposal *)matchProposal matchUpdater:(PNPMatchUpdater *)matchUpdater;
+ (instancetype)matchViewControllerWithClient:(PubNub *)client matchProposal:(PNPMatchProposal *)matchProposal matchUpdater:(PNPMatchUpdater *)matchUpdater;

@end

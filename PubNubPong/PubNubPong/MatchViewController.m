//
//  MatchViewController.m
//  PubNubPong
//
//  Created by Jordan Zucker on 6/16/16.
//  Copyright © 2016 Jordan Zucker. All rights reserved.
//

#import <PubNub/PubNub.h>
#import "PNPMatchmaker.h"
#import "PNPMatchUpdater.h"
#import "MatchViewController.h"

@interface MatchViewController () <
                                    PNPMatchUpdaterDelegate
                                    >
@property (nonatomic, strong) PubNub *client;
@property (nonatomic, strong) PNPMatchUpdater *updater;
@end

@implementation MatchViewController

- (instancetype)initWithClient:(PubNub *)client matchProposal:(PNPMatchProposal *)matchProposal matchUpdater:(PNPMatchUpdater *)matchUpdater {
    self = [super init];
    if (self) {
        _client = client;
        _updater = matchUpdater;
        _updater.delegate = self;
    }
    return self;
}

+ (instancetype)matchViewControllerWithClient:(PubNub *)client matchProposal:(PNPMatchProposal *)matchProposal matchUpdater:(PNPMatchUpdater *)matchUpdater {
    return [[self alloc] initWithClient:client matchProposal:matchProposal matchUpdater:matchUpdater];
}

#pragma mark - View

- (void)loadView {
    UIView *mainView = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    mainView.backgroundColor = [UIColor blackColor];
    self.view = mainView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - PNPMatchUpdaterDelegate

- (void)matchUpdater:(PNPMatchUpdater *)matchUpdater receivedUpdate:(PNPMatchUpdate *)matchUpdate {
    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

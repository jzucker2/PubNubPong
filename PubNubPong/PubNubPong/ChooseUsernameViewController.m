//
//  ChooseUsernameViewController.m
//  PubNubPong
//
//  Created by Jordan Zucker on 6/14/16.
//  Copyright © 2016 Jordan Zucker. All rights reserved.
//

#import <PubNub/PubNub.h>
#import "ChooseUsernameViewController.h"

@interface ChooseUsernameViewController () <
                                            UITextFieldDelegate
                                            >
@property (nonatomic, strong) PubNub *client;
@property (nonatomic, strong) UITextField *usernameTextField;
@property (nonatomic, strong) UIButton *submitUsernameButton;
@end

@implementation ChooseUsernameViewController

- (instancetype)initWithClient:(PubNub *)client {
    NSParameterAssert(client);
    self = [super init];
    if (self) {
        _client = client;
    }
    return self;
}

+ (instancetype)usernameViewControllerWithClient:(PubNub *)client {
    return [[self alloc] initWithClient:client];
}

- (void)loadView {
    UIView *mainView = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    mainView.backgroundColor = [UIColor lightGrayColor];
    self.view = mainView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.usernameTextField = [[UITextField alloc] initWithFrame:CGRectMake(30.0, 50.0, 150.0, 50.0)];
    self.usernameTextField.delegate = self;
    self.usernameTextField.borderStyle = UITextBorderStyleLine;
    self.usernameTextField.placeholder = @"Enter username";
    self.usernameTextField.returnKeyType = UIReturnKeyGo;
    [self.view addSubview:self.usernameTextField];
    
    self.submitUsernameButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.submitUsernameButton setTitle:@"Go" forState:UIControlStateNormal];
    [self.submitUsernameButton addTarget:self action:@selector(submitButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    CGRect usernameTextFieldRect = self.usernameTextField.frame;
    self.submitUsernameButton.frame = CGRectMake(usernameTextFieldRect.origin.x + usernameTextFieldRect.size.width + 15.0, usernameTextFieldRect.origin.y, 100.0, 50.0);
    [self.view addSubview:self.submitUsernameButton];
    
    [self.view setNeedsLayout];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.usernameTextField becomeFirstResponder];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
//    if (
//        !textField.text.length ||
//        [textField.text isEqualToString:@""] ||
//        [textField.text isEqualToString:@" "]
//        ) {
//        self.submitUsernameButton.enabled = NO;
//        return YES;
//    }
//    self.submitUsernameButton.enabled = YES;
//    return YES;
    [textField resignFirstResponder];
    [self submitUsername:textField.text];
    return YES;
}

#pragma mark - UIActions

- (void)submitButtonTapped:(UIButton *)sender {
    [self submitUsername:self.usernameTextField.text];
}

#pragma mark - Logic

- (void)submitUsername:(NSString *)username {
    // possibly validate username
    NSDictionary *state = @{
                            @"username": username,
                            };
    [self.client setState:state forUUID:self.client.uuid onChannel:@"pubnubpong" withCompletion:^(PNClientStateUpdateStatus * _Nonnull status) {
        if (status.isError) {
            NSLog(@"client (%@) with status: %@", self.client, status.debugDescription);
        }
    }];
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

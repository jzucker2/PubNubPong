//
//  PNPMessage.h
//  PubNubPong
//
//  Created by Jordan Zucker on 6/13/16.
//  Copyright © 2016 Jordan Zucker. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PNPPaddleView;
@class PNPBallView;

@interface PNPMessage : NSObject

//@property (nonatomic, assign) CGPoint myPaddlePoint;
//@property (nonatomic, assign) CGPoint opponentPaddlePoint;
//@property (nonatomic, assign) CGPoint ballPoint;

- (instancetype)initWithPubNubMessage:(id)pubNubMessage;
//- (instancetype)initWithMyPaddle:(PNPPaddleView *)myPaddle opponentPaddle:(PNPPaddleView *)opponentPaddle ball:(PNPBallView *)ball;
- (id)JSONFormat;

@end

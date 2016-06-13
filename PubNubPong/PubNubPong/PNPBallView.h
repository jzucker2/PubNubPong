//
//  PNPBallView.h
//  PubNubPong
//
//  Created by Jordan Zucker on 6/13/16.
//  Copyright © 2016 Jordan Zucker. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PNPBallView : UIView

- (instancetype)initWithSideLength:(CGFloat)sideLength;
+ (instancetype)ballWithSideLength:(CGFloat)sideLength;

@end

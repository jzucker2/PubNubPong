//
//  PNPPaddleView.h
//  PubNubPong
//
//  Created by Jordan Zucker on 6/13/16.
//  Copyright © 2016 Jordan Zucker. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PNPPaddleView : UIView

- (instancetype)initWithPaddleLength:(CGFloat)length;
+ (instancetype)paddleWithLength:(CGFloat)length;

@end

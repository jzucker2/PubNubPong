//
//  PNPPaddleView.m
//  PubNubPong
//
//  Created by Jordan Zucker on 6/13/16.
//  Copyright © 2016 Jordan Zucker. All rights reserved.
//

#import "PNPPaddleView.h"

@implementation PNPPaddleView

- (instancetype)initWithPaddleLength:(CGFloat)length {
    NSParameterAssert(length > 0);
    self = [super initWithFrame:CGRectMake(0.0, 0.0, length/4.0, length)];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
    }
    return self;
}

+ (instancetype)paddleWithLength:(CGFloat)length {
    return [[self alloc] initWithPaddleLength:length];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end

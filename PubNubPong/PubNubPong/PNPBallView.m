//
//  PNPBallView.m
//  PubNubPong
//
//  Created by Jordan Zucker on 6/13/16.
//  Copyright © 2016 Jordan Zucker. All rights reserved.
//

#import "PNPBallView.h"

@implementation PNPBallView

- (instancetype)initWithSideLength:(CGFloat)sideLength {
    NSParameterAssert(sideLength > 0);
    self = [super initWithFrame:CGRectMake(0.0, 0.0, sideLength, sideLength)];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
    }
    return self;
}

+ (instancetype)ballWithSideLength:(CGFloat)sideLength {
    return [[self alloc] initWithSideLength:sideLength];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end

//
//  PNPPaddleView.m
//  PubNubPong
//
//  Created by Jordan Zucker on 6/13/16.
//  Copyright © 2016 Jordan Zucker. All rights reserved.
//

#import "PNPPaddleView.h"

@interface PNPPaddleView ()
@property (nonatomic, assign, readwrite) CGFloat length;
@property (nonatomic, copy, readwrite) NSString *uniqueIdentifier;

@end

@implementation PNPPaddleView

- (instancetype)initWithPaddleLength:(CGFloat)length andUniqueIdentifier:(NSString *)uniqueIdentifier {
    NSParameterAssert(length > 0);
    NSParameterAssert(uniqueIdentifier);
    self = [super initWithFrame:CGRectMake(0.0, 0.0, length/4.0, length)];
    if (self) {
        _length = length;
        _uniqueIdentifier = uniqueIdentifier.copy;
        self.backgroundColor = [UIColor whiteColor];
    }
    return self;
}

+ (instancetype)paddleWithLength:(CGFloat)length andUniqueIdentifier:(NSString *)uniqueIdentifier {
    return [[self alloc] initWithPaddleLength:length andUniqueIdentifier:uniqueIdentifier];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end

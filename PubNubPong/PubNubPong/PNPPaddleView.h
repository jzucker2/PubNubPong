//
//  PNPPaddleView.h
//  PubNubPong
//
//  Created by Jordan Zucker on 6/13/16.
//  Copyright © 2016 Jordan Zucker. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PNPPaddleView : UIView

@property (nonatomic, assign, readonly) CGFloat length;
@property (nonatomic, copy, readonly) NSString *uniqueIdentifier;

- (instancetype)initWithPaddleLength:(CGFloat)length andUniqueIdentifier:(NSString *)uniqueIdentifier;
+ (instancetype)paddleWithLength:(CGFloat)length andUniqueIdentifier:(NSString *)uniqueIdentifier;

@end

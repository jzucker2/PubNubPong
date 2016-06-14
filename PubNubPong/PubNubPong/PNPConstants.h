//
//  PNPConstants.h
//  PubNubPong
//
//  Created by Jordan Zucker on 6/14/16.
//  Copyright © 2016 Jordan Zucker. All rights reserved.
//

#ifndef PNPConstants_h
#define PNPConstants_h

static NSString * const kPNPPubKey = @"pub-c-0340cca1-7cd2-4a44-94a9-f51582bdd384";
static NSString * const kPNPSubKey = @"sub-c-8df5f212-3280-11e6-98f9-0619f8945a4f";

static NSString * const kPNPLobbyChannel = @"PongLobby";

static NSString * const kPNPBallIdentifier = @"PongBall";

#define PNPWeakify(__var) \
__weak __typeof__(__var) __var ## _weak_ = (__var)

#define PNPStrongify(__var) \
_Pragma("clang diagnostic push"); \
_Pragma("clang diagnostic ignored  \"-Wshadow\""); \
__strong __typeof__(__var) __var = __var ## _weak_; \
_Pragma("clang diagnostic pop") \

#endif /* PNPConstants_h */

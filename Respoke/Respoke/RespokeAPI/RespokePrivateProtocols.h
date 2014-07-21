//
//  RespokePrivateProtocols.h
//  Respoke
//
//  Created by Jason Adams on 7/20/14.
//  Copyright (c) 2014 Ninjanetic Design Inc. All rights reserved.
//

#ifndef Respoke_RespokePrivateProtocols_h
#define Respoke_RespokePrivateProtocols_h


@class RespokeCall;


@protocol RespokePrivateCallDelegate

- (void)callCreated:(RespokeCall*)call;
- (void)callTerminated:(RespokeCall*)call;

@end


#endif

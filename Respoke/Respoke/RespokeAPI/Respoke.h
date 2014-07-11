//
//  Respoke.h
//  Respoke
//
//  Created by Jason Adams on 7/7/14.
//  Copyright (c) 2014 Ninjanetic Design Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RespokeClient.h"


@interface Respoke : NSObject

+ (Respoke *)sharedInstance;
- (RespokeClient*)createClientWithAppID:(NSString*)appID developmentMode:(BOOL)developmentMode;
- (void)startCallWithEndpoint:(NSString*)endpoint remoteVideoView:(UIView*)newRemoteView localVideoView:(UIView*)newLocalView;

@end

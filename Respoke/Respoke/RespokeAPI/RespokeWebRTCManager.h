//
//  RespokeWebRTCManager.h
//  Respoke
//
//  Created by Jason Adams on 7/7/14.
//  Copyright (c) 2014 Ninjanetic Design Inc. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface RespokeWebRTCManager : NSObject 

- (void)startCallWithURL:(NSString*)url remoteVideoView:(UIView*)newRemoteView localVideoView:(UIView*)newLocalView;

@end

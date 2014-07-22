//
//  RespokeEndpoint.h
//  Respoke
//
//  Created by Jason Adams on 7/14/14.
//  Copyright (c) 2014 Ninjanetic Design Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RespokeSignalingChannel.h"
#import "RespokeCall.h"


@protocol RespokeEndpointDelegate;


@interface RespokeEndpoint : NSObject

@property NSString *endpointID;
@property NSMutableArray *connections;
@property (weak) id <RespokeEndpointDelegate> delegate;

- (instancetype)initWithSignalingChannel:(RespokeSignalingChannel*)channel;
- (void)sendMessage:(NSString*)message successHandler:(void (^)(void))successHandler errorHandler:(void (^)(NSString*))errorHandler;
- (RespokeCall*)startVideoCallWithDelegate:(id <RespokeCallDelegate>)delegate remoteVideoView:(UIView*)newRemoteView localVideoView:(UIView*)newLocalView;
- (RespokeCall*)startAudioCallWithDelegate:(id <RespokeCallDelegate>)delegate;

@end


@protocol RespokeEndpointDelegate <NSObject>

- (void)onMessage:(NSString*)message sender:(RespokeEndpoint*)sender;

@end

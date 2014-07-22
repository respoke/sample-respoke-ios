//
//  RespokeCall.h
//  Respoke
//
//  Created by Jason Adams on 7/18/14.
//  Copyright (c) 2014 Ninjanetic Design Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RespokeSignalingChannel.h"


@protocol RespokeCallDelegate;
@class RespokeEndpoint;


@interface RespokeCall : NSObject

@property id <RespokeCallDelegate> delegate;
@property (weak) UIView *localView;
@property (weak) UIView *remoteView;
@property RespokeEndpoint *endpoint;
@property NSString *sessionID;
@property NSString *toConnection;
@property BOOL audioOnly;

- (instancetype)initWithSignalingChannel:(RespokeSignalingChannel*)channel;
- (instancetype)initWithSignalingChannel:(RespokeSignalingChannel*)channel incomingCallSDP:(NSDictionary*)sdp;
- (void)startCall;
- (void)answerCall;
- (void)hangup;
- (void)muteVideo:(BOOL)mute;
- (void)muteAudio:(BOOL)mute;
- (void)hangupReceived;
- (void)answerReceived:(NSDictionary*)remoteSDP fromConnection:(NSString*)remoteConnection;
- (void)connectedReceived;
- (void)iceCandidatesReceived:(NSArray*)candidates;

@end


@protocol RespokeCallDelegate <NSObject>

- (void)onError:(NSString*)errorMessage sender:(RespokeCall*)sender;
- (void)onHangup:(RespokeCall*)sender;
- (void)onConnected:(RespokeCall*)sender;

@end

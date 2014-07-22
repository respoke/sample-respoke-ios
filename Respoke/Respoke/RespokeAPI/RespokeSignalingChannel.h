//
//  RespokeSignalingChannel.h
//  Respoke
//
//  Created by Jason Adams on 7/13/14.
//  Copyright (c) 2014 Ninjanetic Design Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SocketIO.h"
#import "SocketIOPacket.h"
#import "APITransaction.h"


@protocol RespokeSignalingChannelConnectionDelegate;
@protocol RespokeSignalingChannelErrorDelegate;
@protocol RespokeSignalingChannelGroupDelegate;
@protocol RespokeSignalingChannelClientDelegate;


@interface RespokeSignalingChannel : NSObject {
    NSString *appToken;
    SocketIO *socketIO;
    BOOL devMode;
    BOOL reconnect;
    NSString *connectionID;
}

@property (weak) id <RespokeSignalingChannelConnectionDelegate> connectionDelegate;
@property (weak) id <RespokeSignalingChannelErrorDelegate> errorDelegate;
@property (weak) id <RespokeSignalingChannelGroupDelegate> groupDelegate;
@property (weak) id <RespokeSignalingChannelClientDelegate> clientDelegate;
@property BOOL connected;

- (instancetype)initWithAppToken:(NSString*)token developmentMode:(BOOL)developmentMode;
- (void)authenticate;
- (void)sendRESTMessage:(NSString *)httpMethod url:(NSString *)url data:(NSDictionary*)data responseHandler:(void (^)(id, NSString*))responseHandler;
- (void)disconnect;

@end


@class RespokeCall;
@class RespokeEndpoint;


@protocol RespokeSignalingChannelConnectionDelegate <NSObject>

- (void)onConnect:(RespokeSignalingChannel*)sender;
- (void)onDisconnect:(RespokeSignalingChannel*)sender;
- (void)onIncomingCall:(RespokeCall*)call sender:(RespokeSignalingChannel*)sender;

@end


@protocol RespokeSignalingChannelErrorDelegate <NSObject>

- (void)onError:(NSError *)error sender:(RespokeSignalingChannel*)sender;

@end


@protocol RespokeSignalingChannelGroupDelegate <NSObject>

- (void)onJoin:(NSDictionary*)params sender:(RespokeSignalingChannel*)sender;
- (void)onLeave:(NSDictionary*)params sender:(RespokeSignalingChannel*)sender;
- (void)onMessage:(NSDictionary*)params sender:(RespokeSignalingChannel*)sender;

@end


@protocol RespokeSignalingChannelClientDelegate

- (void)callCreated:(RespokeCall*)call;
- (void)callTerminated:(RespokeCall*)call;
- (RespokeCall*)callWithID:(NSString*)sessionID;
- (void)endpointDiscovered:(RespokeEndpoint*)endpoint;
- (void)endpointDisappeared:(RespokeEndpoint*)endpoint;
- (RespokeEndpoint*)endpointWithID:(NSString*)endpointID;

@end

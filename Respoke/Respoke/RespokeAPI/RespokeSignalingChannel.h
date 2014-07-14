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


@interface RespokeSignalingChannel : NSObject {
    NSString *appToken;
    SocketIO *socketIO;
    BOOL devMode;
    BOOL reconnect;
}

@property (weak) id <RespokeSignalingChannelConnectionDelegate> connectionDelegate;
@property (weak) id <RespokeSignalingChannelErrorDelegate> errorDelegate;
@property BOOL connected;

- (instancetype)initWithAppToken:(NSString*)token developmentMode:(BOOL)developmentMode;
- (void)authenticate;
- (void)sendRESTMessage:(NSString *)httpMethod url:(NSString *)url responseHandler:(void (^)(id, NSString*))responseHandler;

@end


@protocol RespokeSignalingChannelConnectionDelegate <NSObject>

- (void)onConnect:(RespokeSignalingChannel*)sender;
- (void)onDisconnect:(RespokeSignalingChannel*)sender;

@end


@protocol RespokeSignalingChannelErrorDelegate <NSObject>

- (void)onError:(NSError *)error sender:(RespokeSignalingChannel*)sender;

@end

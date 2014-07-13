//
//  RespokeClient.m
//  Respoke
//
//  Created by Jason Adams on 7/11/14.
//  Copyright (c) 2014 Ninjanetic Design Inc. All rights reserved.
//

#import "RespokeClient.h"
#import "APIGetToken.h"
#import "APIDoOpen.h"
#import "SocketIO.h"
#import "SocketIOPacket.h"

#define RESPOKE_SOCKETIO_PORT 443
#define HEARTBEAT_INTERVAL 5000


@interface RespokeClient () <SocketIODelegate> {
    BOOL devMode;
    BOOL reconnect;
    NSString *applicationID;
    NSString *endpointID;
    SocketIO *socketIO;
    BOOL connected;
    BOOL heartbeatActive;
}

@end


@implementation RespokeClient


- (instancetype)initWithAppID:(NSString*)appID developmentMode:(BOOL)developmentMode
{
    if (self = [super init])
    {
        applicationID = appID;
        devMode = developmentMode;
        reconnect = developmentMode;
        socketIO = [[SocketIO alloc] initWithDelegate:self];
        socketIO.useSecure = YES;
    }

    return self;
}


- (void)connectWithEndpointID:(NSString*)endpoint errorHandler:(void (^)(NSString*))errorHandler
{
    endpointID = endpoint;

    if (([endpoint length]) && ([applicationID length]))
    {
        APIGetToken *getToken = [[APIGetToken alloc] init];
        getToken.appID = applicationID;
        getToken.endpointID = endpoint;

        [getToken goWithSuccessHandler:^{
            APIDoOpen *doOpen = [[APIDoOpen alloc] init];
            doOpen.tokenID = getToken.token;

            [doOpen goWithSuccessHandler:^{
                [self authenticateWithToken:doOpen.appToken];
            } errorHandler:^(NSString *errorMessage){
                errorHandler(errorMessage);
            }];

        } errorHandler:^(NSString *errorMessage){
            errorHandler(errorMessage);
        }];
    }
    else
    {
        errorHandler(@"AppID and endpointID must be specified");
    }
}


- (void)authenticateWithToken:(NSString*)appToken
{
    [socketIO connectToHost:[NSString stringWithFormat:@"%@", RESPOKE_BASE_URL] onPort:RESPOKE_SOCKETIO_PORT withParams:[NSDictionary dictionaryWithObjectsAndKeys:appToken, @"app-token", nil]];
}


- (void)heartbeatHandler
{
    if (connected)
    {
        heartbeatActive = YES;
        [socketIO sendMessage:@"heartbeat"];
        [self performSelector:@selector(heartbeatHandler) withObject:nil afterDelay:HEARTBEAT_INTERVAL];
    }
    else
    {
        // stop sending heartbeat
        heartbeatActive = NO;
    }
}


#pragma mark - SocketIODelegate


- (void)socketIODidConnect:(SocketIO *)socket
{
    NSLog(@"socketIODidConnect");
    connected = YES;

    if (!heartbeatActive)
    {
        // start the heartbeat, unless one is already scheduled
        [self heartbeatHandler];
    }

    [self.connectionDelegate onConnect:self];
}


- (void)socketIODidDisconnect:(SocketIO *)socket disconnectedWithError:(NSError *)error
{
    NSLog(@"socketIODidDisconnect: %@", [error localizedDescription]);
    connected = NO;
    [self.connectionDelegate onDisconnect:self];
}


- (void)socketIO:(SocketIO *)socket didReceiveMessage:(SocketIOPacket *)packet
{
    NSLog(@"didReceiveMessage >>> data: %@", packet.data);

}


- (void)socketIO:(SocketIO *)socket didReceiveJSON:(SocketIOPacket *)packet
{
    NSLog(@"didReceiveJSON");

}


- (void)socketIO:(SocketIO *)socket didReceiveEvent:(SocketIOPacket *)packet
{
    NSLog(@"didReceiveEvent >>> data: %@", packet.data);

}


- (void)socketIO:(SocketIO *)socket didSendMessage:(SocketIOPacket *)packet
{
    NSLog(@"didSendMessage");
}


- (void)socketIO:(SocketIO *)socket onError:(NSError *)error
{
    NSLog(@"------%@: socketIO error: %@", [self class], [error localizedDescription]);
    [self.errorDelegate onError:error fromClient:self];
}


@end

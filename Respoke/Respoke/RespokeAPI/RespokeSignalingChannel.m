//
//  RespokeSignalingChannel.m
//  Respoke
//
//  Created by Jason Adams on 7/13/14.
//  Copyright (c) 2014 Ninjanetic Design Inc. All rights reserved.
//

#import "RespokeSignalingChannel.h"
#import "RespokeCall.h"
#import "RespokeEndpoint.h"


#define RESPOKE_SOCKETIO_PORT 443


@interface RespokeSignalingChannel () <SocketIODelegate>

@end


@implementation RespokeSignalingChannel


- (instancetype)initWithAppToken:(NSString*)token developmentMode:(BOOL)developmentMode
{
    if (self = [super init])
    {
        appToken = token;
        devMode = developmentMode;
        reconnect = developmentMode;
    }

    return self;
}


- (void)authenticate
{
    socketIO = [[SocketIO alloc] initWithDelegate:self];
    socketIO.useSecure = YES;
    [socketIO connectToHost:[NSString stringWithFormat:@"%@", RESPOKE_BASE_URL] onPort:RESPOKE_SOCKETIO_PORT withParams:[NSDictionary dictionaryWithObjectsAndKeys:appToken, @"app-token", nil]];
}


- (void)sendRESTMessage:(NSString *)httpMethod url:(NSString *)url data:(NSDictionary*)data responseHandler:(void (^)(id, NSString*))responseHandler
{
    if (self.connected)
    {
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        [dict setObject:@{@"App-Token": appToken} forKey:@"headers"];
        [dict setObject:url forKey:@"url"];

        if (data)
        {
            [dict setObject:data forKey:@"data"];
        }
        
        [socketIO sendEvent:httpMethod withData:dict andAcknowledge:^(id argsData) {
            id response = argsData;
            NSString *errorString = nil;

            if (argsData)
            {
                if ([argsData isEqualToString:@"null"])
                {
                    response = nil;
                }
                else
                {
                    NSError *error;
                    id jsonResult = [NSJSONSerialization JSONObjectWithData:[argsData dataUsingEncoding:NSUTF8StringEncoding] options:0 error:&error];
                    if (!error)
                    {
                        response = jsonResult;

                        if ([jsonResult isKindOfClass:[NSDictionary class]])
                        {
                            errorString = [jsonResult objectForKey:@"error"];
                        }
                    }
                    else
                    {
                        errorString = @"Unexpected response received";
                    }
                }
            }
            else
            {
                errorString = @"Unexpected response received";
            }

            responseHandler(response, errorString);
        }];
    }
    else
    {
        responseHandler(nil, @"Not connected");
    }
}


#pragma mark - SocketIODelegate


- (void)socketIODidConnect:(SocketIO *)socket
{
    self.connected = YES;

    [self sendRESTMessage:@"post" url:@"/v1/endpointconnections" data:nil responseHandler:^(id response, NSString *errorMessage) {
        if (errorMessage)
        {
            [self.errorDelegate onError:[NSError errorWithDomain:NSURLErrorDomain code:5 userInfo:@{NSLocalizedDescriptionKey: @"Unexpected response received"}] sender:self];
        }
        else
        {
            if (response && ([response isKindOfClass:[NSDictionary class]]))
            {   
                connectionID = [response objectForKey:@"id"];
                [self.connectionDelegate onConnect:self];
            }
            else
            {
                [self.errorDelegate onError:[NSError errorWithDomain:NSURLErrorDomain code:5 userInfo:@{NSLocalizedDescriptionKey: @"Unexpected response received"}] sender:self];  
            }
        }
    }];
}


- (void)socketIODidDisconnect:(SocketIO *)socket disconnectedWithError:(NSError *)error
{
    NSLog(@"socketIODidDisconnect: %@", [error localizedDescription]);
    self.connected = NO;
    socketIO = nil;
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
    NSError *error;
    id jsonResult = [NSJSONSerialization JSONObjectWithData:[packet.data dataUsingEncoding:NSUTF8StringEncoding] options:0 error:&error];
    if (!error)
    {
        if (jsonResult && ([jsonResult isKindOfClass:[NSDictionary class]]))
        {
            NSDictionary *dict = (NSDictionary*)jsonResult;

            NSString *name = [dict objectForKey:@"name"];
            NSArray *args = [dict objectForKey:@"args"];

            if ([name isEqualToString:@"join"])
            {
                for (NSDictionary *eachInstance in args)
                {
                    [self.groupDelegate onJoin:eachInstance sender:self];
                }
            }
            else if ([name isEqualToString:@"leave"])
            {
                for (NSDictionary *eachInstance in args)
                {
                    [self.groupDelegate onLeave:eachInstance sender:self];
                }
            }
            else if ([name isEqualToString:@"message"])
            {
                for (NSDictionary *eachInstance in args)
                {
                    [self.groupDelegate onMessage:eachInstance sender:self];
                }
            }
            else if ([name isEqualToString:@"signal"])
            {
                for (NSDictionary *eachInstance in args)
                {
                    [self routeSignal:eachInstance];
                }
            }
        }
    }
}


- (void)socketIO:(SocketIO *)socket didSendMessage:(SocketIOPacket *)packet
{
//    NSLog(@"didSendMessage");
}


- (void)socketIO:(SocketIO *)socket onError:(NSError *)error
{
    NSLog(@"------%@: socketIO error: %@", [self class], [error localizedDescription]);
    [self.errorDelegate onError:error sender:self];
}


#pragma mark - misc


- (void)routeSignal:(NSDictionary*)message
{
    NSString *signal = [message objectForKey:@"signal"];
    NSDictionary *header = [message objectForKey:@"header"];
    NSString *from = [header objectForKey:@"from"];
    NSString *fromConnection = [header objectForKey:@"fromConnection"];
    
    if (signal && from)
    {
        NSError *error;
        id jsonResult = [NSJSONSerialization JSONObjectWithData:[signal dataUsingEncoding:NSUTF8StringEncoding] options:0 error:&error];
        if ((!error) && ([jsonResult isKindOfClass:[NSDictionary class]]))
        {
            NSString *signalType = [jsonResult objectForKey:@"signalType"];
            NSString *sessionID = [jsonResult objectForKey:@"sessionId"];
            NSString *target = [jsonResult objectForKey:@"target"];
            NSString *toConnection = [jsonResult objectForKey:@"toConnection"];

            if (sessionID && signalType)
            {
                RespokeCall *call = [self.clientDelegate callWithID:sessionID];

                if ([target isEqualToString:@"call"])
                {
                    if (call)
                    {
                        if ([signalType isEqualToString:@"hangup"])
                        {
                            [call hangupReceived];
                        }
                        else if ([signalType isEqualToString:@"answer"])
                        {
                            NSDictionary *sdp = [jsonResult objectForKey:@"sdp"];

                            [call answerReceived:sdp fromConnection:fromConnection];
                        }
                        else if ([signalType isEqualToString:@"connected"])
                        {
                            if ([toConnection isEqualToString:connectionID])
                            {
                                [call connectedReceived];
                            }
                            else
                            {
                                NSLog(@"Another device answered, hanging up.");
                                [call hangupReceived];
                            }
                        }
                        else if ([signalType isEqualToString:@"iceCandidates"])
                        {
                            NSArray *candidates = [jsonResult objectForKey:@"iceCandidates"];
                            [call iceCandidatesReceived:candidates];
                        }
                    }
                    else if ([signalType isEqualToString:@"offer"])
                    {
                        NSDictionary *sdp = [jsonResult objectForKey:@"sdp"];
                        
                        if (sdp)
                        {
                            // A remote device is trying to call us, so create a call instance to deal with it
                            RespokeCall *call = [[RespokeCall alloc] initWithSignalingChannel:self incomingCallSDP:sdp];
                            call.sessionID = sessionID;
                            call.toConnection = fromConnection;

                            RespokeEndpoint *endpoint = [self.clientDelegate endpointWithID:from];

                            if (!endpoint)
                            {
                                // If the endpoint that is calling is not a member of our group, create a new instance just for this call
                                endpoint = [[RespokeEndpoint alloc] initWithSignalingChannel:self];
                                endpoint.endpointID = from;

                                if (fromConnection)
                                {
                                    [endpoint.connections addObject:fromConnection];
                                }
                            }

                            call.endpoint = endpoint;
                            
                            [self.connectionDelegate onIncomingCall:call sender:self];
                        }
                        else
                        {
                            NSLog(@"------Error: Offer missing sdp");
                        }
                    }
                }
            }
            else
            {
                NSLog(@"------Error: signal is missing type or session ID. Ignoring.");
            }
        }
        else
        {
            NSLog(@"------Error: Could not parse signal data");
        }
    }
    else
    {
        NSLog(@"------Error: signal missing header data");
    }
}


@end

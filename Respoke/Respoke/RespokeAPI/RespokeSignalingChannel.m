//
//  RespokeSignalingChannel.m
//  Respoke
//
//  Created by Jason Adams on 7/13/14.
//  Copyright (c) 2014 Ninjanetic Design Inc. All rights reserved.
//

#import "RespokeSignalingChannel.h"

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
        socketIO = [[SocketIO alloc] initWithDelegate:self];
        socketIO.useSecure = YES;
    }

    return self;
}


- (void)authenticate
{
    [socketIO connectToHost:[NSString stringWithFormat:@"%@", RESPOKE_BASE_URL] onPort:RESPOKE_SOCKETIO_PORT withParams:[NSDictionary dictionaryWithObjectsAndKeys:appToken, @"app-token", nil]];
}


- (void)sendRESTMessage:(NSString *)httpMethod url:(NSString *)url responseHandler:(void (^)(id, NSString*))responseHandler
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:@{@"App-Token": appToken} forKey:@"headers"];
    [dict setObject:url forKey:@"url"];
    
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


#pragma mark - SocketIODelegate


- (void)socketIODidConnect:(SocketIO *)socket
{
    NSLog(@"socketIODidConnect");
    self.connected = YES;
    [self.connectionDelegate onConnect:self];
}


- (void)socketIODidDisconnect:(SocketIO *)socket disconnectedWithError:(NSError *)error
{
    NSLog(@"socketIODidDisconnect: %@", [error localizedDescription]);
    self.connected = NO;
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
    [self.errorDelegate onError:error sender:self];
}


@end

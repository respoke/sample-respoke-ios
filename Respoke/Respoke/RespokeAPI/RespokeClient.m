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
#import "RespokeSignalingChannel.h"


@interface RespokeClient () <SocketIODelegate, RespokeSignalingChannelConnectionDelegate, RespokeSignalingChannelErrorDelegate, RespokeSignalingChannelClientDelegate> {
    BOOL devMode;
    NSString *applicationID;
    NSString *applicationToken;
    NSString *endpointID;
    RespokeSignalingChannel *signalingChannel;
    NSMutableArray *calls;
    NSMutableArray *knownEndpoints;
}

@end


@implementation RespokeClient


- (instancetype)initWithAppID:(NSString*)appID developmentMode:(BOOL)developmentMode
{
    if (self = [super init])
    {
        applicationID = appID;
        devMode = developmentMode;
        calls = [[NSMutableArray alloc] init];
        knownEndpoints = [[NSMutableArray alloc] init];
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
                signalingChannel = [[RespokeSignalingChannel alloc] initWithAppToken:doOpen.appToken developmentMode:devMode];
                signalingChannel.connectionDelegate = self;
                signalingChannel.errorDelegate = self;
                signalingChannel.clientDelegate = self;
                [signalingChannel authenticate];
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


- (void)joinGroup:(NSString*)groupName errorHandler:(void (^)(NSString*))errorHandler joinHandler:(void (^)(RespokeGroup*))joinHandler
{
    if (signalingChannel && signalingChannel.connected)
    {
        if ([groupName length])
        {
            NSString *urlEndpoint = [NSString stringWithFormat:@"/v1/channels/%@/subscribers/", groupName];
            
            [signalingChannel sendRESTMessage:@"post" url:urlEndpoint data:nil responseHandler:^(id response, NSString *errorMessage) {
                if (errorMessage)
                {
                    errorHandler(errorMessage);
                }
                else
                {
                    if (!response)
                    {   
                        RespokeGroup *newGroup = [[RespokeGroup alloc] initWithGroupID:groupName appToken:applicationToken signalingChannel:signalingChannel endpointID:endpointID];
                        joinHandler(newGroup);
                    }
                    else
                    {
                        errorHandler(@"Unexpected response received");   
                    }
                }
            }];
        }
        else
        {
            errorHandler(@"Group name must be specified");
        }
    }
    else
    {
        errorHandler(@"The client must be connected before joining a group");
    }
}


#pragma mark - Private methods


#pragma mark - RespokeSignalingChannelConnectionDelegate


- (void)onConnect:(RespokeSignalingChannel*)sender
{
    [self.delegate onConnect:self];
}


- (void)onDisconnect:(RespokeSignalingChannel*)sender
{
    [calls removeAllObjects];
    [knownEndpoints removeAllObjects];
    [self.delegate onDisconnect:self];
    signalingChannel = nil;
}


- (void)onIncomingCall:(RespokeCall*)call sender:(RespokeSignalingChannel*)sender
{
    [self.delegate onIncomingCall:call sender:self];
}


- (void)onError:(NSError *)error sender:(RespokeSignalingChannel*)sender
{
    [self.delegate onError:error fromClient:self];
}


#pragma mark - RespokeSignalingChannelClientDelegate


- (void)callCreated:(RespokeCall*)call
{
    [calls addObject:call];
}


- (void)callTerminated:(RespokeCall*)call
{
    [calls removeObject:call];
}


- (RespokeCall*)callWithID:(NSString*)sessionID
{
    RespokeCall *call = nil;
    
    for (RespokeCall *eachCall in calls)
    {
        if ([eachCall.sessionID isEqualToString:sessionID])
        {
            call = eachCall;
            break;
        }
    }
    
    return call;
}


- (void)endpointDiscovered:(RespokeEndpoint*)endpoint
{
    [knownEndpoints addObject:endpoint];
}


- (void)endpointDisappeared:(RespokeEndpoint*)endpoint
{
    [knownEndpoints removeObject:endpoint];
}


- (RespokeEndpoint*)endpointWithID:(NSString*)endpointIDToFind
{
    RespokeEndpoint *endpoint = nil;

    for (RespokeEndpoint *eachEndpoint in knownEndpoints)
    {
        if ([eachEndpoint.endpointID isEqualToString:endpointIDToFind])
        {
            endpoint = eachEndpoint;
            break;
        }
    }

    return endpoint;
}


@end

//
//  RespokeGroup.m
//  Respoke
//
//  Created by Jason Adams on 7/13/14.
//  Copyright (c) 2014 Ninjanetic Design Inc. All rights reserved.
//

#import "RespokeGroup.h"


@interface RespokeGroup () <RespokeSignalingChannelGroupDelegate> {
    NSString *groupName;
    NSString *appToken;
    NSString *endpointID;
    RespokeSignalingChannel *signalingChannel;
    NSMutableArray *members;
}

@end


@implementation RespokeGroup


- (instancetype)initWithGroupID:(NSString*)groupID appToken:(NSString*)token signalingChannel:(RespokeSignalingChannel*)channel endpointID:(NSString*)endpoint
{
    if (self = [super init])
    {
        groupName = groupID;
        appToken = token;
        signalingChannel = channel;
        signalingChannel.groupDelegate = self;
        endpointID = endpoint;
        members = [[NSMutableArray alloc] init];
    }
    
    return self;
}


- (void)getMembersWithSuccessHandler:(void (^)(NSArray*))successHandler errorHandler:(void (^)(NSString*))errorHandler
{
    if ([groupName length])
    {
        NSString *urlEndpoint = [NSString stringWithFormat:@"/v1/channels/%@/subscribers/", groupName];
        
        [signalingChannel sendRESTMessage:@"get" url:urlEndpoint data:nil responseHandler:^(id response, NSString *errorMessage) {
            if (errorMessage)
            {
                errorHandler(errorMessage);
            }
            else
            {
                if ([response isKindOfClass:[NSArray class]])
                {
                    [members removeAllObjects];
                    NSMutableArray *nameList = [[NSMutableArray alloc] init];

                    for (NSDictionary *eachEntry in response)
                    {
                        NSString *newEndpointID = [eachEntry objectForKey:@"endpointId"];
                        NSString *newConnection = [eachEntry objectForKey:@"connectionId"];
                        
                        // Do not include ourselves in this list
                        if (![newEndpointID isEqualToString:endpointID])
                        {
                            RespokeEndpoint *existing = [self endpointWithName:newEndpointID];

                            if (existing)
                            {
                                [existing.connections addObject:newConnection];
                            }
                            else
                            {
                                RespokeEndpoint *newEndpoint = [[RespokeEndpoint alloc] init];
                                newEndpoint.endpointID = newEndpointID;
                                [newEndpoint.connections addObject:newConnection];
                                [members addObject:newEndpoint];

                                [nameList addObject:newEndpointID];
                            }
                        }
                    }

                    successHandler(nameList);
                }
                else
                {
                    errorHandler(@"Invalid response from server");
                }
            }
        }];
    }
    else
    {
        errorHandler(@"Group name must be specified");
    }
}


- (RespokeEndpoint*)endpointWithName:(NSString*)name
{
    RespokeEndpoint *existing = nil;

    for (RespokeEndpoint *each in members)
    {
        if ([each.endpointID isEqualToString:name])
        {
            existing = each;
            break;
        }
    }

    return existing;
}


#pragma mark - RespokeSignalingChannelGroupDelegate


- (void)onJoin:(NSDictionary*)params sender:(RespokeSignalingChannel*)sender
{
    // only pass on notifications about people other than ourselves
    NSString *endpoint = [params objectForKey:@"endpoint"];
    NSString *connection = [params objectForKey:@"connectionId"];
    
    if (![endpoint isEqualToString:endpointID])
    {
        RespokeEndpoint *existing = [self endpointWithName:endpoint];

        if (existing)
        {
            [existing.connections addObject:connection];
        }
        else
        {
            RespokeEndpoint *newEndpoint = [[RespokeEndpoint alloc] init];
            newEndpoint.endpointID = endpoint;
            [newEndpoint.connections addObject:connection];
            [members addObject:newEndpoint];
        }
        
        [self.delegate onJoin:endpoint sender:self];
    }
}


- (void)onLeave:(NSDictionary*)params sender:(RespokeSignalingChannel*)sender
{
    NSString *endpoint = [params objectForKey:@"endpoint"];
    if (![endpoint isEqualToString:endpointID])
    {
        // only pass on notifications about people other than ourselves
    }
}


@end

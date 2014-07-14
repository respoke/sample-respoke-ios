//
//  RespokeGroup.m
//  Respoke
//
//  Created by Jason Adams on 7/13/14.
//  Copyright (c) 2014 Ninjanetic Design Inc. All rights reserved.
//

#import "RespokeGroup.h"


@interface RespokeGroup () {
    NSString *groupName;
    NSString *appToken;
    RespokeSignalingChannel *signalingChannel;
}

@end


@implementation RespokeGroup


- (instancetype)initWithGroupID:(NSString*)groupID appToken:(NSString*)token signalingChannel:(RespokeSignalingChannel*)channel
{
    if (self = [super init])
    {
        groupName = groupID;
        appToken = token;
        signalingChannel = channel;
    }
    
    return self;
}


- (void)getMembersWithSuccessHandler:(void (^)(NSArray*))successHandler errorHandler:(void (^)(NSString*))errorHandler
{
    if ([groupName length])
    {
        NSString *urlEndpoint = [NSString stringWithFormat:@"/v1/channels/%@/subscribers/", groupName];
        
        [signalingChannel sendRESTMessage:@"get" url:urlEndpoint responseHandler:^(id response, NSString *errorMessage) {
            if (errorMessage)
            {
                errorHandler(errorMessage);
            }
            else
            {
                if ([response isKindOfClass:[NSArray class]])
                {
                    successHandler(response);
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


@end

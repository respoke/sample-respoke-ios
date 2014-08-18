//
//  ContactManager.h
//  Respoke
//
//  Created by Jason Adams on 8/17/14.
//  Copyright (c) 2014 Digium, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RespokeGroup.h"
#import "RespokeEndpoint.h"

#define ENDPOINT_MESSAGE_RECEIVED @"ENDPOINT_MESSAGE_RECEIVED"
#define GROUP_MEMBERSHIP_CHANGED @"GROUP_MEMBERSHIP_CHANGED"
#define ENDPOINT_DISCOVERED @"ENDPOINT_DISCOVERED"
#define ENDPOINT_DISAPPEARED @"ENDPOINT_DISAPPEARED"
#define ENDPOINT_JOINED_GROUP @"ENDPOINT_JOINED_GROUP"
#define ENDPOINT_LEFT_GROUP @"ENDPOINT_LEFT_GROUP"


@interface ContactManager : NSObject <RespokeGroupDelegate, RespokeEndpointDelegate>

@property NSString *username;
@property NSMutableArray *groups;
@property NSMutableDictionary *groupConnectionArrays;
@property NSMutableDictionary *groupEndpointArrays;
@property NSMutableDictionary *conversations;
@property NSMutableArray *allKnownEndpoints;

- (void)joinGroup:(NSString*)groupName successHandler:(void (^)(void))successHandler errorHandler:(void (^)(NSString*))errorHandler;
- (void)leaveGroup:(RespokeGroup*)group successHandler:(void (^)(void))successHandler errorHandler:(void (^)(NSString*))errorHandler;

@end

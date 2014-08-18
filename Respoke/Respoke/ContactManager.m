//
//  ContactManager.m
//  Respoke
//
//  Created by Jason Adams on 8/17/14.
//  Copyright (c) 2014 Digium, Inc. All rights reserved.
//

#import "ContactManager.h"
#import "AppDelegate.h"
#import "RespokeClient.h"
#import "RespokeConnection.h"
#import "Conversation.h"


@implementation ContactManager


- (instancetype)init
{
    if (self = [super init])
    {
        self.groups = [[NSMutableArray alloc] init];
        self.groupConnectionArrays = [[NSMutableDictionary alloc] init];
        self.groupEndpointArrays = [[NSMutableDictionary alloc] init];
        self.allKnownEndpoints = [[NSMutableArray alloc] init];
        self.conversations = [[NSMutableDictionary alloc] init];
    }

    return self;
}


- (void)joinGroup:(NSString*)groupName successHandler:(void (^)(void))successHandler errorHandler:(void (^)(NSString*))errorHandler
{
    [sharedRespokeClient joinGroup:groupName errorHandler:^(NSString *errorMessage) {
        errorHandler(errorMessage);
    } joinHandler:^(RespokeGroup *group) {
        // Become the delegate for this group
        group.delegate = self;
        [self.groups addObject:group];

        [group getMembersWithSuccessHandler:^(NSArray *memberList) {
            // Establish the connection and endpoint tracking arrays for this group
            [self.groupConnectionArrays setObject:[memberList mutableCopy] forKey:groupName];

            NSMutableArray *groupEndpoints = [NSMutableArray array];
            [self.groupEndpointArrays setObject:groupEndpoints forKey:groupName];

            // Evaluate each connection in the new group
            for (RespokeConnection *each in memberList)
            {
                // Find the endpoint to which the connection belongs
                RespokeEndpoint *parentEndpoint = [each getEndpoint];

                // If this endpoint is not known in any group, remember it
                if (NSNotFound == [self.allKnownEndpoints indexOfObject:parentEndpoint])
                {
                    [self.allKnownEndpoints addObject:parentEndpoint];
                    parentEndpoint.delegate = self;

                    // Start tracking the conversation with this endpoint
                    Conversation *conversation = [[Conversation alloc] initWithName:parentEndpoint.endpointID];
                    [self.conversations setObject:conversation forKey:parentEndpoint.endpointID];
                }

                // If this endpoint is not known in this specific group, remember it
                if (NSNotFound == [groupEndpoints indexOfObject:parentEndpoint])
                {
                    [groupEndpoints addObject:parentEndpoint];
                }
            }

            // Notify any UI listeners that group membership has changed
            [[NSNotificationCenter defaultCenter] postNotificationName:GROUP_MEMBERSHIP_CHANGED object:group userInfo:nil];

            successHandler();
        } errorHandler:^(NSString *errorMessage) {
            errorHandler(errorMessage);
        }];
    }];
}


- (void)leaveGroup:(RespokeGroup*)group successHandler:(void (^)(void))successHandler errorHandler:(void (^)(NSString*))errorHandler
{
    NSString *groupName = [group getGroupID];

    [group leaveWithSuccessHandler:^() {
        NSMutableArray *endpoints = [self.groupEndpointArrays objectForKey:groupName];

        // Purge all of the group data
        [self.groups removeObject:group];
        [self.groupEndpointArrays removeObjectForKey:groupName];
        [self.groupConnectionArrays removeObjectForKey:groupName];

        // Purge any endpoints that were only a member of this group from the combined endpoint list
        for (RespokeEndpoint *eachEndpoint in endpoints)
        {
            NSInteger membershipCount = 0;

            for (NSMutableArray *eachArray in [self.groupConnectionArrays allValues])
            {
                for (RespokeConnection *eachConnection in eachArray)
                {
                    // Find the endpoint to which the connection belongs
                    RespokeEndpoint *parentEndpoint = [eachConnection getEndpoint];

                    if (eachEndpoint == parentEndpoint)
                    {
                        membershipCount++;
                    }
                }
            }

            if (membershipCount == 0)
            {
                // This endpoint is not a member of any of the other groups, so remove it from the list
                [self.allKnownEndpoints removeObject:eachEndpoint];
            }
        }

        // Notify any UI listeners that group membership has changed
        [[NSNotificationCenter defaultCenter] postNotificationName:GROUP_MEMBERSHIP_CHANGED object:group userInfo:nil];

        successHandler();
    } errorHandler:^(NSString *errorMessage) {
        errorHandler(errorMessage);
    }];
}


#pragma mark - RespokeGroupDelegate


- (void)onJoin:(RespokeConnection*)connection sender:(RespokeGroup*)sender
{
    NSInteger index = [self.groups indexOfObject:sender];

    if (NSNotFound != index)
    {
        NSString *groupName = [sender getGroupID];

        // Get the list of known connections for this group
        NSMutableArray *groupConnections = [self.groupConnectionArrays objectForKey:groupName];
        [groupConnections addObject:connection];

        // Get the list of known endpoints for this group
        NSMutableArray *groupEndpoints = [self.groupEndpointArrays objectForKey:groupName];

        // Get the endpoint that owns this new connection
        RespokeEndpoint *parentEndpoint = [connection getEndpoint];

        // If this endpoint is not known anywhere, remember it
        if (NSNotFound == [self.allKnownEndpoints indexOfObject:parentEndpoint])
        {
            NSLog(@"Joined: %@", parentEndpoint.endpointID);
            [self.allKnownEndpoints addObject:parentEndpoint];
            parentEndpoint.delegate = self;

            // Start tracking the conversation with this endpoint
            Conversation *conversation = [[Conversation alloc] initWithName:parentEndpoint.endpointID];
            [self.conversations setObject:conversation forKey:parentEndpoint.endpointID];

            // Notify any UI listeners that a new endpoint has been discovered
            [[NSNotificationCenter defaultCenter] postNotificationName:ENDPOINT_DISCOVERED object:parentEndpoint userInfo:nil];
        }

        // If this endpoint is not known in this specific group, remember it
        if (NSNotFound == [groupEndpoints indexOfObject:parentEndpoint])
        {
            [groupEndpoints addObject:parentEndpoint];

            // Notify any UI listeners that a new endpoint has joined this group
            [[NSNotificationCenter defaultCenter] postNotificationName:ENDPOINT_JOINED_GROUP object:sender userInfo:@{@"endpoint": parentEndpoint}];
        }
    }
}


- (void)onLeave:(RespokeConnection*)connection sender:(RespokeGroup*)sender
{
    NSInteger groupIndex = [self.groups indexOfObject:sender];

    if (NSNotFound != groupIndex)
    {
        NSString *groupName = [sender getGroupID];

        // Get the list of known connections for this group
        NSMutableArray *groupMembers = [self.groupConnectionArrays objectForKey:groupName];
        NSInteger index = [groupMembers indexOfObject:connection];

        // Get the list of known endpoints for this group
        NSMutableArray *groupEndpoints = [self.groupEndpointArrays objectForKey:groupName];

        // Avoid leave messages for connection we didn't know about
        if (NSNotFound != index)
        {
            [groupMembers removeObjectAtIndex:index];
            RespokeEndpoint *parentEndpoint = [connection getEndpoint];

            if (parentEndpoint)
            {
                // Make sure that this is the last connection for this endpoint before removing it from the list
                NSInteger connectionCount = 0;
                NSInteger groupConnectionCount = 0;

                for (NSMutableArray *eachConnectionList in [self.groupConnectionArrays allValues])
                {
                    for (RespokeConnection *eachConnection in eachConnectionList)
                    {
                        if (eachConnection.getEndpoint == parentEndpoint)
                        {
                            connectionCount++;

                            if (eachConnectionList == groupMembers)
                            {
                                groupConnectionCount++;
                            }
                        }
                    }
                }

                if (connectionCount == 0)
                {
                    NSLog(@"Left: %@", parentEndpoint.endpointID);
                    NSInteger index = [self.allKnownEndpoints indexOfObject:parentEndpoint];

                    if (NSNotFound != index)
                    {
                        [self.allKnownEndpoints removeObjectAtIndex:index];
                        [self.conversations removeObjectForKey:parentEndpoint.endpointID];

                        // Notify any UI listeners that an endpoint has left
                        [[NSNotificationCenter defaultCenter] postNotificationName:ENDPOINT_DISAPPEARED object:parentEndpoint userInfo:@{@"index": [NSNumber numberWithInteger:index]}];
                    }
                }

                if (groupConnectionCount == 0)
                {
                    NSInteger index = [groupEndpoints indexOfObject:parentEndpoint];

                    if (NSNotFound != index)
                    {
                        [groupEndpoints removeObjectAtIndex:index];

                        // Notify any UI listeners that an endpoint has left this group
                        [[NSNotificationCenter defaultCenter] postNotificationName:ENDPOINT_LEFT_GROUP object:sender userInfo:@{@"endpoint": parentEndpoint, @"index": [NSNumber numberWithInteger:index]}];
                    }
                }
            }
        }
    }
}


#pragma mark - RespokeEndpointDelegate


- (void)onMessage:(NSString*)message sender:(RespokeEndpoint*)sender
{
    Conversation *conversation = [self.conversations objectForKey:sender.endpointID];
    [conversation addMessage:message from:sender.endpointID];
    conversation.unreadCount++;

    // Notify any UI listeners that a message has been received from a remote endpoint
    [[NSNotificationCenter defaultCenter] postNotificationName:ENDPOINT_MESSAGE_RECEIVED object:sender userInfo:nil];
}


@end

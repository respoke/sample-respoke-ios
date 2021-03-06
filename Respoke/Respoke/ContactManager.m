//
//  ContactManager.m
//  Respoke
//
//  Copyright 2015, Digium, Inc.
//  All rights reserved.
//
//  This source code is licensed under The MIT License found in the
//  LICENSE file in the root directory of this source tree.
//
//  For all details and documentation:  https://www.respoke.io
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
        self.groupConversations = [[NSMutableDictionary alloc] init];
    }

    return self;
}


- (void)joinGroups:(NSArray*)groupNames successHandler:(void (^)(void))successHandler errorHandler:(void (^)(NSString*))errorHandler
{
    [sharedRespokeClient joinGroups:groupNames successHandler:^(NSArray *groups) {

        for (RespokeGroup *group in groups)
        {
            // Become the delegate for this group
            group.delegate = self;
            [self.groups addObject:group];

            [group getMembersWithSuccessHandler:^(NSArray *memberList) {
                // Establish the connection and endpoint tracking arrays for this group
                [self.groupConnectionArrays setObject:[memberList mutableCopy] forKey:[group getGroupID]];

                NSMutableArray *groupEndpoints = [NSMutableArray array];
                [self.groupEndpointArrays setObject:groupEndpoints forKey:[group getGroupID]];

                // Start tracking the conversation with this group
                Conversation *conversation = [[Conversation alloc] initWithName:[group getGroupID]];
                [self.groupConversations setObject:conversation forKey:[group getGroupID]];

                // Evaluate each connection in the new group
                for (RespokeConnection *each in memberList)
                {
                    // Find the endpoint to which the connection belongs
                    RespokeEndpoint *parentEndpoint = [each getEndpoint];

                    [self trackEndpoint:parentEndpoint];

                    // If this endpoint is not known in this specific group, remember it
                    if (NSNotFound == [groupEndpoints indexOfObject:parentEndpoint])
                    {
                        [groupEndpoints addObject:parentEndpoint];
                    }
                }

                // Notify any UI listeners that group membership has changed
                [[NSNotificationCenter defaultCenter] postNotificationName:GROUP_MEMBERSHIP_CHANGED object:group userInfo:nil];

                for (RespokeEndpoint *eachEndpoint in groupEndpoints)
                {
                    [eachEndpoint registerPresenceWithSuccessHandler:nil errorHandler:nil];
                }

                successHandler();
            } errorHandler:^(NSString *errorMessage) {
                errorHandler(errorMessage);
            }];
        }
    } errorHandler:^(NSString *errorMessage) {
        errorHandler(errorMessage);
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
        [self.groupConversations removeObjectForKey:groupName];

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


- (void)disconnected
{
    self.groups = [[NSMutableArray alloc] init];
    self.groupConnectionArrays = [[NSMutableDictionary alloc] init];
    self.groupEndpointArrays = [[NSMutableDictionary alloc] init];
    self.allKnownEndpoints = [[NSMutableArray alloc] init];
    self.conversations = [[NSMutableDictionary alloc] init];
    self.groupConversations = [[NSMutableDictionary alloc] init];   
}


- (void)trackEndpoint:(RespokeEndpoint*)newEndpoint
{
    // If this endpoint is not known in any group, remember it
    if (NSNotFound == [self.allKnownEndpoints indexOfObject:newEndpoint])
    {
        [self.allKnownEndpoints addObject:newEndpoint];
        newEndpoint.delegate = self;

        // Start tracking the conversation with this endpoint
        Conversation *conversation = [[Conversation alloc] initWithName:newEndpoint.endpointID];
        [self.conversations setObject:conversation forKey:newEndpoint.endpointID];
    }
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
            
            [self trackEndpoint:parentEndpoint];

            // Notify any UI listeners that a new endpoint has been discovered
            [[NSNotificationCenter defaultCenter] postNotificationName:ENDPOINT_DISCOVERED object:parentEndpoint userInfo:nil];

            [parentEndpoint registerPresenceWithSuccessHandler:nil errorHandler:nil];
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


- (void)onGroupMessage:(NSString*)message fromEndpoint:(RespokeEndpoint*)endpoint sender:(RespokeGroup*)sender timestamp:(NSDate*)timestamp
{
    Conversation *conversation = [self.groupConversations objectForKey:[sender getGroupID]];
    [conversation addMessage:message from:endpoint.endpointID directMessage:NO];
    conversation.unreadCount++;

    // TODO: process timestamp

    // Notify any UI listeners that a message has been received from a remote endpoint
    [[NSNotificationCenter defaultCenter] postNotificationName:GROUP_MESSAGE_RECEIVED object:sender userInfo:nil];
}


#pragma mark - RespokeEndpointDelegate


- (void)onMessage:(NSString*)message endpoint:(RespokeEndpoint*)endpoint timestamp:(NSDate*)timestamp didSend:(BOOL)didSend
{
    if (didSend) // the endpoint sent the message (not a ccSelf message)
    {
        Conversation *conversation = [self.conversations objectForKey:endpoint.endpointID];
        [conversation addMessage:message from:endpoint.endpointID directMessage:NO];
        conversation.unreadCount++;

        // TODO: process timestamp

        // Notify any UI listeners that a message has been received from a remote endpoint
        [[NSNotificationCenter defaultCenter] postNotificationName:ENDPOINT_MESSAGE_RECEIVED object:endpoint userInfo:nil];
    }
}


- (void)onPresence:(NSObject*)presence sender:(RespokeEndpoint*)sender
{
    // Notify any UI listeners that presence for this endpoint has been updated
    [[NSNotificationCenter defaultCenter] postNotificationName:ENDPOINT_PRESENCE_CHANGED object:sender userInfo:nil];
}


@end

//
//  Conversation.m
//  Respoke
//
//  Created by Jason Adams on 7/15/14.
//  Copyright (c) 2014 Digium, Inc. All rights reserved.
//

#import "Conversation.h"

@implementation Conversation


- (instancetype)initWithName:(NSString*)name
{
    if (self = [super init])
    {
        self.messages = [[NSMutableArray alloc] init];
        self.name = name;
    }

    return self;
}


- (void)addMessage:(NSString*)message from:(NSString*)sender
{
    ConversationMessage *newMessage = [[ConversationMessage alloc] init];
    newMessage.message = message;
    newMessage.senderEndpoint = sender;
    [self.messages addObject:newMessage];
}


@end

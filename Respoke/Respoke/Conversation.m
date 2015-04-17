//
//  Conversation.m
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


- (void)addMessage:(NSString*)message from:(NSString*)sender directMessage:(BOOL)directMessage
{
    ConversationMessage *newMessage = [[ConversationMessage alloc] init];
    newMessage.message = message;
    newMessage.senderEndpoint = sender;
    newMessage.direct = directMessage;
    [self.messages addObject:newMessage];
}


@end

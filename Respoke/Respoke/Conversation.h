//
//  Conversation.h
//  Respoke
//
//  Created by Jason Adams on 7/15/14.
//  Copyright (c) 2014 Digium, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ConversationMessage.h"


@interface Conversation : NSObject

@property NSMutableArray *messages;
@property NSString *name;
@property NSInteger unreadCount;

- (instancetype)initWithName:(NSString*)name;
- (void)addMessage:(NSString*)message from:(NSString*)sender directMessage:(BOOL)directMessage;

@end

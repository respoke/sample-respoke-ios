//
//  Conversation.h
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

#import <Foundation/Foundation.h>
#import "ConversationMessage.h"


@interface Conversation : NSObject

@property NSMutableArray *messages;
@property NSString *name;
@property NSInteger unreadCount;

- (instancetype)initWithName:(NSString*)name;
- (void)addMessage:(NSString*)message from:(NSString*)sender directMessage:(BOOL)directMessage;

@end

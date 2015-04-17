//
//  ConversationMessage.h
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

@interface ConversationMessage : NSObject

@property NSString *message;
@property NSString *senderEndpoint;
@property BOOL direct;

@end

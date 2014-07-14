//
//  RespokeClient.h
//  Respoke
//
//  Created by Jason Adams on 7/11/14.
//  Copyright (c) 2014 Ninjanetic Design Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RespokeGroup.h"


@protocol RespokeClientDelegate;


@interface RespokeClient : NSObject

@property (weak) id <RespokeClientDelegate> delegate;

- (instancetype)initWithAppID:(NSString*)appID developmentMode:(BOOL)developmentMode;
- (void)connectWithEndpointID:(NSString*)endpoint errorHandler:(void (^)(NSString*))errorHandler;
- (void)joinGroup:(NSString*)groupName errorHandler:(void (^)(NSString*))errorHandler joinHandler:(void (^)(RespokeGroup*))joinHandler;

@end


@protocol RespokeClientDelegate <NSObject>

- (void)onConnect:(RespokeClient*)sender;
- (void)onDisconnect:(RespokeClient*)sender;
- (void)onError:(NSError *)error fromClient:(RespokeClient*)sender;

@end
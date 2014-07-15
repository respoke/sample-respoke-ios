//
//  RespokeEndpoint.h
//  Respoke
//
//  Created by Jason Adams on 7/14/14.
//  Copyright (c) 2014 Ninjanetic Design Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RespokeSignalingChannel.h"


@protocol RespokeEndpointDelegate;


@interface RespokeEndpoint : NSObject

@property NSString *endpointID;
@property NSMutableArray *connections;
@property (weak) id <RespokeEndpointDelegate> delegate;

- (instancetype)initWithSignalingChannel:(RespokeSignalingChannel*)channel;
- (void)sendMessage:(NSString*)message successHandler:(void (^)(void))successHandler errorHandler:(void (^)(NSString*))errorHandler;

@end


@protocol RespokeEndpointDelegate <NSObject>

- (void)onMessage:(NSString*)message sender:(RespokeEndpoint*)sender;

@end

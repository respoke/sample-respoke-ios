//
//  RespokeClient.h
//  Respoke
//
//  Created by Jason Adams on 7/11/14.
//  Copyright (c) 2014 Ninjanetic Design Inc. All rights reserved.
//

#import <Foundation/Foundation.h>


@protocol RespokeClientConnectionDelegate;


@interface RespokeClient : NSObject

@property (weak) id <RespokeClientConnectionDelegate> connectionDelegate;

- (instancetype)initWithAppID:(NSString*)appID developmentMode:(BOOL)developmentMode;
- (void)connectWithEndpointID:(NSString*)endpoint errorHandler:(void (^)(NSString*))errorHandler;

@end


@protocol RespokeClientConnectionDelegate <NSObject>

- (void)onConnect:(RespokeClient*)sender;

@end
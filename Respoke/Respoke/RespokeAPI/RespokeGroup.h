//
//  RespokeGroup.h
//  Respoke
//
//  Created by Jason Adams on 7/13/14.
//  Copyright (c) 2014 Ninjanetic Design Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RespokeSignalingChannel.h"
#import "RespokeEndpoint.h"


@protocol RespokeGroupDelegate;


@interface RespokeGroup : NSObject

@property (weak) id <RespokeGroupDelegate> delegate;

- (instancetype)initWithGroupID:(NSString*)groupID appToken:(NSString*)token signalingChannel:(RespokeSignalingChannel*)channel endpointID:(NSString*)endpoint;
- (void)getMembersWithSuccessHandler:(void (^)(NSArray*))successHandler errorHandler:(void (^)(NSString*))errorHandler;
- (RespokeEndpoint*)endpointWithName:(NSString*)name;

@end


@protocol RespokeGroupDelegate <NSObject>

- (void)onJoin:(NSString*)endpoint sender:(RespokeGroup*)sender;
- (void)onLeave:(NSString*)endpoint sender:(RespokeGroup*)sender;

@end

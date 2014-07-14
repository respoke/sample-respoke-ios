//
//  RespokeGroup.h
//  Respoke
//
//  Created by Jason Adams on 7/13/14.
//  Copyright (c) 2014 Ninjanetic Design Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RespokeSignalingChannel.h"


@interface RespokeGroup : NSObject

- (instancetype)initWithGroupID:(NSString*)groupID appToken:(NSString*)token signalingChannel:(RespokeSignalingChannel*)channel;
- (void)getMembersWithSuccessHandler:(void (^)(NSArray*))successHandler errorHandler:(void (^)(NSString*))errorHandler;

@end

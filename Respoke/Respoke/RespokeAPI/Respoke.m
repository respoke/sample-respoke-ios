//
//  Respoke.m
//  Respoke
//
//  Created by Jason Adams on 7/7/14.
//  Copyright (c) 2014 Ninjanetic Design Inc. All rights reserved.
//

#import "Respoke.h"
#import "RespokeWebRTCManager.h"


@interface Respoke() {
    RespokeWebRTCManager *respokeWebRTCManager;
    NSMutableDictionary *instances;
}


@end


@implementation Respoke 


// The Respoke SDK class is a singleton that should be accessed through this share instance method
+ (Respoke *)sharedInstance
{
    static Respoke *sharedInstance = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        sharedInstance = [[Respoke alloc] init];
    });
    
    return sharedInstance;
}


- (instancetype)init 
{
    if (self = [super init])
    {
        respokeWebRTCManager = [[RespokeWebRTCManager alloc] init];
        instances = [[NSMutableDictionary alloc] init];
    }

    return self;
}


- (RespokeClient*)createClientWithAppID:(NSString*)appID developmentMode:(BOOL)developmentMode
{
    RespokeClient *newClient = [[RespokeClient alloc] initWithAppID:appID developmentMode:developmentMode];
    return newClient;
}


- (void)startCallWithEndpoint:(NSString*)endpoint remoteVideoView:(UIView*)newRemoteView localVideoView:(UIView*)newLocalView
{
    NSString* url = [NSString stringWithFormat:@"https://apprtc.appspot.com/?r=%@", endpoint];

    [respokeWebRTCManager startCallWithURL:url remoteVideoView:newRemoteView localVideoView:newLocalView];
}


@end

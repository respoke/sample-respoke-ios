//
//  RespokeWebRTCManager.m
//  Respoke
//
//  Created by Jason Adams on 7/7/14.
//  Copyright (c) 2014 Ninjanetic Design Inc. All rights reserved.
//

#import "RespokeWebRTCManager.h"
#import "APPRTCConnectionManager.h"
#import "RTCEAGLVideoView.h"
#import "RTCPeerConnectionFactory.h"
#import <AVFoundation/AVFoundation.h>


@interface RespokeWebRTCManager() <APPRTCConnectionManagerDelegate, APPRTCLogger, RTCEAGLVideoViewDelegate>

@end


@implementation RespokeWebRTCManager {
    APPRTCConnectionManager* _connectionManager;
    RTCEAGLVideoView* localVideoView;
    RTCEAGLVideoView* remoteVideoView;
    UIView __weak* localView;
    UIView __weak* remoteView;
    CGSize _localVideoSize;
    CGSize _remoteVideoSize;
}


- (instancetype)init 
{
    if (self = [super init])
    {
        [RTCPeerConnectionFactory initializeSSL];
        _connectionManager = [[APPRTCConnectionManager alloc] initWithDelegate:self logger:self];
    }

    return self;
}


- (void)startCallWithURL:(NSString*)url remoteVideoView:(UIView*)newRemoteView localVideoView:(UIView*)newLocalView
{
    remoteView = newRemoteView;
    localView = newLocalView;

    remoteVideoView = [[RTCEAGLVideoView alloc] initWithFrame:remoteView.bounds];
    remoteVideoView.delegate = self;
    remoteVideoView.transform = CGAffineTransformMakeScale(-1, 1);
    [remoteView addSubview:remoteVideoView];

    localVideoView = [[RTCEAGLVideoView alloc] initWithFrame:localView.bounds];
    localVideoView.delegate = self;
    [localView addSubview:localVideoView];

    [self updateVideoViewLayout];

    [_connectionManager connectToRoomWithURL:[NSURL URLWithString:url]];
}


- (void)updateVideoViewLayout
{
    CGSize defaultAspectRatio = CGSizeMake(4, 3);
    CGSize localAspectRatio = CGSizeEqualToSize(_localVideoSize, CGSizeZero) ? defaultAspectRatio : _localVideoSize;
    CGSize remoteAspectRatio = CGSizeEqualToSize(_remoteVideoSize, CGSizeZero) ? defaultAspectRatio : _remoteVideoSize;

    CGRect remoteVideoFrame = AVMakeRectWithAspectRatioInsideRect(remoteAspectRatio, remoteView.bounds);
    remoteVideoView.frame = remoteVideoFrame;

    CGRect localVideoFrame = AVMakeRectWithAspectRatioInsideRect(localAspectRatio, localView.bounds);
    localVideoView.frame = localVideoFrame;
}


- (void)disconnect 
{
    [_connectionManager disconnect];
    remoteVideoView = nil;
    localVideoView = nil;
    remoteView = nil;
    localView = nil;
}


- (void)showAlertWithMessage:(NSString*)message 
{
    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:nil
                                                        message:message
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
    [alertView show];
}


#pragma mark - APPRTCConnectionManagerDelegate


- (void)connectionManager:(APPRTCConnectionManager*)manager didReceiveLocalVideoTrack:(RTCVideoTrack*)localVideoTrack 
{
    localVideoView.videoTrack = localVideoTrack;
}


- (void)connectionManager:(APPRTCConnectionManager*)manager didReceiveRemoteVideoTrack:(RTCVideoTrack*)remoteVideoTrack 
{
    remoteVideoView.videoTrack = remoteVideoTrack;
}


- (void)connectionManagerDidReceiveHangup:(APPRTCConnectionManager*)manager 
{
    [self showAlertWithMessage:@"Remote hung up."];
    [self disconnect];
}


- (void)connectionManager:(APPRTCConnectionManager*)manager didErrorWithMessage:(NSString*)message 
{
    [self showAlertWithMessage:message];
    [self disconnect];
}


#pragma mark - RTCEAGLVideoViewDelegate


- (void)videoView:(RTCEAGLVideoView*)videoView didChangeVideoSize:(CGSize)size 
{
    if (videoView == localVideoView) 
    {
        _localVideoSize = size;
    } 
    else if (videoView == remoteVideoView) 
    {
        _remoteVideoSize = size;
    } 
    else 
    {
        NSParameterAssert(NO);
    }

    [self updateVideoViewLayout];
}


#pragma mark - APPRTCLogger


- (void)logMessage:(NSString*)message 
{
//    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"%@", message);
//    });
}


@end

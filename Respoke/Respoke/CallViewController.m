//
//  CallViewController.m
//  Respoke
//
//  Created by Jason Adams on 7/9/14.
//  Copyright (c) 2014 Digium, Inc. All rights reserved.
//

#import "CallViewController.h"


@interface CallViewController () <RespokeCallDelegate> {
    BOOL audioMuted;
    BOOL videoMuted;
}

@end


@implementation CallViewController


- (void)viewDidLoad
{
    [super viewDidLoad];

    self.endCallButton.layer.cornerRadius = 32.0;
    self.muteAudioButton.layer.cornerRadius = 32.0;
    self.muteAudioButton.layer.borderWidth = 0;
    self.muteAudioButton.layer.borderColor = [UIColor redColor].CGColor;
    self.muteVideoButton.layer.cornerRadius = 32.0;
    self.muteVideoButton.layer.borderWidth = 0;
    self.muteVideoButton.layer.borderColor = [UIColor redColor].CGColor;

    if (self.call)
    {
        RespokeEndpoint *remoteEndpoint = [self.call getRemoteEndpoint];
        if (remoteEndpoint)
        {
            self.callerNameLabel.text = [remoteEndpoint endpointID];
        }
        else
        {
            
            self.callerNameLabel.text = @"Unknown Caller";
        }
        
        self.answerView.hidden = NO;
        self.call.delegate = self;
        self.call.remoteView = self.remoteView;
        self.call.localView = self.localView;
    }
    else
    {
        self.answerView.hidden = YES;

        if (self.audioOnly)
        {
            self.muteVideoButton.hidden = YES;
            self.call = [self.endpoint startAudioCallWithDelegate:self];
        }
        else
        {
            self.call = [self.endpoint startVideoCallWithDelegate:self remoteVideoView:self.remoteView localVideoView:self.localView];
        }
    }
}


- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}


- (IBAction)answerCall
{
    [self.call answer];
    self.answerView.hidden = YES;
}


- (IBAction)ignoreCall
{
    [self.call hangup:YES];
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}


- (IBAction)endCall
{
    self.remoteView.hidden = YES;
    self.localView.hidden = YES;
    [self.call hangup:YES];
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}


- (IBAction)muteVideo
{
    videoMuted = !videoMuted;
    [self.call muteVideo:videoMuted];
    
    self.localView.hidden = videoMuted;
    
    if (videoMuted)
    {
        self.muteVideoButton.layer.borderWidth = 4.0;
        [self.muteVideoButton setImage:[UIImage imageNamed:@"unmute_video.png"] forState:UIControlStateNormal];
    }
    else
    {
        self.muteVideoButton.layer.borderWidth = 0;
        [self.muteVideoButton setImage:[UIImage imageNamed:@"mute_video.png"] forState:UIControlStateNormal];
    }
}


- (IBAction)muteAudio
{
    audioMuted = !audioMuted;
    [self.call muteAudio:audioMuted];
    
    if (audioMuted)
    {
        self.muteAudioButton.layer.borderWidth = 4.0;
        [self.muteAudioButton setImage:[UIImage imageNamed:@"unmute_audio.png"] forState:UIControlStateNormal];
    }
    else
    {
        self.muteAudioButton.layer.borderWidth = 0;
        [self.muteAudioButton setImage:[UIImage imageNamed:@"mute_audio.png"] forState:UIControlStateNormal];
    }
}


#pragma mark - RespokeCallDelegate


- (void)onError:(NSString*)errorMessage sender:(RespokeCall*)sender
{
    NSLog(@"Call Error: %@", errorMessage);
    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:nil
                                                        message:errorMessage
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
    [alertView show];
}


- (void)onHangup:(RespokeCall*)sender
{
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}


- (void)onConnected:(RespokeCall*)sender
{
    self.connectingView.hidden = YES;
}


@end

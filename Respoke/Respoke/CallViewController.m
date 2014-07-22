//
//  CallViewController.m
//  Respoke
//
//  Created by Jason Adams on 7/9/14.
//  Copyright (c) 2014 Ninjanetic Design Inc. All rights reserved.
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
        self.call.delegate = self;
        self.call.remoteView = self.remoteView;
        self.call.localView = self.localView;
        [self.call answerCall];
    }
    else
    {
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


- (IBAction)endCall
{
    self.remoteView.hidden = YES;
    self.localView.hidden = YES;
    [self.call hangup];
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}


- (IBAction)muteVideo
{
    videoMuted = !videoMuted;
    
    if (videoMuted)
    {
        self.muteVideoButton.layer.borderWidth = 1.0;
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
    
    if (audioMuted)
    {
        self.muteAudioButton.layer.borderWidth = 1.0;
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

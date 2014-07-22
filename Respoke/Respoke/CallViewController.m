//
//  CallViewController.m
//  Respoke
//
//  Created by Jason Adams on 7/9/14.
//  Copyright (c) 2014 Ninjanetic Design Inc. All rights reserved.
//

#import "CallViewController.h"


@interface CallViewController () <RespokeCallDelegate> {
}

@end


@implementation CallViewController


- (void)viewDidLoad
{
    [super viewDidLoad];

    self.endCallButton.layer.cornerRadius = 16.0;
    self.muteAudioButton.layer.cornerRadius = 16.0;
    self.muteVideoButton.layer.cornerRadius = 16.0;

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

}


- (IBAction)muteAudio
{

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


@end

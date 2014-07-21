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

    if (self.call)
    {
        self.call.delegate = self;
        self.call.remoteView = self.remoteView;
        self.call.localView = self.localView;
        [self.call answerCall];
    }
    else
    {
        self.call = [self.endpoint startVideoCallWithDelegate:self remoteVideoView:self.remoteView localVideoView:self.localView];
    }
}


- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

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

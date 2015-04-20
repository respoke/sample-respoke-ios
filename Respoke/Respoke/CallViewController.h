//
//  CallViewController.h
//  Respoke
//
//  Copyright 2015, Digium, Inc.
//  All rights reserved.
//
//  This source code is licensed under The MIT License found in the
//  LICENSE file in the root directory of this source tree.
//
//  For all details and documentation:  https://www.respoke.io
//

#import <UIKit/UIKit.h>
#import "RespokeEndpoint.h"
#import "RespokeCall.h"


@interface CallViewController : UIViewController

@property (weak) IBOutlet UIView *remoteView;
@property (weak) IBOutlet UIView *localView;
@property (weak) IBOutlet UIButton *endCallButton;
@property (weak) IBOutlet UIButton *muteAudioButton;
@property (weak) IBOutlet UIButton *muteVideoButton;
@property (weak) IBOutlet UIButton *switchCameraButton;
@property (weak) IBOutlet UIView *connectingView;
@property (weak) IBOutlet UIView *answerView;
@property (weak) IBOutlet UILabel *callerNameLabel;
@property RespokeEndpoint *endpoint;
@property RespokeCall *call;
@property BOOL audioOnly;

- (IBAction)answerCall;
- (IBAction)ignoreCall;
- (IBAction)endCall;
- (IBAction)muteVideo;
- (IBAction)muteAudio;
- (IBAction)toggleCamera;

@end

//
//  CallViewController.h
//  Respoke
//
//  Created by Jason Adams on 7/9/14.
//  Copyright (c) 2014 Digium, Inc. All rights reserved.
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

@end

//
//  ViewController.h
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
#import "AppDelegate.h"
#import "RespokeClient.h"


@interface LoginViewController : UIViewController <UITextFieldDelegate, RespokeClientDelegate>

@property (weak) IBOutlet UITextField *usernameTextField;
@property (weak) IBOutlet UITextField *groupTextField;
@property (weak) IBOutlet UITextField *appIDTextField;
@property (weak) IBOutlet UILabel *errorLabel;
@property (weak) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak) IBOutlet UIButton *connectButton;
@property (weak) IBOutlet UIButton *configButton;
@property (weak) IBOutlet UISwitch *brokeredSwitch;

- (IBAction)configAction;
- (IBAction)brokeredSwitchAction;

@end

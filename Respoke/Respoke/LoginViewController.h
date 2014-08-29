//
//  ViewController.h
//  Respoke
//
//  Created by Jason Adams on 7/3/14.
//  Copyright (c) 2014 Digium, Inc. All rights reserved.
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

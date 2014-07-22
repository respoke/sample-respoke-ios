//
//  ViewController.h
//  Respoke
//
//  Created by Jason Adams on 7/3/14.
//  Copyright (c) 2014 Ninjanetic Design Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

@interface LoginViewController : UIViewController <UITextFieldDelegate, RespokeClientDelegate>

@property (weak) IBOutlet UITextField *usernameTextField;
@property (weak) IBOutlet UITextField *groupTextField;
@property (weak) IBOutlet UILabel *errorLabel;
@property (weak) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak) IBOutlet UIButton *connectButton;

- (IBAction)unwindFromGroupView:(UIStoryboardSegue*)sender;

@end

//
//  JoinGroupViewController.h
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

@interface JoinGroupViewController : UIViewController

@property (weak) IBOutlet UITextField *groupTextField;
@property (weak) IBOutlet UILabel *errorLabel;
@property (weak) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak) IBOutlet UIButton *joinButton;

- (IBAction)joinAction;
- (IBAction)cancelAction;

@end

//
//  JoinGroupViewController.h
//  Respoke
//
//  Created by Jason Adams on 8/18/14.
//  Copyright (c) 2014 Digium, Inc. All rights reserved.
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

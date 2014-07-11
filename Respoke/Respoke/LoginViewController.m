//
//  LoginViewController.m
//  Respoke
//
//  Created by Jason Adams on 7/3/14.
//  Copyright (c) 2014 Ninjanetic Design Inc. All rights reserved.
//

#import "LoginViewController.h"
#import "GroupTableViewController.h"


@implementation LoginViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    sharedRespokeClient.connectionDelegate = self;
}


- (IBAction)connectAction
{
    if ([self.usernameTextField.text length])
    {
        self.activityIndicator.hidden = NO;
        [self.connectButton setTitle:@"" forState:UIControlStateNormal];

        [sharedRespokeClient connectWithEndpointID:self.usernameTextField.text errorHandler:^(NSString *errorMessage) {
            self.errorLabel.text = errorMessage;
            self.errorLabel.hidden = NO;
            self.activityIndicator.hidden = YES;
            [self.connectButton setTitle:@"Connect" forState:UIControlStateNormal];
        }];
    }
    else
    {
        [self.usernameTextField becomeFirstResponder];
        self.errorLabel.text = @"Username may not be blank";
        self.errorLabel.hidden = NO;
    }
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    GroupTableViewController *controller = [segue destinationViewController];
    controller.username = self.usernameTextField.text;
}


#pragma mark - UITextFieldDelegate


- (BOOL)textFieldShouldReturn:(UITextField*)textField 
{
    [textField resignFirstResponder];
    [self connectAction];
    
    return YES;
}


- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    self.errorLabel.hidden = YES;
    
    return YES;
}


#pragma mark - RespokeClientConnectionDelegate


- (void)onConnect:(RespokeClient*)sender
{
    self.activityIndicator.hidden = YES;
    [self.connectButton setTitle:@"Connect" forState:UIControlStateNormal];
    
    [self performSegueWithIdentifier:@"ShowGroup" sender:self];
}


@end

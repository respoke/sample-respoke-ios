//
//  LoginViewController.m
//  Respoke
//
//  Created by Jason Adams on 7/3/14.
//  Copyright (c) 2014 Ninjanetic Design Inc. All rights reserved.
//

#import "LoginViewController.h"
#import "Respoke.h"
#import "CallViewController.h"


@implementation LoginViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}


- (IBAction)connectAction
{
    if ([self.usernameTextField.text length])
    {
        //[[Respoke sharedInstance] connectWithUsername:self.usernameTextField.text];
        [self performSegueWithIdentifier:@"StartCall" sender:self];
    }
    else
    {
        [self.usernameTextField becomeFirstResponder];
    }
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    CallViewController *controller = [segue destinationViewController];
    controller.endpoint = self.usernameTextField.text;
}


#pragma mark - UITextFieldDelegate


- (BOOL)textFieldShouldReturn:(UITextField*)textField 
{
    [textField resignFirstResponder];
    [self connectAction];
    
    return YES;
}


@end

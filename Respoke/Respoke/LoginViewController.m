//
//  LoginViewController.m
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

#import "LoginViewController.h"
#import "GroupListTableViewController.h"
#import "AppDelegate.h"


#define LAST_APP_ID_KEY @"LAST_APP_ID_KEY"
#define LAST_USER_KEY @"LAST_USER_KEY"
#define LAST_GROUP_KEY @"LAST_GROUP_KEY"

/**
 * Substitute your own Respoke application ID here. This is the ID you got from the Respoke
 * Developer Console when you signed up and defined an application:
 *
 * https://portal.respoke.io/#/signup
 */
#define RESPOKE_APP_ID @"REPLACE_ME"


@implementation LoginViewController {
    id __weak lastResponder;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.connectButton.layer.cornerRadius = 8.0;

    [self.configButton setAttributedTitle:[[NSAttributedString alloc] initWithString:@"Change App ID" attributes:@{NSUnderlineStyleAttributeName: @(NSUnderlineStyleSingle), NSForegroundColorAttributeName: [UIColor whiteColor], NSFontAttributeName: [UIFont systemFontOfSize:13]}] forState:UIControlStateNormal];

    NSString *lastAppID = [[NSUserDefaults standardUserDefaults] objectForKey:LAST_APP_ID_KEY];

    if (lastAppID)
    {
        self.appIDTextField.text = lastAppID;
    }

    NSString *lastUser = [[NSUserDefaults standardUserDefaults] objectForKey:LAST_USER_KEY];

    if (lastUser)
    {
        self.usernameTextField.text = lastUser;
    }

    NSString *lastGroup = [[NSUserDefaults standardUserDefaults] objectForKey:LAST_GROUP_KEY];

    if (lastGroup)
    {
        self.groupTextField.text = lastGroup;
    }
}


- (void)viewDidAppear:(BOOL)animated
{
    [self.usernameTextField becomeFirstResponder];
    sharedRespokeClient = nil;
}


- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent; 
}


- (IBAction)connectAction
{
    if ([self.usernameTextField.text length])
    {
        [lastResponder resignFirstResponder];
        
        self.activityIndicator.hidden = NO;
        self.errorLabel.hidden = YES;
        [self.connectButton setTitle:@"" forState:UIControlStateNormal];

        // Hook for UI testing. Don't create the client if the test framework has already done so.
        if (!sharedRespokeClient)
        {
            // Create a Respoke client instance to be used for the duration of the application
            sharedRespokeClient = [[Respoke sharedInstance] createClient];
        }

        sharedRespokeClient.delegate = self;

        if (self.brokeredSwitch.on)
        {
            [sharedRespokeClient connectWithTokenID:self.usernameTextField.text initialPresence:nil errorHandler:^(NSString *errorMessage) {
                [self showError:errorMessage];
            }];
        }
        else
        {
            NSString *appID = RESPOKE_APP_ID;

            if ([self.appIDTextField.text length])
            {
                appID = self.appIDTextField.text;
            }
            
            [sharedRespokeClient connectWithEndpointID:self.usernameTextField.text appID:appID reconnect:YES initialPresence:nil errorHandler:^(NSString *errorMessage) {
                [self showError:errorMessage];
            }];
        }
    }
    else
    {
        [self.usernameTextField becomeFirstResponder];
        self.errorLabel.text = @"Username may not be blank";
        self.errorLabel.hidden = NO;
    }
}


- (IBAction)brokeredSwitchAction
{
    if (self.brokeredSwitch.on)
    {
        self.usernameTextField.placeholder = @"Token ID";
        self.appIDTextField.hidden = YES;
        self.configButton.hidden = YES;
    }
    else
    {
        self.usernameTextField.placeholder = @"Endpoint ID";
        
        BOOL showAppID = ([self.appIDTextField.text length] > 0);
        self.appIDTextField.hidden = !showAppID;
        self.configButton.hidden = showAppID;
    }
}


- (IBAction)configAction
{
    self.configButton.hidden = YES;
    self.appIDTextField.hidden = NO;
}


- (void)showError:(NSString*)errorMessage
{
    self.errorLabel.text = errorMessage;
    self.errorLabel.hidden = NO;
    self.activityIndicator.hidden = YES;
    [self.connectButton setTitle:@"Connect" forState:UIControlStateNormal];
}


#pragma mark - UITextFieldDelegate


- (BOOL)textFieldShouldReturn:(UITextField*)textField 
{
    if (textField == self.usernameTextField)
    {
        [self.groupTextField becomeFirstResponder];
    }
    else if (textField == self.groupTextField)
    {
        [textField resignFirstResponder];
        [self connectAction];
    }
    else
    {
        [textField resignFirstResponder];
    }
    
    return YES;
}


- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    self.errorLabel.hidden = YES;
    
    return YES;
}


- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    lastResponder = textField;
}


- (void)textFieldDidEndEditing:(UITextField *)textField
{
    lastResponder = nil;
    
    if (textField == self.usernameTextField)
    {
        [[NSUserDefaults standardUserDefaults] setObject:self.usernameTextField.text forKey:LAST_USER_KEY];
    }
    else if (textField == self.groupTextField)
    {
        [[NSUserDefaults standardUserDefaults] setObject:self.groupTextField.text forKey:LAST_GROUP_KEY];
    }
    else
    {
        [[NSUserDefaults standardUserDefaults] setObject:self.appIDTextField.text forKey:LAST_APP_ID_KEY];
    }
    
    [[NSUserDefaults standardUserDefaults] synchronize];
}


#pragma mark - RespokeClientDelegate


- (void)onConnect:(RespokeClient*)sender
{
    NSString *groupName = @"RespokeTeam";

    if ([self.groupTextField.text length])
    {
        groupName = self.groupTextField.text;
    }
    
    sharedContactManager.username = [sender getEndpointID];
    
    [sharedContactManager joinGroups:@[groupName] successHandler:^(){
        self.activityIndicator.hidden = YES;
        [self.connectButton setTitle:@"Connect" forState:UIControlStateNormal];
        
        [self performSegueWithIdentifier:@"ShowGroup" sender:self];
    } errorHandler:^(NSString *errorMessage) {
        [self showError:errorMessage];
    }];
}


- (void)onDisconnect:(RespokeClient*)sender reconnecting:(BOOL)reconnecting
{
    // Do nothing
}

- (void)onCall:(RespokeCall *)call sender:(RespokeClient *)sender
{
    // Do nothing
}


- (void)onError:(NSError *)error fromClient:(RespokeClient*)sender
{
    [self showError:[error localizedDescription]];
}


- (void)onIncomingDirectConnection:(RespokeDirectConnection*)directConnection endpoint:(RespokeEndpoint*)endpoint
{
    // Do nothing
}


@end

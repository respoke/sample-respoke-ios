//
//  LoginViewController.m
//  Respoke
//
//  Created by Jason Adams on 7/3/14.
//  Copyright (c) 2014 Digium, Inc. All rights reserved.
//

#import "LoginViewController.h"
#import "GroupTableViewController.h"
#import "RespokeGroup.h"


#define LAST_APP_ID_KEY @"LAST_APP_ID_KEY"
#define LAST_USER_KEY @"LAST_USER_KEY"
#define LAST_GROUP_KEY @"LAST_GROUP_KEY"


@implementation LoginViewController {
    RespokeGroup *myGroup;
    NSArray *groupMembers;
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
        
        NSString *appID = @"2b446810-6d92-4fa4-826a-2eabced82d60";
        
        if ([self.appIDTextField.text length])
        {
            appID = self.appIDTextField.text;
        }
        
        // Create a Respoke client instance to be used for the duration of the application
        sharedRespokeClient = [[Respoke sharedInstance] createClientWithAppID:appID developmentMode:YES];
        sharedRespokeClient.delegate = self;

        [sharedRespokeClient connectWithEndpointID:self.usernameTextField.text errorHandler:^(NSString *errorMessage) {
            [self showError:errorMessage];
        }];
    }
    else
    {
        [self.usernameTextField becomeFirstResponder];
        self.errorLabel.text = @"Username may not be blank";
        self.errorLabel.hidden = NO;
    }
}


- (IBAction)configAction
{
    self.configButton.hidden = YES;
    self.appIDTextField.hidden = NO;
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    GroupTableViewController *controller = (GroupTableViewController*) [(UINavigationController*) [segue destinationViewController] topViewController];;
    controller.username = self.usernameTextField.text;
    controller.group = myGroup;
    controller.groupMembers = [groupMembers mutableCopy];
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
    NSString *groupName = @"endpointlist";

    if ([self.groupTextField.text length])
    {
        groupName = self.groupTextField.text;
    }

    [sharedRespokeClient joinGroup:groupName errorHandler:^(NSString *errorMessage) {
        [self showError:errorMessage];
    } joinHandler:^(RespokeGroup *group) {
        myGroup = group;
        [myGroup getMembersWithSuccessHandler:^(NSArray *memberList) {
            groupMembers = memberList;

            self.activityIndicator.hidden = YES;
            [self.connectButton setTitle:@"Connect" forState:UIControlStateNormal];
            
            [self performSegueWithIdentifier:@"ShowGroup" sender:self];
        } errorHandler:^(NSString *errorMessage) {
            [self showError:errorMessage];
        }];
    }];
}


- (void)onDisconnect:(RespokeClient*)sender
{
    // Do nothing
}

- (void)onIncomingCall:(RespokeCall *)call sender:(RespokeClient *)sender
{
    // Do nothing
}


- (void)onError:(NSError *)error fromClient:(RespokeClient*)sender
{
    [self showError:[error localizedDescription]];
}


@end

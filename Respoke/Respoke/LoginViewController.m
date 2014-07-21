//
//  LoginViewController.m
//  Respoke
//
//  Created by Jason Adams on 7/3/14.
//  Copyright (c) 2014 Ninjanetic Design Inc. All rights reserved.
//

#import "LoginViewController.h"
#import "GroupTableViewController.h"


@implementation LoginViewController {
    RespokeGroup *myGroup;
    NSArray *groupMembers;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    sharedRespokeClient.delegate = self;
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
        self.activityIndicator.hidden = NO;
        self.errorLabel.hidden = YES;
        [self.connectButton setTitle:@"" forState:UIControlStateNormal];

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


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    GroupTableViewController *controller = (GroupTableViewController*) [(UINavigationController*) [segue destinationViewController] topViewController];;
    controller.username = self.usernameTextField.text;
    controller.group = myGroup;
    controller.groupMembers = [groupMembers mutableCopy];
}


- (IBAction)unwindFromGroupView:(UIStoryboardSegue*)sender
{
    
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
    [textField resignFirstResponder];
    [self connectAction];
    
    return YES;
}


- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    self.errorLabel.hidden = YES;
    
    return YES;
}


#pragma mark - RespokeClientDelegate


- (void)onConnect:(RespokeClient*)sender
{
    [sharedRespokeClient joinGroup:@"jasontest" errorHandler:^(NSString *errorMessage) {
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

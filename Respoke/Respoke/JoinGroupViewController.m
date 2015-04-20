//
//  JoinGroupViewController.m
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

#import "JoinGroupViewController.h"
#import "AppDelegate.h"


@interface JoinGroupViewController () {
    BOOL joinInProgress;
}

@end


@implementation JoinGroupViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.joinButton.layer.cornerRadius = 8.0;
}


- (void)viewDidAppear:(BOOL)animated
{
    [self.groupTextField becomeFirstResponder];
}


- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent; 
}


- (IBAction)joinAction
{
    if (!joinInProgress)
    {
        if ([self.groupTextField.text length])
        {
            [self.groupTextField resignFirstResponder];
            
            self.activityIndicator.hidden = NO;
            self.errorLabel.hidden = YES;
            [self.joinButton setTitle:@"" forState:UIControlStateNormal];

            joinInProgress = YES;

            [sharedContactManager joinGroups:@[self.groupTextField.text] successHandler:^(){
                self.activityIndicator.hidden = YES;
                [self.joinButton setTitle:@"Join" forState:UIControlStateNormal];
                
                [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
            } errorHandler:^(NSString *errorMessage) {
                [self showError:errorMessage];
                joinInProgress = NO;
            }];
        }
        else
        {
            [self.groupTextField becomeFirstResponder];
            self.errorLabel.text = @"Group name may not be blank";
            self.errorLabel.hidden = NO;
        }
    }
}


- (IBAction)cancelAction
{
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];   
}


- (void)showError:(NSString*)errorMessage
{
    self.errorLabel.text = errorMessage;
    self.errorLabel.hidden = NO;
    self.activityIndicator.hidden = YES;
    [self.joinButton setTitle:@"Connect" forState:UIControlStateNormal];
}


#pragma mark - UITextFieldDelegate


- (BOOL)textFieldShouldReturn:(UITextField*)textField 
{
    [textField resignFirstResponder];
    [self joinAction];
    
    return YES;
}


- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    self.errorLabel.hidden = YES;
    
    return YES;
}


@end

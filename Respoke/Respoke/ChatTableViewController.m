//
//  ChatTableViewController.m
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

#import "ChatTableViewController.h"
#import "CallViewController.h"
#import "AppDelegate.h"
#import "Conversation.h"
#import "RespokeDirectConnection.h"


@interface ChatTableViewController () <UIActionSheetDelegate, RespokeCallDelegate, RespokeDirectConnectionDelegate> {
    UITableViewCell *remotePrototype;
    UITableViewCell *localPrototype;
    BOOL audioOnly;
    BOOL dismissed;
    Conversation *conversation;
}

@end


@implementation ChatTableViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = self.endpoint.endpointID;

    conversation = [sharedContactManager.conversations objectForKey:self.endpoint.endpointID];

    remotePrototype = [self.tableView dequeueReusableCellWithIdentifier:@"RemoteMessage"];
    localPrototype = [self.tableView dequeueReusableCellWithIdentifier:@"LocalMessage"];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(endpointMessageReceived:) name:ENDPOINT_MESSAGE_RECEIVED object:self.endpoint];
    
    self.textItem.width = 244 + self.view.frame.size.width - 320;

    self.textField.accessibilityLabel = @"Message";
    self.textItem.accessibilityLabel = @"Send";
    self.tableView.accessibilityLabel = @"Chat";

    if (self.directConnection)
    {
        self.directConnection.delegate = self;

        RespokeCall *call = [self.directConnection getCall];
        BOOL caller = NO;

        if (call)
        {
            call.delegate = self;
            caller = [call isCaller];
        }

        self.answerView.hidden = caller;
        self.connectingView.hidden = !caller;
        self.callerNameLabel.text = [self.endpoint endpointID];
        
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Close" style:UIBarButtonItemStylePlain target:self action:@selector(closeDirectConnectionView)];
        [self.navigationController setNavigationBarHidden:!caller animated:NO];
        self.navigationController.navigationBar.barTintColor = [UIColor darkGrayColor];
        self.navigationController.navigationBar.tintColor = [UIColor blackColor];

        // TOOD: remove this when we support direct connection calls
        self.navigationItem.rightBarButtonItem = nil;

        self.tableView.accessibilityLabel = @"Direct Chat";
        self.connectingView.accessibilityLabel = @"Connecting";
    }
}


- (void)viewWillAppear:(BOOL)animated
{
    // need to load direct connection messages into table when direct connection closes
    [self.tableView reloadData];
}


- (void)viewDidAppear:(BOOL)animated
{
    conversation.unreadCount = 0;
}


#pragma mark - Navigation


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"Call"])
    {
        CallViewController *controller = [segue destinationViewController];
        controller.endpoint = self.endpoint;
        controller.audioOnly = audioOnly;
    }
}


- (void)closeDirectConnectionView
{
    RespokeCall *call = [self.directConnection getCall];
    [call hangup:YES];

    if (!dismissed)
    {
        [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
        dismissed = YES;
    }
}


#pragma mark - Table view data source


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [conversation.messages count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ConversationMessage *message = [conversation.messages objectAtIndex:indexPath.row];
    UITableViewCell *cell = nil;

    if ([message.senderEndpoint isEqualToString:sharedContactManager.username])
    {
        cell = [tableView dequeueReusableCellWithIdentifier:@"LocalMessage" forIndexPath:indexPath];
    }
    else
    {
        cell = [tableView dequeueReusableCellWithIdentifier:@"RemoteMessage" forIndexPath:indexPath];
    }
    
    [self configureCell:cell forMessage:message];

    return cell;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ConversationMessage *message = [conversation.messages objectAtIndex:indexPath.row];
    UITableViewCell *prototypeCell = nil;

    if ([message.senderEndpoint isEqualToString:sharedContactManager.username])
    {
        prototypeCell = localPrototype;
    }
    else
    {
        prototypeCell = remotePrototype;
    }

    // Force the prototype cell to lay itself out, and then grab the final height so that it can be used for the actual cell.
    prototypeCell.frame = CGRectMake(0, 0, tableView.frame.size.width, prototypeCell.frame.size.height);
    [self configureCell:prototypeCell forMessage:message];

    [prototypeCell setNeedsLayout];
    [prototypeCell layoutIfNeeded];
    CGFloat height = [prototypeCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
    return MAX(44.0, height);
}


- (void)configureCell:(UITableViewCell*)cell forMessage:(ConversationMessage*)message
{
    UILabel *label = (UILabel*)[cell viewWithTag:1];
    UIView *bubble = [cell viewWithTag:2];
    UIImageView *imageView = (UIImageView*)[cell viewWithTag:3];

    label.text = message.message;

    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad)
    {
        label.preferredMaxLayoutWidth = 600;
    }
    else
    {
        label.preferredMaxLayoutWidth = 200;   
    }

    bubble.layer.cornerRadius = 8.0;

    imageView.hidden = !message.direct;
}


#pragma mark - UITextFieldDelegate


- (BOOL)textFieldShouldReturn:(UITextField*)textField 
{
    [self sendAction];
    
    return YES;
}


- (IBAction)sendAction
{
    if ([self.textField.text length])
    {
        [conversation addMessage:self.textField.text from:sharedContactManager.username directMessage:(nil != self.directConnection)];
        [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:[conversation.messages count] - 1 inSection:0]] withRowAnimation:UITableViewRowAnimationBottom];
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[conversation.messages count] - 1 inSection:0] atScrollPosition:UITableViewScrollPositionMiddle animated:YES];

        if (self.directConnection)
        {
            [self.directConnection sendMessage:self.textField.text successHandler:^(void){
                NSLog(@"Direct message sent");
            } errorHandler:^(NSString *error){
                NSLog(@"Error sending: %@", error);
            }];
        }
        else
        {
            [self.endpoint sendMessage:self.textField.text successHandler:^(void){
                NSLog(@"Message sent");
            } errorHandler:^(NSString *error){
                NSLog(@"Error sending: %@", error);
            }];
        }

        self.textField.text = @"";
    }
}


- (IBAction)callAction
{
    UIActionSheet *methodAlert = [[UIActionSheet alloc] initWithTitle:@""
                                    delegate:self cancelButtonTitle:@"Cancel"
                                    destructiveButtonTitle:nil
                                    otherButtonTitles:  @"Video Call",
                                                        @"Audio Only",
                                                        self.directConnection ? nil : @"Direct Connection",
                                                        nil];

    [methodAlert showInView:self.view];
}


- (void)actionSheet:(UIActionSheet *)modalView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex)
    {
        case 0:
        {
            audioOnly = NO;
            [self performSegueWithIdentifier:@"Call" sender:self];
        }
        break;

        case 1:
        {
            audioOnly = YES;
            [self performSegueWithIdentifier:@"Call" sender:self];

            break;
        }

        case 2:
        {
            ChatTableViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"ChatTableViewController"];
            controller.directConnection = [self.endpoint startDirectConnection];
            controller.endpoint = self.endpoint;
            UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:controller];
            
            UIViewController *presenter = [self.navigationController topViewController];
            [presenter presentViewController:navController animated:YES completion:nil];

            break;
        }
    }
}


- (void)keyboardWillShow:(NSNotification *)notification
{
    NSTimeInterval animationDuration = [[[notification userInfo] valueForKey: UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    CGRect keyboardBounds = [(NSValue *)[[notification userInfo] objectForKey: UIKeyboardFrameBeginUserInfoKey] CGRectValue];
    
    [UIView animateWithDuration:animationDuration animations:^(void){
        self.bottomConstraint.constant = keyboardBounds.size.height;
        [self.view layoutIfNeeded];
    } completion:nil];
}


- (void)keyboardWillHide:(NSNotification *)notification
{
    NSTimeInterval animationDuration = [[[notification userInfo] valueForKey: UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
    [UIView animateWithDuration:animationDuration animations:^(void){
        self.bottomConstraint.constant = 0;
        [self.view layoutIfNeeded];
    } completion:nil];
}


- (void)endpointMessageReceived:(NSNotification *)notification
{
    conversation.unreadCount = 0;

    [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:[conversation.messages count] - 1 inSection:0]] withRowAnimation:UITableViewRowAnimationBottom];
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[conversation.messages count] - 1 inSection:0] atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
}


- (IBAction)acceptConnection
{
    [self.directConnection accept];
    self.connectingView.hidden = NO;
    self.answerView.hidden = YES;
    [self.navigationController setNavigationBarHidden:NO animated:NO];
}


- (IBAction)ignoreConnection
{
    RespokeCall *call = [self.directConnection getCall];
    [call hangup:YES];
    
    if (!dismissed)
    {
        [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
        dismissed = YES;
    }
}


#pragma mark - RespokeCallDelegate methods for direct connections


- (void)onError:(NSString*)errorMessage sender:(RespokeCall*)sender
{
    NSLog(@"Call Error: %@", errorMessage);
    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:nil
                                                        message:errorMessage
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
    [alertView show];
}


- (void)onHangup:(RespokeCall*)sender
{
    if (!dismissed)
    {
        [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
        dismissed = YES;
    }
}


- (void)onConnected:(RespokeCall*)sender
{

}


- (void)directConnectionAvailable:(RespokeDirectConnection*)directConnection endpoint:(RespokeEndpoint*)endpoint
{
    
}


#pragma mark - RespokeDirectConnectionDelegate


- (void)onStart:(RespokeDirectConnection*)sender
{

}


- (void)onOpen:(RespokeDirectConnection*)sender
{
    self.connectingView.hidden = YES;
}


- (void)onClose:(RespokeDirectConnection*)sender
{
}


 - (void)onMessage:(id)message sender:(RespokeDirectConnection*)sender
 {
    if ([message isKindOfClass:[NSString class]])
    {
        NSString *messageString = (NSString*)message;
        
        [conversation addMessage:messageString from:self.endpoint.endpointID directMessage:YES];
        [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:[conversation.messages count] - 1 inSection:0]] withRowAnimation:UITableViewRowAnimationBottom];
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[conversation.messages count] - 1 inSection:0] atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
    }
 }


@end

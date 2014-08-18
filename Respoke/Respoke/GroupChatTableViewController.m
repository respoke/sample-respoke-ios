//
//  GroupChatTableViewController.m
//  Respoke
//
//  Created by Jason Adams on 8/18/14.
//  Copyright (c) 2014 Digium, Inc. All rights reserved.
//

#import "GroupChatTableViewController.h"
#import "AppDelegate.h"
#import "Conversation.h"


@interface GroupChatTableViewController () <UIActionSheetDelegate> {
    UITableViewCell *remotePrototype;
    UITableViewCell *localPrototype;
    Conversation *conversation;
}

@end


@implementation GroupChatTableViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = [self.group getGroupID];

    conversation = [sharedContactManager.groupConversations objectForKey:self.title];

    remotePrototype = [self.tableView dequeueReusableCellWithIdentifier:@"RemoteMessage"];
    localPrototype = [self.tableView dequeueReusableCellWithIdentifier:@"LocalMessage"];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(groupMessageReceived:) name:GROUP_MESSAGE_RECEIVED object:self.group];
}


- (void)viewDidAppear:(BOOL)animated
{
    conversation.unreadCount = 0;
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
    UILabel *senderLabel = (UILabel*)[cell viewWithTag:3];

    label.text = message.message;

    if (senderLabel)
    {
        senderLabel.text = message.senderEndpoint;
    }

    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad)
    {
        label.preferredMaxLayoutWidth = 600;
    }
    else
    {
        label.preferredMaxLayoutWidth = 200;   
    }

    bubble.layer.cornerRadius = 8.0;
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
        [conversation addMessage:self.textField.text from:sharedContactManager.username];
        [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:[conversation.messages count] - 1 inSection:0]] withRowAnimation:UITableViewRowAnimationBottom];
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[conversation.messages count] - 1 inSection:0] atScrollPosition:UITableViewScrollPositionMiddle animated:YES];

        [self.group sendMessage:self.textField.text successHandler:^(void){
            NSLog(@"Message sent");
        } errorHandler:^(NSString *error){
            NSLog(@"Error sending: %@", error);
        }];

        self.textField.text = @"";
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


- (void)groupMessageReceived:(NSNotification *)notification
{
    conversation.unreadCount = 0;

    [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:[conversation.messages count] - 1 inSection:0]] withRowAnimation:UITableViewRowAnimationBottom];
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[conversation.messages count] - 1 inSection:0] atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
}


@end

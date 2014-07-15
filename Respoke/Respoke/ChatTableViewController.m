//
//  ChatTableViewController.m
//  Respoke
//
//  Created by Jason Adams on 7/14/14.
//  Copyright (c) 2014 Ninjanetic Design Inc. All rights reserved.
//

#import "ChatTableViewController.h"
#import "Conversation.h"


@interface ChatTableViewController () {
    Conversation *conversation;
    UITableViewCell *remotePrototype;
    UITableViewCell *localPrototype;
}

@end


@implementation ChatTableViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = self.endpoint.endpointID;
    conversation = [[Conversation alloc] initWithName:self.endpoint.endpointID];
    /*[conversation addMessage:@"Hi there!" from:self.username];
    [conversation addMessage:@"Top of the morning to you, fine sir. Top of the morning to you, fine sir. Top of the morning to you, fine sir." from:self.endpoint.endpointID];
    [conversation addMessage:@"Thanks bro" from:self.username];*/
    self.endpoint.delegate = self;

    remotePrototype = [self.tableView dequeueReusableCellWithIdentifier:@"RemoteMessage"];
    localPrototype = [self.tableView dequeueReusableCellWithIdentifier:@"LocalMessage"];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
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

    if ([message.senderEndpoint isEqualToString:self.username])
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

    if ([message.senderEndpoint isEqualToString:self.username])
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
    return MAX(44.0, height);// + CELL_SEPARATOR_ADJUSTMENT);
}


- (void)configureCell:(UITableViewCell*)cell forMessage:(ConversationMessage*)message
{
    UILabel *label = (UILabel*)[cell viewWithTag:1];
    UIView *bubble = [cell viewWithTag:2];

    label.text = message.message;
    label.preferredMaxLayoutWidth = 200;
    bubble.layer.cornerRadius = 8.0;
}


#pragma mark - UITextFieldDelegate


- (BOOL)textFieldShouldReturn:(UITextField*)textField 
{
    [self sendAction];
    
    return YES;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)sendAction
{
    if ([self.textField.text length])
    {
        [conversation addMessage:self.textField.text from:self.username];
        [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:[conversation.messages count] - 1 inSection:0]] withRowAnimation:UITableViewRowAnimationBottom];
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[conversation.messages count] - 1 inSection:0] atScrollPosition:UITableViewScrollPositionMiddle animated:YES];

        [self.endpoint sendMessage:self.textField.text successHandler:^(void){
            NSLog(@"Message sent");
        } errorHandler:^(NSString *error){
            NSLog(@"Error sending: %@", error);
        }];

        self.textField.text = @"";
    }
}


- (IBAction)callAction
{

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


- (void)onMessage:(NSString*)message sender:(RespokeEndpoint*)sender
{
    [conversation addMessage:message from:sender.endpointID];
    [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:[conversation.messages count] - 1 inSection:0]] withRowAnimation:UITableViewRowAnimationBottom];
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[conversation.messages count] - 1 inSection:0] atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
}


@end

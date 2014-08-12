//
//  GroupTableViewController.m
//  Respoke
//
//  Created by Jason Adams on 7/11/14.
//  Copyright (c) 2014 Digium, Inc. All rights reserved.
//

#import "GroupTableViewController.h"
#import "ChatTableViewController.h"
#import "CallViewController.h"


@interface GroupTableViewController () {
    NSMutableDictionary *conversations;
    RespokeEndpoint *endpointBeingViewed;
}

@end


@implementation GroupTableViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    conversations = [[NSMutableDictionary alloc] init];
    for (RespokeEndpoint *each in self.groupMembers)
    {
        each.delegate = self;
        Conversation *conversation = [[Conversation alloc] initWithName:each.endpointID];
        [conversations setObject:conversation forKey:each.endpointID];
    }

    sharedRespokeClient.delegate = self;
    self.group.delegate = self;

    self.title = self.username;

    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    self.navigationItem.backBarButtonItem = backButton;
}


- (void)viewWillAppear:(BOOL)animated
{
    if (endpointBeingViewed)
    {
        endpointBeingViewed.delegate = self;
        endpointBeingViewed = nil;

        [self.tableView reloadData];
    }
}


#pragma mark - Navigation


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"ShowContact"])
    {
        ChatTableViewController *controller = [segue destinationViewController];
        controller.endpoint = sender;
        controller.username = self.username;
        controller.conversation = [conversations objectForKey:((RespokeEndpoint*)sender).endpointID];

        endpointBeingViewed = sender;
    }
}


- (IBAction)logoutAction
{
    [sharedRespokeClient disconnect];
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
    return [self.groupMembers count];
}


#pragma mark - RespokeClientDelegate


- (void)onConnect:(RespokeClient*)sender
{

}


- (void)onDisconnect:(RespokeClient*)sender
{
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}


- (void)onError:(NSError *)error fromClient:(RespokeClient*)sender
{

}


- (void)onCall:(RespokeCall*)call sender:(RespokeClient*)sender
{
    CallViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"CallViewController"];
    controller.call = call;
    UIViewController *presenter = [self.navigationController topViewController];
    [presenter presentViewController:controller animated:YES completion:nil];
}


#pragma mark - RespokeGroupDelegate


- (void)onJoin:(RespokeEndpoint*)endpoint sender:(RespokeGroup*)sender
{
    NSLog(@"Joined: %@", endpoint.endpointID);
    [self.groupMembers addObject:endpoint];
    Conversation *conversation = [[Conversation alloc] initWithName:endpoint.endpointID];
    [conversations setObject:conversation forKey:endpoint.endpointID];
    [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:[self.groupMembers count] - 1 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
}


- (void)onLeave:(RespokeEndpoint*)endpoint sender:(RespokeGroup*)sender
{
    NSLog(@"Left: %@", endpoint.endpointID);
    NSInteger index = [self.groupMembers indexOfObject:endpoint];

    if (NSNotFound != index)
    {
        [self.groupMembers removeObjectAtIndex:index];
        [conversations removeObjectForKey:endpoint.endpointID];
        [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PersonCell" forIndexPath:indexPath];
    
    UILabel *label = (UILabel*)[cell viewWithTag:1];
    UILabel *countLabel = (UILabel*)[cell viewWithTag:2];

    RespokeEndpoint *endpoint = [self.groupMembers objectAtIndex:indexPath.row];
    Conversation *conversation = [conversations objectForKey:endpoint.endpointID];

    label.text = endpoint.endpointID;

    if (conversation.unreadCount > 0)
    {
        countLabel.text = [NSString stringWithFormat:@"  %d  ", conversation.unreadCount];
        countLabel.layer.cornerRadius = 8.0;
        countLabel.hidden = NO;
    }
    else
    {
        countLabel.hidden = YES;
    }
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
    RespokeEndpoint *selection = [self.groupMembers objectAtIndex:indexPath.row];

    if (selection)
    {
        [self performSegueWithIdentifier:@"ShowContact" sender:selection];
    }
}


- (void)onMessage:(NSString*)message sender:(RespokeEndpoint*)sender
{
    Conversation *conversation = [conversations objectForKey:((RespokeEndpoint*)sender).endpointID];
    [conversation addMessage:message from:sender.endpointID];
    conversation.unreadCount++;

    NSInteger index = [self.groupMembers indexOfObject:sender];
    [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
}


@end

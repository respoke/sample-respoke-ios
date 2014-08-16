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
#import "RespokeConnection.h"


@interface GroupTableViewController () {
    NSMutableDictionary *conversations;
    RespokeEndpoint *endpointBeingViewed;
    NSMutableArray *endpoints;
}

@end


@implementation GroupTableViewController


- (void)viewDidLoad
{
    [super viewDidLoad];

    endpoints = [[NSMutableArray alloc] init];
    conversations = [[NSMutableDictionary alloc] init];

    for (RespokeConnection *each in self.groupMembers)
    {
        RespokeEndpoint *parentEndpoint = [each getEndpoint];

        // Some endpoints may have more than one connection that is a member of this group, so only remember each endpoint once
        if (NSNotFound == [endpoints indexOfObject:parentEndpoint])
        {
            [endpoints addObject:parentEndpoint];
            parentEndpoint.delegate = self;

            Conversation *conversation = [[Conversation alloc] initWithName:parentEndpoint.endpointID];
            [conversations setObject:conversation forKey:parentEndpoint.endpointID];
        }
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
    return [endpoints count];
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


- (void)onJoin:(RespokeConnection*)connection sender:(RespokeGroup*)sender
{
    [self.groupMembers addObject:connection];

    RespokeEndpoint *parentEndpoint = [connection getEndpoint];

    // Some endpoints may have more than one connection that is a member of this group, so only remember each endpoint once
    if (NSNotFound == [endpoints indexOfObject:parentEndpoint])
    {
        NSLog(@"Joined: %@", parentEndpoint.endpointID);
        [endpoints addObject:parentEndpoint];
        parentEndpoint.delegate = self;

        Conversation *conversation = [[Conversation alloc] initWithName:parentEndpoint.endpointID];
        [conversations setObject:conversation forKey:parentEndpoint.endpointID];

        [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:[endpoints count] - 1 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}


- (void)onLeave:(RespokeConnection*)connection sender:(RespokeGroup*)sender
{
    NSInteger index = [self.groupMembers indexOfObject:connection];

    // Avoid leave messages for connection we didn't know about
    if (NSNotFound != index)
    {
        [self.groupMembers removeObjectAtIndex:index];
        RespokeEndpoint *parentEndpoint = [connection getEndpoint];

        if (parentEndpoint)
        {
            // Make sure that this is the last connection for this endpoint before removing it from the list
            NSInteger connectionCount = 0;

            for (RespokeConnection *eachConnection in self.groupMembers)
            {
                if (eachConnection.getEndpoint == parentEndpoint)
                {
                    connectionCount++;
                }
            }

            if (connectionCount == 0)
            {
                NSLog(@"Left: %@", parentEndpoint.endpointID);
                NSInteger index = [endpoints indexOfObject:parentEndpoint];

                if (NSNotFound != index)
                {
                    [endpoints removeObjectAtIndex:index];
                    [conversations removeObjectForKey:parentEndpoint.endpointID];
                    [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
                }
            }
        }
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PersonCell" forIndexPath:indexPath];
    
    UILabel *label = (UILabel*)[cell viewWithTag:1];
    UILabel *countLabel = (UILabel*)[cell viewWithTag:2];

    RespokeEndpoint *endpoint = [endpoints objectAtIndex:indexPath.row];
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
    RespokeEndpoint *selection = [endpoints objectAtIndex:indexPath.row];

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

    NSInteger index = [endpoints indexOfObject:sender];
    [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
}


@end

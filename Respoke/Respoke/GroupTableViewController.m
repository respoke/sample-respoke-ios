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
#import "RespokeEndpoint.h"
#import "Conversation.h"
#import "GroupChatTableViewController.h"


@interface GroupTableViewController () {
    NSMutableArray *endpoints;
    BOOL leavingGroup;
}

@end


@implementation GroupTableViewController


- (void)viewDidLoad
{
    [super viewDidLoad];

    self.title = [self.group getGroupID];
    endpoints = [sharedContactManager.groupEndpointArrays objectForKey:self.title];

    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    self.navigationItem.backBarButtonItem = backButton;

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(endpointMessageReceived:) name:ENDPOINT_MESSAGE_RECEIVED object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(endpointPresenceChanged:) name:ENDPOINT_PRESENCE_CHANGED object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(endpointJoinedGroup:) name:ENDPOINT_JOINED_GROUP object:self.group];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(endpointLeftGroup:) name:ENDPOINT_LEFT_GROUP object:self.group];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(groupMessageReceived:) name:GROUP_MESSAGE_RECEIVED object:self.group];
}


- (void)viewWillAppear:(BOOL)animated
{
    [self.tableView reloadData];
}


#pragma mark - Navigation


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"ShowContact"])
    {
        ChatTableViewController *controller = [segue destinationViewController];
        controller.endpoint = sender;
    }
    else
    {
        GroupChatTableViewController *controller = [segue destinationViewController];
        controller.group = self.group;
    }
}


- (IBAction)leaveAction
{
    leavingGroup = YES;
    
    [sharedContactManager leaveGroup:self.group successHandler:^(){
        // Once the group has been left, close this view
        [self.navigationController popViewControllerAnimated:YES];
    } errorHandler:^(NSString *errorMessage){
        leavingGroup = NO;
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error Leaving Group" message:errorMessage delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }];
}


#pragma mark - Table view data source


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 2;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if (section == 0)
    {
        return 1;
    }
    else
    {
        return [endpoints count];
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    
    if (indexPath.section == 0)
    {
        cell = [tableView dequeueReusableCellWithIdentifier:@"GroupCell" forIndexPath:indexPath];
        
        UILabel *label = (UILabel*)[cell viewWithTag:1];
        UILabel *countLabel = (UILabel*)[cell viewWithTag:2];
        
        NSString *groupName = [self.group getGroupID];
        Conversation *conversation = [sharedContactManager.groupConversations objectForKey:groupName];

        label.text = [NSString stringWithFormat:@"%@ group messages", groupName];

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
    }
    else
    {
        cell = [tableView dequeueReusableCellWithIdentifier:@"PersonCell" forIndexPath:indexPath];
        
        UILabel *label = (UILabel*)[cell viewWithTag:1];
        UILabel *countLabel = (UILabel*)[cell viewWithTag:2];
        UILabel *presenceLabel = (UILabel*)[cell viewWithTag:3];

        RespokeEndpoint *endpoint = [endpoints objectAtIndex:indexPath.row];
        Conversation *conversation = [sharedContactManager.conversations objectForKey:endpoint.endpointID];

        label.text = endpoint.endpointID;
        
        NSObject *presence = [endpoint getPresence];
        
        if (presence && [presence isKindOfClass:[NSString class]])
        {
            presenceLabel.text = (NSString*) presence;
        }
        else
        {
            presenceLabel.text = @"";
        }

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
    }
    
    return cell;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
        return 44;
    }
    else
    {
        RespokeEndpoint *endpoint = [endpoints objectAtIndex:indexPath.row];
        NSObject *presence = [endpoint getPresence];
        
        if (presence && [presence isKindOfClass:[NSString class]])
        {
            if ([((NSString*) presence) length] > 0)
            {
                return 59;
            }
        }

        return 44;
    }
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
    if (!leavingGroup)
    {
        if (indexPath.section == 0)
        {
            [self performSegueWithIdentifier:@"ShowGroupMessages" sender:nil];
        }
        else
        {
            RespokeEndpoint *selection = [endpoints objectAtIndex:indexPath.row];

            if (selection)
            {
                [self performSegueWithIdentifier:@"ShowContact" sender:selection];
            }
        }
    }
}


#pragma mark - ContactManager notifications


- (void)endpointMessageReceived:(NSNotification *)notification
{
    RespokeEndpoint* endpoint = [notification object];

    NSInteger index = [endpoints indexOfObject:endpoint];
    [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:1]] withRowAnimation:UITableViewRowAnimationAutomatic];
}


- (void)endpointPresenceChanged:(NSNotification *)notification
{
    RespokeEndpoint* endpoint = [notification object];

    NSInteger index = [endpoints indexOfObject:endpoint];
    [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:1]] withRowAnimation:UITableViewRowAnimationAutomatic];
}


- (void)endpointJoinedGroup:(NSNotification *)notification
{
    [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:[endpoints count] - 1 inSection:1]] withRowAnimation:UITableViewRowAnimationAutomatic];
}


- (void)endpointLeftGroup:(NSNotification *)notification
{
    NSDictionary *userInfo = [notification userInfo];
    NSNumber *index = [userInfo objectForKey:@"index"];

    if (index && ([index integerValue] <= [endpoints count]))
    {
        [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:[index integerValue] inSection:1]] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}


- (void)groupMessageReceived:(NSNotification *)notification
{
    [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
}


@end

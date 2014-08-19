//
//  GroupListTableViewController.m
//  Respoke
//
//  Created by Jason Adams on 8/17/14.
//  Copyright (c) 2014 Digium, Inc. All rights reserved.
//

#import "GroupListTableViewController.h"
#import "RespokeConnection.h"
#import "AppDelegate.h"
#import "Conversation.h"
#import "ChatTableViewController.h"
#import "GroupTableViewController.h"
#import "CallViewController.h"


@implementation GroupListTableViewController


- (void)viewDidLoad
{
    [super viewDidLoad];

    sharedRespokeClient.delegate = self;

    self.title = sharedContactManager.username;

    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    self.navigationItem.backBarButtonItem = backButton;

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(endpointMessageReceived:) name:ENDPOINT_MESSAGE_RECEIVED object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(endpointPresenceChanged:) name:ENDPOINT_PRESENCE_CHANGED object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(groupMembershipChanged:) name:GROUP_MEMBERSHIP_CHANGED object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(endpointDiscovered:) name:ENDPOINT_DISCOVERED object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(endpointDisappeared:) name:ENDPOINT_DISAPPEARED object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(groupMessageReceived:) name:GROUP_MESSAGE_RECEIVED object:nil];

    // set the initial status for this client
    [self setStatus:@"available"];
}


- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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
    else if ([segue.identifier isEqualToString:@"ShowGroup"])
    {
        GroupTableViewController *controller = [segue destinationViewController];
        controller.group = (RespokeGroup*)sender;
    }
}


- (IBAction)logoutAction
{
    [sharedRespokeClient disconnect];
}


- (IBAction)statusAction
{
    UIActionSheet *methodAlert = [[UIActionSheet alloc] initWithTitle:@"Choose a status"
                                    delegate:self cancelButtonTitle:@"Cancel"
                                    destructiveButtonTitle:nil
                                    otherButtonTitles:  @"chat",
                                                        @"available",
                                                        @"away",
                                                        @"dnd",
                                                        @"unavailable",
                                                        nil];

    methodAlert.actionSheetStyle = self.navigationController.navigationBar.barStyle;
    [methodAlert showInView:self.view];
}


- (void)actionSheet:(UIActionSheet *)modalView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *status = nil;

    switch (buttonIndex)
    {
        case 0:
        {
            status = @"chat";
        }
        break;

        case 1:
        {
            status = @"available";
        }
        break;

        case 2:
        {
            status = @"away";
        }
        break;

        case 3:
        {
            status = @"dnd";
        }
        break;

        case 4:
        {
            status = @"unavailable";
        }
        break;
    }

    if (status)
    {
        [self setStatus:status];
    }
}


- (void)setStatus:(NSString*)status
{
    self.statusButton.hidden = YES;
    self.activityIndicator.hidden = NO;

    [sharedRespokeClient setPresence:status successHandler:^() {
        self.statusButton.hidden = NO;
        self.activityIndicator.hidden = YES;
        [self.statusButton setTitle:[NSString stringWithFormat:@"Your Status: %@", [sharedRespokeClient getPresence]] forState:UIControlStateNormal];
    } errorHandler:^(NSString *errorMessage) {
        self.statusButton.hidden = NO;
        self.activityIndicator.hidden = YES;
        NSLog(@"Error: %@", errorMessage);
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
        return [sharedContactManager.groups count];
    }
    else
    {
        return [sharedContactManager.allKnownEndpoints count];
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

        RespokeGroup *group = [sharedContactManager.groups objectAtIndex:indexPath.row];
        NSString *groupName = [group getGroupID];
        label.text = groupName;
        Conversation *conversation = [sharedContactManager.groupConversations objectForKey:groupName];

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

        RespokeEndpoint *endpoint = [sharedContactManager.allKnownEndpoints objectAtIndex:indexPath.row];
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
        RespokeEndpoint *endpoint = [sharedContactManager.allKnownEndpoints objectAtIndex:indexPath.row];
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
    if (indexPath.section == 0)
    {
        RespokeGroup *selection = [sharedContactManager.groups objectAtIndex:indexPath.row];

        if (selection)
        {
            [self performSegueWithIdentifier:@"ShowGroup" sender:selection];
        }
    }
    else
    {
        RespokeEndpoint *selection = [sharedContactManager.allKnownEndpoints objectAtIndex:indexPath.row];

        if (selection)
        {
            [self performSegueWithIdentifier:@"ShowContact" sender:selection];
        }
    }
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0)
    {
        return @"Groups";
    }
    else
    {
        return @"All Known Endpoints";
    }
}


#pragma mark - RespokeClientDelegate


- (void)onConnect:(RespokeClient*)sender
{

}


- (void)onDisconnect:(RespokeClient*)sender
{
    [sharedContactManager disconnected];
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}


- (void)onError:(NSError *)error fromClient:(RespokeClient*)sender
{
    NSLog(@"RespokeSDK Error: %@", [error localizedDescription]);
}


- (void)onCall:(RespokeCall*)call sender:(RespokeClient*)sender
{
    CallViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"CallViewController"];
    controller.call = call;
    UIViewController *presenter = [self.navigationController topViewController];
    [presenter presentViewController:controller animated:YES completion:nil];
}


#pragma mark - ContactManager notifications


- (void)endpointMessageReceived:(NSNotification *)notification
{
    RespokeEndpoint* endpoint = [notification object];

    NSInteger index = [sharedContactManager.allKnownEndpoints indexOfObject:endpoint];
    [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:1]] withRowAnimation:UITableViewRowAnimationAutomatic];
}


- (void)endpointPresenceChanged:(NSNotification *)notification
{
    RespokeEndpoint* endpoint = [notification object];

    NSInteger index = [sharedContactManager.allKnownEndpoints indexOfObject:endpoint];
    [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:1]] withRowAnimation:UITableViewRowAnimationAutomatic];
}


- (void)groupMembershipChanged:(NSNotification*)notification
{
    [self.tableView reloadData];
}


- (void)endpointDiscovered:(NSNotification*)notification
{
    [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:[sharedContactManager.allKnownEndpoints count] - 1 inSection:1]] withRowAnimation:UITableViewRowAnimationAutomatic];   
}


- (void)endpointDisappeared:(NSNotification*)notification
{
    NSDictionary *userInfo = [notification userInfo];
    NSNumber *index = [userInfo objectForKey:@"index"];

    if (index && ([index integerValue] <= [sharedContactManager.allKnownEndpoints count]))
    {
        [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:[index integerValue] inSection:1]] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}


- (void)groupMessageReceived:(NSNotification *)notification
{
    RespokeGroup *group = [notification object];
    NSInteger index = [sharedContactManager.groups indexOfObject:group];

    if (index < [sharedContactManager.groups count])
    {
        [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}


@end

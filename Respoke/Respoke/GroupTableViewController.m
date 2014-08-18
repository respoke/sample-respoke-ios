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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(endpointJoinedGroup:) name:ENDPOINT_JOINED_GROUP object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(endpointLeftGroup:) name:ENDPOINT_LEFT_GROUP object:nil];
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
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [endpoints count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PersonCell" forIndexPath:indexPath];
    
    UILabel *label = (UILabel*)[cell viewWithTag:1];
    UILabel *countLabel = (UILabel*)[cell viewWithTag:2];

    RespokeEndpoint *endpoint = [endpoints objectAtIndex:indexPath.row];
    Conversation *conversation = [sharedContactManager.conversations objectForKey:endpoint.endpointID];

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
    if (!leavingGroup)
    {
        RespokeEndpoint *selection = [endpoints objectAtIndex:indexPath.row];

        if (selection)
        {
            [self performSegueWithIdentifier:@"ShowContact" sender:selection];
        }
    }
}


#pragma mark - ContactManager notifications


- (void)endpointMessageReceived:(NSNotification *)notification
{
    RespokeEndpoint* endpoint = [notification object];

    NSInteger index = [endpoints indexOfObject:endpoint];
    [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
}


- (void)endpointJoinedGroup:(NSNotification *)notification
{
    [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:[endpoints count] - 1 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
}


- (void)endpointLeftGroup:(NSNotification *)notification
{
    NSDictionary *userInfo = [notification userInfo];
    NSNumber *index = [userInfo objectForKey:@"index"];

    if (index && ([index integerValue] <= [endpoints count]))
    {
        [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:[index integerValue] inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}


@end

//
//  GroupTableViewController.m
//  Respoke
//
//  Created by Jason Adams on 7/11/14.
//  Copyright (c) 2014 Ninjanetic Design Inc. All rights reserved.
//

#import "GroupTableViewController.h"
#import "ChatTableViewController.h"


@interface GroupTableViewController ()

@end


@implementation GroupTableViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    sharedRespokeClient.delegate = self;
    self.group.delegate = self;

    self.title = self.username;

    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    self.navigationItem.backBarButtonItem = backButton;
}


#pragma mark - Navigation


// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    ChatTableViewController *controller = [segue destinationViewController];
    controller.endpoint = sender;
    controller.username = self.username;
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
    [self performSegueWithIdentifier:@"Disconnected" sender:self];
}


- (void)onError:(NSError *)error fromClient:(RespokeClient*)sender
{

}


#pragma mark - RespokeGroupDelegate


- (void)onJoin:(NSString*)endpoint sender:(RespokeGroup*)sender
{
    NSLog(@"Joined: %@", endpoint);
    [self.groupMembers addObject:endpoint];
    [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:[self.groupMembers count] - 1 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
}


- (void)onLeave:(NSString*)endpoint sender:(RespokeGroup*)sender
{
    NSLog(@"Left: %@", endpoint);
    NSInteger index = [self.groupMembers indexOfObject:endpoint];

    if (NSNotFound != index)
    {
        [self.groupMembers removeObjectAtIndex:index];
        [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PersonCell" forIndexPath:indexPath];
    
    UILabel *label = (UILabel*)[cell viewWithTag:1];
    label.text = [self.groupMembers objectAtIndex:indexPath.row];//[(NSDictionary*)[self.groupMembers objectAtIndex:indexPath.row] objectForKey:@"endpointId"];
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
    NSString *endpointToShow = [self.groupMembers objectAtIndex:indexPath.row];
    RespokeEndpoint *selection = [self.group endpointWithName:endpointToShow];

    if (selection)
    {
        [self performSegueWithIdentifier:@"ShowContact" sender:selection];
    }
}


@end

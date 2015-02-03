//
//  GroupTests.m
//  Respoke
//
//  Created by Rob Crabtree on 1/28/15.
//  Copyright (c) 2015 Digium, Inc. All rights reserved.
//

#import <KIF/KIF.h>
#import "KIFUITestActor+Respoke.h"


#define TEST_ENDPOINT           @"test endpoint"
#define TEST_GROUP_NAME_0       @"test group 0"
#define TEST_GROUP_NAME_1       @"test group 1"
#define TEST_GROUP_NAME_2       @"test group 2"


@interface GroupTests : KIFTestCase
@end


@implementation GroupTests


#pragma mark - Pre and Post Test Methods


- (void)beforeAll
{
    [super beforeAll];

    // login
    [tester initializeLoginScreen];
    [tester loginEndpoint:TEST_ENDPOINT groupName:TEST_GROUP_NAME_0 appID:nil];

    // make sure the GroupListTableViewController appears
    [tester waitForViewWithAccessibilityLabel:GROUP_LIST_TABLE_VIEW];

    // ensure the group has showed up in the group list
    [self verifyGroupAtRow:0];
}


- (void)afterAll
{
    [super afterAll];
    [tester logout];
    [tester resetLoginScreen];
}


#pragma mark - UI Tests


- (void)testJoiningAndLeavingGroups
{
    [self joinGroup:TEST_GROUP_NAME_1 andEnsureGroupAppearsAtRow:1];
    [self joinGroup:TEST_GROUP_NAME_2 andEnsureGroupAppearsAtRow:2];

    [self leaveGroupAtRow:2];
    [self leaveGroupAtRow:1];
}


#pragma mark - Helper Methods


- (void)verifyGroupAtRow:(NSUInteger)row
{
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];
    [tester waitForCellAtIndexPath:indexPath inTableViewWithAccessibilityIdentifier:GROUP_LIST_TABLE_VIEW];
}


- (void)joinGroup:(NSString *)groupName andEnsureGroupAppearsAtRow:(NSUInteger)row
{
    // click "Join" bar button item
    [tester tapViewWithAccessibilityLabel:GROUP_LIST_JOIN_BUTTON];

    // Wait for JoinGroupViewController to load
    [tester waitForViewWithAccessibilityLabel:JOIN_GROUP_VIEW];

    // Enter group name in text field
    [tester enterText:groupName intoViewWithAccessibilityLabel:JOIN_GROUP_NAME_TEXTFIELD];

    // Click the "Join" button
    [tester tapViewWithAccessibilityLabel:JOIN_GROUP_JOIN_BUTTON];

    // Wait for JoinGroupViewController to unload
    [tester waitForAbsenceOfViewWithAccessibilityLabel:JOIN_GROUP_VIEW];

    // Verify that we've added a new "Groups" cell
    [self verifyGroupAtRow:row];
}


- (void)leaveGroupAtRow:(NSUInteger)row
{
    // tap the specified row
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];
    [tester tapRowAtIndexPath:indexPath inTableViewWithAccessibilityIdentifier:GROUP_LIST_TABLE_VIEW];

    // wait for group table view to load
    [tester waitForViewWithAccessibilityLabel:GROUP_TABLE_VIEW];

    // leave the group
    [tester tapViewWithAccessibilityLabel:GROUP_LEAVE_BUTTON];

    // verify the view closes
    [tester waitForViewWithAccessibilityLabel:GROUP_LIST_TABLE_VIEW];
}

@end

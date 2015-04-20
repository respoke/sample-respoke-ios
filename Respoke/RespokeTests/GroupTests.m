//
//  GroupTests.m
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

#import <KIF/KIF.h>
#import "KIFUITestActor+Respoke.h"


#define TEST_GROUP_ID_1     @"test group 1"
#define TEST_GROUP_ID_2     @"test group 2"


@interface GroupTests : KIFTestCase
@end


@implementation GroupTests


#pragma mark - Pre and Post Test Methods


- (void)beforeAll
{
    [super beforeAll];
    [tester initializeLoginScreen];
    [tester loginEndpoint:[KIFUITestActor generateTestEndpointID] groupName:TEST_BOT_GROUP_ID appID:nil];
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
    [self joinGroup:TEST_GROUP_ID_1];
    [self joinGroup:TEST_GROUP_ID_2];

    [self leaveGroup:TEST_GROUP_ID_2];
    [self leaveGroup:TEST_GROUP_ID_1];
}


- (void)testMessaging
{
    // click on testbot's group cell in GroupListTableViewController
    [tester tapViewWithAccessibilityLabel:TEST_BOT_GROUP_ID];

    // wait for GroupListTableViewController to disappear
    [tester waitForAbsenceOfViewWithAccessibilityLabel:GROUP_LIST_TABLE_VIEW];

    // wait for GroupTableViewController to load
    [tester waitForViewWithAccessibilityLabel:GROUP_TABLE_VIEW];

    // click on testbot's group cell in GroupTableViewController
    NSString *cellAccessibilityLabel = [TEST_BOT_GROUP_ID stringByAppendingString:GROUP_CHAT_GROUP_CELL_SUFFIX];
    [tester tapViewWithAccessibilityLabel:cellAccessibilityLabel];

    // wait for GroupChatTableViewController to load
    [tester waitForViewWithAccessibilityLabel:GROUP_CHAT_TABLE_VIEW];

    // enter message in textbox
    [tester enterText:TEST_BOT_GROUP_HELLO_MESSAGE intoViewWithAccessibilityLabel:GROUP_CHAT_MESSAGE_TEXTFIELD];

    // click send
    [tester tapViewWithAccessibilityLabel:GROUP_CHAT_SEND_BUTTON];

    // verify reply received from testbot
    [tester waitForViewWithAccessibilityLabel:TEST_BOT_GROUP_HELLO_REPLY];

    // verify message was labeled with testbot's name
    [tester waitForViewWithAccessibilityLabel:TEST_BOT_ENDPOINT_ID];

    // hit back bar button item navigate back
    [tester tapViewWithAccessibilityLabel:GROUP_CHAT_BACK_BUTTON];

    // verify we navigate to group table view
    [tester waitForViewWithAccessibilityLabel:GROUP_TABLE_VIEW];

    // hit back bar button item navigate back
    [tester tapViewWithAccessibilityLabel:GROUP_LIST_BACK_BUTTON];

    // verify we navigate to group list table view
    [tester waitForViewWithAccessibilityLabel:GROUP_LIST_TABLE_VIEW];
}


#pragma mark - Helper Methods


- (void)joinGroup:(NSString *)groupID
{
    // click "Join" bar button item
    [tester tapViewWithAccessibilityLabel:GROUP_LIST_JOIN_BUTTON];

    // Wait for JoinGroupViewController to load
    [tester waitForViewWithAccessibilityLabel:JOIN_GROUP_VIEW];

    // Enter group name in text field
    [tester enterText:groupID intoViewWithAccessibilityLabel:JOIN_GROUP_NAME_TEXTFIELD];

    // Click the "Join" button
    [tester tapViewWithAccessibilityLabel:JOIN_GROUP_JOIN_BUTTON];

    // Wait for JoinGroupViewController to unload
    [tester waitForAbsenceOfViewWithAccessibilityLabel:JOIN_GROUP_VIEW];

    // Verify that we've added a new "Groups" cell
    [tester waitForViewWithAccessibilityLabel:groupID];
}


- (void)leaveGroup:(NSString *)groupID
{
    // tap the specified row
    [tester tapViewWithAccessibilityLabel:groupID];

    // wait for group table view to load
    [tester waitForViewWithAccessibilityLabel:GROUP_TABLE_VIEW];

    // leave the group
    [tester tapViewWithAccessibilityLabel:GROUP_LEAVE_BUTTON];

    // verify the view closes
    [tester waitForViewWithAccessibilityLabel:GROUP_LIST_TABLE_VIEW];
}


@end

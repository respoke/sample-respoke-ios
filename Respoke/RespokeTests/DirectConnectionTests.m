//
//  DirectConnectionTests.m
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


@interface DirectConnectionTests : KIFTestCase
@end


@implementation DirectConnectionTests


#pragma mark - Pre and Post Test Methods


- (void)beforeAll
{
    // navigate to chat view
    [tester initializeLoginScreen];
    [tester loginEndpoint:[KIFUITestActor generateTestEndpointID] groupName:TEST_BOT_GROUP_ID appID:nil];
    [tester tapViewWithAccessibilityLabel:TEST_BOT_ENDPOINT_ID];
}


- (void)afterAll
{
    // navigate back to login
    [tester tapViewWithAccessibilityLabel:CHAT_BACK_BUTTON];
    [tester logout];
    [tester resetLoginScreen];
}


#pragma mark - UI Tests


- (void)testIncomingConnection
{
    [self initiateIncomingDirectConnection];
    [tester waitForTimeInterval:1.0]; // leave connection open for a bit
    [self closeIncomingDirectConnection];
}

// TODO: Remove this once the fix for dead direct connection is added to Transporter
/*
- (void)testIncomingConnectionIgnore
{
    // enter message in textbox
    [tester enterText:TEST_BOT_DIRECT_CONNECT_MESSAGE intoViewWithAccessibilityLabel:CHAT_MESSAGE_TEXTFIELD];

    // click send
    [tester tapViewWithAccessibilityLabel:CHAT_SEND_BUTTON];

    // wait for table view to disappear
    [tester waitForAbsenceOfViewWithAccessibilityLabel:CHAT_TABLE_VIEW];

    // click ignore
    [tester tapViewWithAccessibilityLabel:CHAT_VIEW_IGNORE_BUTTON];

    // wait for ignore button to disappear
    [tester waitForAbsenceOfViewWithAccessibilityLabel:CHAT_VIEW_IGNORE_BUTTON];

    // wait for chat table view to reappear in regular mode
    [tester waitForViewWithAccessibilityLabel:CHAT_TABLE_VIEW];
}
*/

- (void)testMessaging
{
    // setup direct connection
    [self initiateOutgoingDirectConnection];

    // enter message in textbox
    [tester enterText:TEST_BOT_HELLO_MESSAGE intoViewWithAccessibilityLabel:CHAT_MESSAGE_TEXTFIELD];

    // click send
    [tester tapViewWithAccessibilityLabel:CHAT_SEND_BUTTON];

    // verify reply received
    [tester waitForViewWithAccessibilityLabel:TEST_BOT_HELLO_REPLY];

    // close direct connection
    [self closeOutgoingDirectConnection];
}


#pragma mark - Helper Methods


- (void)initiateIncomingDirectConnection
{
    // enter message in textbox
    [tester enterText:TEST_BOT_DIRECT_CONNECT_MESSAGE intoViewWithAccessibilityLabel:CHAT_MESSAGE_TEXTFIELD];

    // click send
    [tester tapViewWithAccessibilityLabel:CHAT_SEND_BUTTON];

    // click accept
    [tester tapViewWithAccessibilityLabel:CALL_VIEW_ACCEPT_BUTTON];

    // wait for accept button to disappear
    [tester waitForAbsenceOfViewWithAccessibilityLabel:CALL_VIEW_ACCEPT_BUTTON];

    // wait for chat table view to load in direct chat mode
    [tester waitForViewWithAccessibilityLabel:CHAT_DIRECT_TABLE_VIEW];
}


- (void)closeIncomingDirectConnection
{
    // enter message in textbox
    [tester enterText:TEST_BOT_DIRECT_CLOSE_MESSAGE intoViewWithAccessibilityLabel:CHAT_MESSAGE_TEXTFIELD];

    // click send
    [tester tapViewWithAccessibilityLabel:CHAT_SEND_BUTTON];

    // wait for chat table view to reappear in regular mode
    [tester waitForViewWithAccessibilityLabel:CHAT_TABLE_VIEW];
}


- (void)initiateOutgoingDirectConnection
{
    // hit "call" bar button item
    [tester tapViewWithAccessibilityLabel:CHAT_CALL_BUTTON];

    // hit "direct connection" button
    [tester tapViewWithAccessibilityLabel:CHAT_VIDEO_DIRECT_CONNECTION_BUTTON];

    // wait for chat table view to load in direct chat mode
    [tester waitForViewWithAccessibilityLabel:CHAT_DIRECT_TABLE_VIEW];

    // wait for status indicator to disappear
    [tester waitForAbsenceOfViewWithAccessibilityLabel:CHAT_CONNECTING_VIEW];
}


- (void)closeOutgoingDirectConnection
{
    // click close button
    [tester tapViewWithAccessibilityLabel:CHAT_CLOSE_BUTTON];

    // wait for chat table view to reappear in regular mode
    [tester waitForViewWithAccessibilityLabel:CHAT_TABLE_VIEW];
}


@end

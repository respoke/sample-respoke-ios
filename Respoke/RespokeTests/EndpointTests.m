//
//  EndpointTests.m
//  Respoke
//
//  Created by Rob Crabtree on 2/3/15.
//  Copyright (c) 2015 Digium, Inc. All rights reserved.
//

#import <KIF/KIF.h>
#import "KIFUITestActor+Respoke.h"


@interface EndpointTests : KIFTestCase
@end


@implementation EndpointTests


#pragma mark - Pre and Post Test Methods


- (void)beforeAll
{
    [tester initializeLoginScreen];
    [tester loginEndpoint:@"testdevice" groupName:TEST_BOT_GROUP_ID appID:nil];
}


- (void)afterAll
{
    [tester logout];
    [tester resetLoginScreen];
}


#pragma mark - UI Tests


- (void)testMessaging
{
    // click on table cell (testbot endpoint)
    [tester tapViewWithAccessibilityLabel:TEST_BOT_ENDPOINT_ID];

    // enter message in textbox
    [tester enterText:TEST_BOT_HELLO_MESSAGE intoViewWithAccessibilityLabel:CHAT_TABLE_VIEW_MESSAGE_TEXTFIELD];

    // click send
    [tester tapViewWithAccessibilityLabel:CHAT_TABLE_VIEW_SEND_BUTTON];

    // verify reply received
    [tester waitForViewWithAccessibilityLabel:TEST_BOT_HELLO_REPLY];

    // hit back bar button item navigate back
    [tester tapViewWithAccessibilityLabel:CHAT_TABLE_VIEW_BACK_BUTTON];

    // verify we navigate to group list
    [tester waitForViewWithAccessibilityLabel:GROUP_LIST_TABLE_VIEW];
}


- (void)testRemotePresence
{
    // click on table cell (testbot endpoint)
    [tester tapViewWithAccessibilityLabel:TEST_BOT_ENDPOINT_ID];

    // enter message in textbox
    [tester enterText:TEST_BOT_PRESENCE_DND_MESSAGE intoViewWithAccessibilityLabel:CHAT_TABLE_VIEW_MESSAGE_TEXTFIELD];

    // click send to tell testbot to change status to "dnd"
    [tester tapViewWithAccessibilityLabel:CHAT_TABLE_VIEW_SEND_BUTTON];

    // hit back bar button item navigate back
    [tester tapViewWithAccessibilityLabel:CHAT_TABLE_VIEW_BACK_BUTTON];

    // verify testbot changed status to "dnd"
    [tester waitForViewWithAccessibilityLabel:@"dnd"];

    // click on table cell (testbot endpoint)
    [tester tapViewWithAccessibilityLabel:TEST_BOT_ENDPOINT_ID];

    // enter message in textbox
    [tester enterText:TEST_BOT_PRESENCE_AVAIL_MESSAGE intoViewWithAccessibilityLabel:CHAT_TABLE_VIEW_MESSAGE_TEXTFIELD];

    // click send to tell testbot to change status to "available"
    [tester tapViewWithAccessibilityLabel:CHAT_TABLE_VIEW_SEND_BUTTON];

    // hit back bar button item navigate back
    [tester tapViewWithAccessibilityLabel:CHAT_TABLE_VIEW_BACK_BUTTON];

    // verify testbot changed status to "available"
    [tester waitForViewWithAccessibilityLabel:@"available"];
}


- (void)testLocalPresence
{
    // verify status changes
    UIButton *statusButton = (UIButton *) [tester waitForViewWithAccessibilityLabel:GROUP_LIST_STATUS_BUTTON];
    [self setStatus:@"chat" statusButton:statusButton];
    [self setStatus:@"available" statusButton:statusButton];
    [self setStatus:@"away" statusButton:statusButton];
    [self setStatus:@"dnd" statusButton:statusButton];
    [self setStatus:@"unavailable" statusButton:statusButton];

    // verify that status doesn't change if we cancel
    [tester tapViewWithAccessibilityLabel:GROUP_LIST_STATUS_BUTTON];
    [tester tapViewWithAccessibilityLabel:@"Cancel"];
    XCTAssertTrue([statusButton.titleLabel.text hasSuffix:@"unavailable"],
                  @"Status should contain 'unavailable'");
}


#pragma mark - Helper Methods


- (void)setStatus:(NSString *)status statusButton:(UIButton *)statusButton
{
    [tester tapViewWithAccessibilityLabel:GROUP_LIST_STATUS_BUTTON];
    [tester tapViewWithAccessibilityLabel:status];
    XCTAssertTrue([statusButton.titleLabel.text hasSuffix:status],
                  @"Status should contain '%@'", status);
}


@end

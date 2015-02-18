//
//  CallingTests.m
//  Respoke
//
//  Created by Rob Crabtree on 2/6/15.
//  Copyright (c) 2015 Digium, Inc. All rights reserved.
//

#import <KIF/KIF.h>
#import "KIFUITestActor+Respoke.h"


@interface CallingTests : KIFTestCase
@end


@implementation CallingTests


#pragma mark - Pre and Post Test Methods


- (void)beforeAll
{
    [tester initializeLoginScreen];
    [tester loginEndpoint:[KIFUITestActor generateTestEndpointID] groupName:TEST_BOT_GROUP_ID appID:nil];
}


- (void)afterAll
{
    [tester logout];
    [tester resetLoginScreen];
}


#pragma mark - UI Tests


- (void)testOutgoingAudioCall
{
    // click on table cell (testbot endpoint)
    [tester tapViewWithAccessibilityLabel:TEST_BOT_ENDPOINT_ID];

    // hit "call" bar button item
    [tester tapViewWithAccessibilityLabel:CHAT_CALL_BUTTON];

    // hit "audio only" button
    [tester tapViewWithAccessibilityLabel:CHAT_AUDIO_CALL_BUTTON];

    // wait for status indicator to disappear
    [tester waitForAbsenceOfViewWithAccessibilityLabel:CALL_VIEW_STATUS_INDICATOR];

    // hit mute button
    [tester tapViewWithAccessibilityLabel:CALL_VIEW_MUTE_AUDIO_BUTTON];

    // hit unmute button
    [tester tapViewWithAccessibilityLabel:CALL_VIEW_UNMUTE_AUDIO_BUTTON];

    // verify mute button reappears
    [tester waitForViewWithAccessibilityLabel:CALL_VIEW_MUTE_AUDIO_BUTTON];

    // hit end call button
    [tester tapViewWithAccessibilityLabel:CALL_VIEW_END_CALL_BUTTON];

    // verify we navigate back to chat view
    [tester waitForViewWithAccessibilityLabel:CHAT_MESSAGE_TEXTFIELD];

    // hit back bar button item to navigate back to group list
    [tester tapViewWithAccessibilityLabel:CHAT_BACK_BUTTON];

    // verify we navigate to group list
    [tester waitForViewWithAccessibilityLabel:GROUP_LIST_TABLE_VIEW];
}


- (void)testIncomingAudioCall
{
    // click on table cell (testbot endpoint)
    [tester tapViewWithAccessibilityLabel:TEST_BOT_ENDPOINT_ID];

    // enter "call me" message into textbox
    [tester enterText:TEST_BOT_CALL_ME_AUDIO_MESSAGE intoViewWithAccessibilityLabel:CHAT_MESSAGE_TEXTFIELD];

    // click send to request audio call
    [tester tapViewWithAccessibilityLabel:CHAT_SEND_BUTTON];

    // click answer button
    [tester tapViewWithAccessibilityLabel:CALL_VIEW_ANSWER_BUTTON];

    // wait for status indicator to disappear
    [tester waitForAbsenceOfViewWithAccessibilityLabel:CALL_VIEW_STATUS_INDICATOR];

    // hit end call button
    [tester tapViewWithAccessibilityLabel:CALL_VIEW_END_CALL_BUTTON];

    // verify we navigate back to chat view
    [tester waitForViewWithAccessibilityLabel:CHAT_MESSAGE_TEXTFIELD];

    // hit back bar button item to navigate back to group list
    [tester tapViewWithAccessibilityLabel:CHAT_BACK_BUTTON];

    // verify we navigate to group list
    [tester waitForViewWithAccessibilityLabel:GROUP_LIST_TABLE_VIEW];
}


- (void)testIncomingCallIgnore
{
    // click on table cell (testbot endpoint)
    [tester tapViewWithAccessibilityLabel:TEST_BOT_ENDPOINT_ID];

    // enter message in textbox to request audio call
    [tester enterText:TEST_BOT_CALL_ME_AUDIO_MESSAGE intoViewWithAccessibilityLabel:CHAT_MESSAGE_TEXTFIELD];

    // click send
    [tester tapViewWithAccessibilityLabel:CHAT_SEND_BUTTON];

    // click the ignore button
    [tester tapViewWithAccessibilityLabel:CALL_VIEW_IGNORE_BUTTON];

    // verify we navigate back to chat view
    [tester waitForViewWithAccessibilityLabel:CHAT_MESSAGE_TEXTFIELD];

    // hit back bar button item to navigate back to group list
    [tester tapViewWithAccessibilityLabel:CHAT_BACK_BUTTON];

    // verify we navigate to group list
    [tester waitForViewWithAccessibilityLabel:GROUP_LIST_TABLE_VIEW];
}


- (void)testOutgoingVideoCall
{
    // click on table cell (testbot endpoint)
    [tester tapViewWithAccessibilityLabel:TEST_BOT_ENDPOINT_ID];

    // hit "call" bar button item
    [tester tapViewWithAccessibilityLabel:CHAT_CALL_BUTTON];

    // hit "video call" button
    [tester tapViewWithAccessibilityLabel:CHAT_VIDEO_CALL_BUTTON];

    // wait for status indicator to disappear
    [tester waitForAbsenceOfViewWithAccessibilityLabel:CALL_VIEW_STATUS_INDICATOR];

    // verify local video view
    [tester waitForViewWithAccessibilityLabel:CALL_VIEW_LOCAL_VIDEO_VIEW];

    // verify remote video view
    [tester waitForViewWithAccessibilityLabel:CALL_VIEW_REMOTE_VIDEO_VIEW];

    // hit mute audio button
    [tester tapViewWithAccessibilityLabel:CALL_VIEW_MUTE_AUDIO_BUTTON];

    // hit unmute audio button
    [tester tapViewWithAccessibilityLabel:CALL_VIEW_UNMUTE_AUDIO_BUTTON];

    // verify mute audio button reappears
    [tester waitForViewWithAccessibilityLabel:CALL_VIEW_MUTE_AUDIO_BUTTON];

    // hit "switch camera" button
    [tester tapViewWithAccessibilityLabel:CALL_VIEW_SWITCH_CAMERA_BUTTON];

    // TODO: verify camera switched?

    // hit mute video button
    [tester tapViewWithAccessibilityLabel:CALL_VIEW_MUTE_VIDEO_BUTTON];

    // verify local video view disappears
    [tester waitForAbsenceOfViewWithAccessibilityLabel:CALL_VIEW_LOCAL_VIDEO_VIEW];

    // hit unmute video button
    [tester tapViewWithAccessibilityLabel:CALL_VIEW_UNMUTE_VIDEO_BUTTON];

    // verify local video view reappears
    [tester waitForViewWithAccessibilityLabel:CALL_VIEW_LOCAL_VIDEO_VIEW];

    // hit end call button
    [tester tapViewWithAccessibilityLabel:CALL_VIEW_END_CALL_BUTTON];

    // verify we navigate back to chat view
    [tester waitForViewWithAccessibilityLabel:CHAT_MESSAGE_TEXTFIELD];

    // hit back bar button item to navigate back to group list
    [tester tapViewWithAccessibilityLabel:CHAT_BACK_BUTTON];

    // verify we navigate to group list
    [tester waitForViewWithAccessibilityLabel:GROUP_LIST_TABLE_VIEW];
}


- (void)testIncomingVideoCall
{
    // click on table cell (testbot endpoint)
    [tester tapViewWithAccessibilityLabel:TEST_BOT_ENDPOINT_ID];

    // enter "call me" message into textbox
    [tester enterText:TEST_BOT_CALL_ME_VIDEO_MESSAGE intoViewWithAccessibilityLabel:CHAT_MESSAGE_TEXTFIELD];

    // click send to request video call
    [tester tapViewWithAccessibilityLabel:CHAT_SEND_BUTTON];

    // click answer button
    [tester tapViewWithAccessibilityLabel:CALL_VIEW_ANSWER_BUTTON];

    // wait for status indicator to disappear
    [tester waitForAbsenceOfViewWithAccessibilityLabel:CALL_VIEW_STATUS_INDICATOR];

    // verify local video view
    [tester waitForViewWithAccessibilityLabel:CALL_VIEW_LOCAL_VIDEO_VIEW];

    // verify remote video view
    [tester waitForViewWithAccessibilityLabel:CALL_VIEW_REMOTE_VIDEO_VIEW];

    // hit end call button
    [tester tapViewWithAccessibilityLabel:CALL_VIEW_END_CALL_BUTTON];

    // verify we navigate back to chat view
    [tester waitForViewWithAccessibilityLabel:CHAT_MESSAGE_TEXTFIELD];

    // hit back bar button item to navigate back to group list
    [tester tapViewWithAccessibilityLabel:CHAT_BACK_BUTTON];
    
    // verify we navigate to group list
    [tester waitForViewWithAccessibilityLabel:GROUP_LIST_TABLE_VIEW];
}


#pragma mark - Helper Methods


@end
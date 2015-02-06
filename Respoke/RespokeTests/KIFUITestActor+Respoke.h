//
//  KIFUITestActor+Helper.h
//  Respoke
//
//  Created by Rob Crabtree on 1/27/15.
//  Copyright (c) 2015 Digium, Inc. All rights reserved.
//

#import <KIF/KIF.h>


// TestBot constants
#define TEST_BOT_ENDPOINT_ID            @"testbot"
#define TEST_BOT_GROUP_ID               @"robots are taking over"
#define TEST_BOT_HELLO_MESSAGE          @"Hi testbot!"
#define TEST_BOT_HELLO_REPLY            @"Hey pal!"
#define TEST_BOT_PRESENCE_DND_MESSAGE   @"You still there, dude?"
#define TEST_BOT_PRESENCE_DND           @"dnd"
#define TEST_BOT_PRESENCE_AVAIL_MESSAGE @"This is important, we need to talk."
#define TEST_BOT_PRESENCE_AVAIL         @"available"
#define TEST_BOT_CALL_ME_AUDIO_MESSAGE  @"Testbot! Call me sometime! Or now!"
#define TEST_BOT_CALL_ME_VIDEO_MESSAGE  @"Testbot! Video call me sometime! Or now!"
#define TEST_BOT_HANGUP_MESSAGE         @"Hang up dude. I'm done talking."


// LoginViewController accessibility labels
#define LOGIN_ENDPOINT_ID_TEXTFIELD @"Endpoint ID"
#define LOGIN_GROUP_TEXTFIELD       @"Optional Group"
#define LOGIN_APP_ID_TEXTFIELD      @"Optional App ID"
#define LOGIN_CONNECT_BUTTON        @"Connect"
#define LOGIN_CHANGE_APP_ID_BUTTON  @"Change App ID"
#define LOGIN_BROKERED_SWITCH       @"Use Brokered Authentication"
#define LOGIN_ERROR_LABEL           @"Error"


// GroupListTableView accessibility labels
#define GROUP_LIST_TABLE_VIEW       @"Groups and Endpoints"
#define GROUP_LIST_STATUS_BUTTON    @"Change Status"
#define GROUP_LIST_LOGOUT_BUTTON    @"Log Out"
#define GROUP_LIST_JOIN_BUTTON      @"Join Group"


// JoinGroupViewController accessibility labels
#define JOIN_GROUP_VIEW             @"Join a Group"
#define JOIN_GROUP_NAME_TEXTFIELD   @"Group Name"
#define JOIN_GROUP_JOIN_BUTTON      @"Join"


// GroupTableViewController accessibility labels
#define GROUP_TABLE_VIEW            @"Group"
#define GROUP_LEAVE_BUTTON          @"Leave Group"


// ChatTableViewController accessibility labels
#define CHAT_TABLE_VIEW_SEND_BUTTON         @"Send"
#define CHAT_TABLE_VIEW_MESSAGE_TEXTFIELD   @"Message"
#define CHAT_TABLE_VIEW_BACK_BUTTON         @"Back"
#define CHAT_TABLE_VIEW_CALL_BUTTON         @"Call"
#define CHAT_TABLE_VIEW_AUDIO_CALL_BUTTON   @"Audio Only"
#define CHAT_TABLE_VIEW_VIDEO_CALL_BUTTON   @"Video Call"


// CallViewController accessibility labels
#define CALL_VIEW_MUTE_AUDIO_BUTTON         @"Mute Audio"
#define CALL_VIEW_UNMUTE_AUDIO_BUTTON       @"Unmute Audio"
#define CALL_VIEW_MUTE_VIDEO_BUTTON         @"Mute Video"
#define CALL_VIEW_UNMUTE_VIDEO_BUTTON       @"Unmute Video"
#define CALL_VIEW_END_CALL_BUTTON           @"End"
#define CALL_VIEW_ANSWER_BUTTON             @"Answer"
#define CALL_VIEW_IGNORE_BUTTON             @"Ignore"
#define CALL_VIEW_LOCAL_VIDEO_VIEW          @"Local Video"
#define CALL_VIEW_REMOTE_VIDEO_VIEW         @"Remote Video"
#define CALL_VIEW_SWITCH_CAMERA_BUTTON      @"Switch Camera"
#define CALL_VIEW_STATUS_INDICATOR          @"Connecting"


@interface KIFUITestActor (Respoke)


/**
 * Should be called before logging in. This will ensure the appID text field
 * isn't hidden.
 */
- (void)initializeLoginScreen;


/**
 * Should be called after an attempted login. This will ensure the appID text
 * field is hidden.
 */
- (void)resetLoginScreen;


/**
 * This will log in the user with the specified endpoint, groupName, and appID.
 * The login screen should be initilized prior to calling this method.
 *
 * @param endpoint  The name of the endpoint
 * @param groupName The name of the group (optional)
 * @param appID     The ID of the app (optional)
 */
- (void)loginEndpoint:(NSString *)endpoint groupName:(NSString *)groupName appID:(NSString *)appID;


/**
 * This will logout the user. Be sure to reset the login screen after calling
 * this method.
 */
- (void)logout;
@end

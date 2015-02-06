//
//  KIFUITestActor+Helper.h
//  Respoke
//
//  Created by Rob Crabtree on 1/27/15.
//  Copyright (c) 2015 Digium, Inc. All rights reserved.
//

#import <KIF/KIF.h>


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

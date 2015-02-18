//
//  KIFUITestActor+Helper.m
//  Respoke
//
//  Created by Rob Crabtree on 1/27/15.
//  Copyright (c) 2015 Digium, Inc. All rights reserved.
//

#import "KIFUITestActor+Respoke.h"
#import "AppDelegate.h"
#import "RespokeClient+private.h"
#import <KIF/KIFTypist.h>


@implementation KIFUITestActor (Respoke)


#define LAST_APP_ID_KEY         @"LAST_APP_ID_KEY"
#define RESPOKE_TEST_BASE_URL   @"https://api-int.respoke.io"


+ (NSString*)generateTestEndpointID
{
    NSString *uuid = @"test_user_";
    NSString *chars = @"0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz";
    NSInteger rnd = 0;
    NSInteger r;
    
    for (NSInteger i = 0; i < 6; i += 1)
    {
        if (rnd <= 0x02)
        {
            rnd = 0x2000000 + (arc4random() % 0x1000000) | 0;
        }
        r = rnd & 0xf;
        rnd = rnd >> 4;
        
        uuid = [uuid stringByAppendingString:[chars substringWithRange:NSMakeRange(r, 1)]];
    }
    
    return uuid;
}


- (void)initializeLoginScreen
{
    [KIFTypist setKeystrokeDelay:0.25];
    
    // This is a workaround to clear out any appIDs that may have been saved in user defaults
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // show the app id text field
        [tester tapViewWithAccessibilityLabel:LOGIN_CHANGE_APP_ID_BUTTON];

        // clear out all text
        [self resetLoginScreen];

        // use the intergration server for testing
        sharedRespokeClient = [[Respoke sharedInstance] createClient];
        [sharedRespokeClient setBaseURL:RESPOKE_TEST_BASE_URL];
    });

    // hit change app id button
    [tester tapViewWithAccessibilityLabel:LOGIN_CHANGE_APP_ID_BUTTON];

    // wait for app id text field to appear
    [tester waitForViewWithAccessibilityLabel:LOGIN_APP_ID_TEXTFIELD];
}


- (void)resetLoginScreen
{
    // clear endpointID, groupName, and appID
    [tester clearTextFromViewWithAccessibilityLabel:LOGIN_ENDPOINT_ID_TEXTFIELD];
    [tester clearTextFromViewWithAccessibilityLabel:LOGIN_GROUP_TEXTFIELD];
    [tester clearTextFromViewWithAccessibilityLabel:LOGIN_APP_ID_TEXTFIELD];

    // hide the "app id" textfield and show the "change app id" button
    [tester setOn:YES forSwitchWithAccessibilityLabel:LOGIN_BROKERED_SWITCH];
    [tester setOn:NO forSwitchWithAccessibilityLabel:LOGIN_BROKERED_SWITCH];

    // ensure the change app id button is present
    [tester waitForViewWithAccessibilityLabel:LOGIN_CHANGE_APP_ID_BUTTON];
}


- (void)loginEndpoint:(NSString *)endpoint groupName:(NSString *)groupName appID:(NSString *)appID
{
    // enter endpointID and group textfields
    if (endpoint)
    {
        [tester enterText:endpoint intoViewWithAccessibilityLabel:LOGIN_ENDPOINT_ID_TEXTFIELD];
    }
    if (groupName)
    {
        [tester enterText:groupName intoViewWithAccessibilityLabel:LOGIN_GROUP_TEXTFIELD];
    }

    if (appID)
    {
        // enter app id
        [tester enterText:appID intoViewWithAccessibilityLabel:LOGIN_APP_ID_TEXTFIELD];
    }

    // hit the login button
    [tester tapViewWithAccessibilityLabel:LOGIN_CONNECT_BUTTON];

    // ensure the group list table view appears
    [tester waitForViewWithAccessibilityLabel:GROUP_LIST_TABLE_VIEW];
}


- (void)logout
{
    // make sure we are at the expected view
    [tester waitForViewWithAccessibilityLabel:GROUP_LIST_TABLE_VIEW];

    // hit the logout button
    [tester tapViewWithAccessibilityLabel:GROUP_LIST_LOGOUT_BUTTON];

    // wait for login screen to appear
    [tester waitForViewWithAccessibilityLabel:LOGIN_ENDPOINT_ID_TEXTFIELD];
}

@end

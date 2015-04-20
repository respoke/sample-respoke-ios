//
//  AppDelegate.h
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

#import <UIKit/UIKit.h>
#import "Respoke.h"
#import "ContactManager.h"


@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property RespokeClient *respokeClient;
@property ContactManager *contactManager;

@end


#define sharedAppInstance ((AppDelegate*) [UIApplication sharedApplication].delegate)
#define sharedRespokeClient (sharedAppInstance.respokeClient)
#define sharedContactManager (sharedAppInstance.contactManager)

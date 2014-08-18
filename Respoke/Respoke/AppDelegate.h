//
//  AppDelegate.h
//  Respoke
//
//  Created by Jason Adams on 7/3/14.
//  Copyright (c) 2014 Digium, Inc. All rights reserved.
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

//
//  GroupTableViewController.h
//  Respoke
//
//  Created by Jason Adams on 7/11/14.
//  Copyright (c) 2014 Digium, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "RespokeGroup.h"


@interface GroupTableViewController : UITableViewController

@property RespokeGroup *group;

- (IBAction)leaveAction;

@end

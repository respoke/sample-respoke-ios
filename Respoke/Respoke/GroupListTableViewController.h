//
//  GroupListTableViewController.h
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
#import "RespokeClient.h"


@interface GroupListTableViewController : UITableViewController <RespokeClientDelegate, UIActionSheetDelegate> {
    NSMutableArray *groupsToJoin;
}

@property (weak) IBOutlet UIButton *statusButton;
@property (weak) IBOutlet UIActivityIndicatorView *activityIndicator;

- (IBAction)logoutAction;
- (IBAction)statusAction;

@end

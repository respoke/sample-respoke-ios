//
//  GroupChatTableViewController.h
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
#import "RespokeGroup.h"


@interface GroupChatTableViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>

@property RespokeGroup *group;
@property (weak) IBOutlet NSLayoutConstraint *bottomConstraint;
@property (weak) IBOutlet UITableView *tableView;
@property (weak) IBOutlet UITextField *textField;
@property (weak) IBOutlet UIBarButtonItem *textItem;

- (IBAction)sendAction;

@end

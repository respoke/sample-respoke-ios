//
//  GroupChatTableViewController.h
//  Respoke
//
//  Created by Jason Adams on 8/18/14.
//  Copyright (c) 2014 Digium, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RespokeGroup.h"


@interface GroupChatTableViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>

@property RespokeGroup *group;
@property (weak) IBOutlet NSLayoutConstraint *bottomConstraint;
@property (weak) IBOutlet UITableView *tableView;
@property (weak) IBOutlet UITextField *textField;

- (IBAction)sendAction;

@end

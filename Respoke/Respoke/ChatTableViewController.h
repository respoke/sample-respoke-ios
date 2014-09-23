//
//  ChatTableViewController.h
//  Respoke
//
//  Created by Jason Adams on 7/14/14.
//  Copyright (c) 2014 Digium, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RespokeEndpoint.h"


@interface ChatTableViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>

@property RespokeEndpoint *endpoint;
@property (weak) IBOutlet NSLayoutConstraint *bottomConstraint;
@property (weak) IBOutlet UITableView *tableView;
@property (weak) IBOutlet UITextField *textField;
@property (weak) IBOutlet UIBarButtonItem *textItem;

- (IBAction)sendAction;
- (IBAction)callAction;

@end

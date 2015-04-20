//
//  ChatTableViewController.h
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
#import "RespokeEndpoint.h"


@interface ChatTableViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>

@property RespokeEndpoint *endpoint;
@property RespokeDirectConnection *directConnection;
@property (weak) IBOutlet NSLayoutConstraint *bottomConstraint;
@property (weak) IBOutlet UITableView *tableView;
@property (weak) IBOutlet UITextField *textField;
@property (weak) IBOutlet UIBarButtonItem *textItem;
@property (weak) IBOutlet UIView *connectingView;
@property (weak) IBOutlet UIView *answerView;
@property (weak) IBOutlet UILabel *callerNameLabel;

- (IBAction)sendAction;
- (IBAction)callAction;
- (IBAction)acceptConnection;
- (IBAction)ignoreConnection;

@end

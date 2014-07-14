//
//  GroupTableViewController.h
//  Respoke
//
//  Created by Jason Adams on 7/11/14.
//  Copyright (c) 2014 Ninjanetic Design Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"


@interface GroupTableViewController : UITableViewController <RespokeClientDelegate, RespokeGroupDelegate>

@property NSString *username;
@property RespokeGroup *group;
@property NSMutableArray *groupMembers;

@end

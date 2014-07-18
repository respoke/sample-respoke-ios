//
//  CallViewController.h
//  Respoke
//
//  Created by Jason Adams on 7/9/14.
//  Copyright (c) 2014 Ninjanetic Design Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RespokeEndpoint.h"


@interface CallViewController : UIViewController

@property (weak) IBOutlet UIView *remoteView;
@property (weak) IBOutlet UIView *localView;
@property RespokeEndpoint *endpoint;

@end

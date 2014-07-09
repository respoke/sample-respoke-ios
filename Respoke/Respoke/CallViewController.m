//
//  CallViewController.m
//  Respoke
//
//  Created by Jason Adams on 7/9/14.
//  Copyright (c) 2014 Ninjanetic Design Inc. All rights reserved.
//

#import "CallViewController.h"
#import "Respoke.h"


@interface CallViewController ()

@end


@implementation CallViewController


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];

    [[Respoke sharedInstance] startCallWithEndpoint:self.endpoint remoteVideoView:self.remoteView localVideoView:self.localView];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

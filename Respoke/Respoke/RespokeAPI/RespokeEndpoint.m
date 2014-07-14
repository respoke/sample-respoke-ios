//
//  RespokeEndpoint.m
//  Respoke
//
//  Created by Jason Adams on 7/14/14.
//  Copyright (c) 2014 Ninjanetic Design Inc. All rights reserved.
//

#import "RespokeEndpoint.h"


@implementation RespokeEndpoint


- (instancetype)init
{
    if (self = [super init])
    {
        self.connections = [[NSMutableArray alloc] init];
    }

    return self;
}


@end

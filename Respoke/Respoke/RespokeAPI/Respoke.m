//
//  Respoke.m
//  Respoke
//
//  Created by Jason Adams on 7/7/14.
//  Copyright (c) 2014 Ninjanetic Design Inc. All rights reserved.
//

#import "Respoke.h"
#import "RTCPeerConnectionFactory.h"


@interface Respoke() {
    NSMutableDictionary *instances;
}


@end


@implementation Respoke 


// The Respoke SDK class is a singleton that should be accessed through this share instance method
+ (Respoke *)sharedInstance
{
    static Respoke *sharedInstance = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        sharedInstance = [[Respoke alloc] init];
    });
    
    return sharedInstance;
}


+ (NSString*)makeGUID
{
    NSString *uuid = @"";
    NSString *chars = @"0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz";
    NSInteger rnd = 0;
    NSInteger r;

    for (NSInteger i = 0; i < 36; i += 1) 
    {
        if (i == 8 || i == 13 ||  i == 18 || i == 23) 
        {
            uuid = [uuid stringByAppendingString:@"-"];
        } 
        else if (i == 14) 
        {
            uuid = [uuid stringByAppendingString:@"4"];
        } 
        else 
        {
            if (rnd <= 0x02) 
            {
                rnd = 0x2000000 + (arc4random() % 0x1000000) | 0;
            }
            r = rnd & 0xf;
            rnd = rnd >> 4;

            if (i == 19)
            {
                uuid = [uuid stringByAppendingString:[chars substringWithRange:NSMakeRange((r & 0x3) | 0x8, 1)]];
            }
            else
            {
                uuid = [uuid stringByAppendingString:[chars substringWithRange:NSMakeRange(r, 1)]];
            }
        }
    }

    return uuid;
}


- (instancetype)init 
{
    if (self = [super init])
    {
        instances = [[NSMutableDictionary alloc] init];

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillTerminate) name:UIApplicationWillTerminateNotification object:nil];
    }

    return self;
}


- (RespokeClient*)createClientWithAppID:(NSString*)appID developmentMode:(BOOL)developmentMode
{
    RespokeClient *newClient = [[RespokeClient alloc] initWithAppID:appID developmentMode:developmentMode];
    return newClient;
}


- (void)applicationWillTerminate
{
    [RTCPeerConnectionFactory deinitializeSSL];
}


@end

//
//  RespokeClient.m
//  Respoke
//
//  Created by Jason Adams on 7/11/14.
//  Copyright (c) 2014 Ninjanetic Design Inc. All rights reserved.
//

#import "RespokeClient.h"
#import "APIGetToken.h"
#import "APIDoOpen.h"


@interface RespokeClient () {
    BOOL devMode;
    BOOL reconnect;
    NSString *applicationID;
    NSString *endpointID;
}

@end


@implementation RespokeClient


- (instancetype)initWithAppID:(NSString*)appID developmentMode:(BOOL)developmentMode
{
    if (self = [super init])
    {
        applicationID = appID;
        devMode = developmentMode;
        reconnect = developmentMode;
    }

    return self;
}


- (void)connectWithEndpointID:(NSString*)endpoint errorHandler:(void (^)(NSString*))errorHandler
{
    endpointID = endpoint;

    if (([endpoint length]) && ([applicationID length]))
    {
        APIGetToken *getToken = [[APIGetToken alloc] init];
        getToken.appID = applicationID;
        getToken.endpointID = endpoint;

        [getToken goWithSuccessHandler:^{
            APIDoOpen *doOpen = [[APIDoOpen alloc] init];
            doOpen.tokenID = getToken.token;

            [doOpen goWithSuccessHandler:^{
                NSLog(@"Got app token: [%@]", doOpen.appToken);
                [self.connectionDelegate onConnect:self];
            } errorHandler:^(NSString *errorMessage){
                errorHandler(errorMessage);
            }];

        } errorHandler:^(NSString *errorMessage){
            errorHandler(errorMessage);
        }];
    }
    else
    {
        errorHandler(@"AppID and endpointID must be specified");
    }
}


@end

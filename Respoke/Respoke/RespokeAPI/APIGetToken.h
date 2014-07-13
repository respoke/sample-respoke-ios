//
//  APIGetToken.h
//  Respoke
//
//  Created by Jason Adams on 7/11/14.
//  Copyright (c) 2014 Ninjanetic Design Inc. All rights reserved.
//

#import "APITransaction.h"

@interface APIGetToken : APITransaction

@property NSString *appID;
@property NSString *endpointID;
@property NSString *token;

@end

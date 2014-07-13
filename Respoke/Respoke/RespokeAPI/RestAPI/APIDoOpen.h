//
//  APIDoOpen.h
//  Respoke
//
//  Created by Jason Adams on 7/13/14.
//  Copyright (c) 2014 Ninjanetic Design Inc. All rights reserved.
//

#import "APITransaction.h"

@interface APIDoOpen : APITransaction

// Parameters to send
@property NSString *tokenID;

// Results
@property NSString *appToken;

@end

//
//  ApiTransaction.h
//  Respoke
//
//  Created by Jason Adams on 7/12/14.
//  Copyright (c) 2014 Ninjanetic Design Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface APITransaction : NSObject <NSURLConnectionDataDelegate> {
    NSURLConnection *connection;
    NSString *httpMethod;
    NSString *params;
    NSString *urlEndpoint;
    BOOL abort;
    BOOL silentMode;
}

@property NSString *baseURL;
@property BOOL success;
@property NSMutableData *receivedData;
@property id jsonResult;
@property (copy) void (^successHandler)();
@property (copy) void (^errorHandler)(NSString*);
@property NSString *errorMessage;

- (void)goWithSuccessHandler:(void (^)())successHandler errorHandler:(void (^)(NSString*))errorHandler;
- (void)transactionComplete;
- (void)cancel;

@end

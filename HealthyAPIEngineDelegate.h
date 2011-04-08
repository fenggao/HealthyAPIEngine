//
//  HealthyAPIEngineDelegate.h
//  healthy-iosapp
//
//  Created by Feng Gao on 11-3-15.
//  Copyright 2011年 hciatsoton. All rights reserved.
//

#import "HealthyAPIGlobalHeader.h"
#import "HealthyAPIConnection.h"

@protocol HealthyAPIEngineDelegate

//NOTE: identifier actually is only used for debug

//request start loading
- (void)requestLoading:(HealthyAPIConnection *) connection;

//if request fail, then notify receiver
- (void)requestFailed:(HealthyAPIConnection *) connection withError:(NSError *)error;

//These delegate methods are called after requestsucceeded, they will notify the receiver it's time to parse response data to populate views or notify the receiver api call fail then could call it again
- (void)apiSucceeded:(HealthyAPIConnection *) connection withResult:(NSDictionary *) result;
- (void)apiFail:(HealthyAPIConnection *) connection withStatus:(NSString *) status withErrorMsg:(NSString *) errormsg;


// This delegate method is called whenever a connection has been deliberately cancelled
- (void)connectionFinished;

@end

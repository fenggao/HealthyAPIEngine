//
//  HealthyAPIConnection.h
//  healthy-iosapp
//
//  Created by Feng Gao on 11-3-15.
//  Copyright 2011 hciatsoton. All rights reserved.
//

#import "HealthyAPIGlobalHeader.h"
#import "HealthyAPITypes.h"


@interface HealthyAPIConnection : TTURLRequest {
    HealthyAPIRequestType _requestType;      // general type of this request, mostly for error handling
    HealthyAPIResponseType _responseType;    // type of response data expected (if successful)    
    NSString *_identifier; //for each connection a unique identifier will be generated
}

// Initializer
+ (HealthyAPIConnection*)requestWithURL:(NSString*)URL delegate:(id /*<TTURLRequestDelegate>*/)delegate requestType:(HealthyAPIRequestType)requestType responseType:(HealthyAPIResponseType)responseType;

- (id)initWithURL:(NSString *)URL delegate:(id /*<TTURLRequestDelegate>*/)delegate requestType:(HealthyAPIRequestType)requestType responseType:(HealthyAPIResponseType)responseType;

// Accessors
- (HealthyAPIRequestType)requestType;
- (HealthyAPIResponseType)responseType;
- (NSString *)identifier;

@end

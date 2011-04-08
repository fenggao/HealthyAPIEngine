//
//  HealthyAPIConnection.m
//  healthy-iosapp
//
//  Created by Feng Gao on 11-3-15.
//  Copyright 2011 hciatsoton. All rights reserved.
//

#import "HealthyAPIConnection.h"
#import "NSString+UUID.h"


@implementation HealthyAPIConnection

#pragma mark -
#pragma mark Initializer


+ (HealthyAPIConnection*)requestWithURL:(NSString*)URL delegate:(id /*<TTURLRequestDelegate>*/)delegate requestType:(HealthyAPIRequestType)requestType responseType:(HealthyAPIResponseType)responseType
{
    return [[[HealthyAPIConnection alloc] initWithURL:URL delegate:delegate requestType:requestType responseType:responseType] autorelease];
}

- (id)initWithURL:(NSString *)URL delegate:(id /*<TTURLRequestDelegate>*/)delegate requestType:(HealthyAPIRequestType)requestType responseType:(HealthyAPIResponseType)responseType;
{
    if (self = [super initWithURL:URL delegate:delegate]) {
        _requestType = requestType;
        _responseType = responseType;
        _identifier = [[NSString stringWithNewUUID] retain];
    }
    
    return self;
}


- (void)dealloc
{   
    [_identifier release];
    [super dealloc];
}


#pragma mark -
#pragma mark Accessors



- (HealthyAPIRequestType)requestType
{
    return _requestType;
}


- (HealthyAPIResponseType)responseType
{
    return _responseType;
}

- (NSString *)identifier
{
    return [[_identifier retain] autorelease];
}


@end

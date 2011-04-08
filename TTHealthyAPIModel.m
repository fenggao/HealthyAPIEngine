//
//  TTHealthyAPIModel.m
//  healthy-iosapp
//
//  Created by Feng Gao on 11-3-15.
//  Copyright 2011 hciatsoton. All rights reserved.
//


/***
*To use this model,just subclass it and you need to at least override:
* (1) -(id)init method
* (2) - (void)load:(TTURLRequestCachePolicy)cachePolicy more:(BOOL)more 
*     In this function, call api to request data
* (3) In most case, just need to handle 
*     - (void)apiSucceeded:(HealthyAPIConnection *) connection withResult:(NSDictionary *)result
*     don't forget to call [super apisucceeded: withResult: ] in your implemention of this delegate
*/




#import "TTHealthyAPIModel.h"


#import "Three20Network/TTURLRequestModel.h"

// Network
#import "Three20Network/TTURLRequest.h"
#import "Three20Network/TTURLRequestQueue.h"
#import "Three20Network/TTURLCache.h"

// Core
#import "Three20Core/TTCorePreprocessorMacros.h"

@implementation TTHealthyAPIModel


@synthesize loadedTime  = _loadedTime;
@synthesize cacheKey    = _cacheKey;
@synthesize hasNoMore   = _hasNoMore;



#pragma mark -
#pragma mark Class Management

- (id)init {
    if (self = [super init]) {
        _api = [(HealthyAPIEngine *)[HealthyAPIEngine alloc] initWithDelegate:self];    
    }
    
    return self;
}


- (void)dealloc {
    [_api closeAllConnections:TRUE];
    [_api removeDelegate];
    TT_RELEASE_SAFELY(_api);
    TT_RELEASE_SAFELY(_loadedTime);
    TT_RELEASE_SAFELY(_cacheKey);
    
    [super dealloc];
}


- (void)reset {
    TT_RELEASE_SAFELY(_cacheKey);
    TT_RELEASE_SAFELY(_loadedTime);
}

#pragma mark -
#pragma mark TTModel


- (BOOL)isLoaded {
    return !!_loadedTime;
}


- (BOOL)isLoading {
    return !![_api numberOfConnections];
}



- (BOOL)isLoadingMore {
    return _isLoadingMore;
}


- (BOOL)isOutdated {
    if (nil == _cacheKey) {
        return nil != _loadedTime;
        
    } else {
        NSDate* loadedTime = self.loadedTime;
        
        if (nil != loadedTime) {
            return -[loadedTime timeIntervalSinceNow] > [TTURLCache sharedCache].invalidationAge;
            
        } else {
            return NO;
        }
    }
}



- (void)cancel {
    [_api closeAllConnections:FALSE];
}


- (void)invalidate:(BOOL)erase {
    if (nil != _cacheKey) {
        if (erase) {
            [[TTURLCache sharedCache] removeKey:_cacheKey];
            
        } else {
            [[TTURLCache sharedCache] invalidateKey:_cacheKey];
        }
        
        TT_RELEASE_SAFELY(_cacheKey);
    }
}


//Implement this function to call specific api. The base one does nothing

- (void)load:(TTURLRequestCachePolicy)cachePolicy more:(BOOL)more 
{

}



#pragma mark -
#pragma mark HealthyAPIEngineDelegate



//request start loading
- (void)requestLoading:(HealthyAPIConnection *) connection
{
    [self didStartLoad];
}

//if request fail, then notify receiver
- (void)requestFailed:(HealthyAPIConnection *) connection withError:(NSError *)error
{
    NSLog(@"request fail!!");
    [self didFailLoadWithError:error];

}

//These two delegate methods are called after requestsucceeded, they will notify the receiver it's time to parse response data to populate views or notify the receiver api call fail then could call it again
- (void)apiSucceeded:(HealthyAPIConnection *) connection withResult:(NSDictionary *)result
{
    if (!self.isLoadingMore) {
        [_loadedTime release];
        _loadedTime = [connection.timestamp retain];
        self.cacheKey = connection.cacheKey;
    }
    [_api closeConnection:[connection identifier] isFinished:TRUE];
    [self didFinishLoad];
}
- (void)apiFail:(HealthyAPIConnection *) connection withStatus:(NSString *) status withErrorMsg:(NSString *) errormsg
{
    NSLog(@"api fails!!responsetype:%@",[connection responseType]);
    NSLog(@"%@:%@",status,errormsg);
    [_api closeConnection:[connection identifier] isFinished:TRUE];
    [self didFailLoadWithError:nil];

}

// This delegate method is called whenever a connection has deliberately finished.
- (void)connectionFinished
{
    [self didCancelLoad];
}

@end

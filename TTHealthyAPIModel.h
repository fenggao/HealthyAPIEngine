//
//  TTHealthyAPIModel.h
//  healthy-iosapp
//
//  Created by Feng Gao on 11-3-15.
//  Copyright 2011 hciatsoton. All rights reserved.
//

// Network
#import "Three20Network/TTModel.h"
#import "HealthyAPIEngineDelegate.h"

#import "HealthyAPIEngine.h"

/**
 * This MODEL steals the idea of original TTURLRequestModel. 
 *
 * This is a implemention of TTHealthyAPIModel which is built to work with HealthyAPIEngine and Three20.
 *
 * If you use a TTHealthyAPIModel as the delegate of your HealthyAPIEngine, it will automatically
 * manage many of the TTModel properties based on the state of your requests.
 *
 * To use this model, just subclass it and implement functions and delegates. Details in .m file
 */
@interface TTHealthyAPIModel : TTModel <HealthyAPIEngineDelegate> {
    HealthyAPIEngine * _api;
    
    NSDate*       _loadedTime;
    NSString*     _cacheKey;
    
    BOOL          _isLoadingMore;
    BOOL          _hasNoMore;
}

/**
 * Valid upon completion of the URL request. Represents the timestamp of the completed request.
 */
@property (nonatomic, retain) NSDate*   loadedTime;

/**
 * Valid upon completion of the URL request. Represents the request's cache key.
 */
@property (nonatomic, copy)   NSString* cacheKey;

/**
 * Not used internally, but intended for book-keeping purposes when making requests.
 */
@property (nonatomic) BOOL hasNoMore;

/**
 * Resets the model to its original state before any data was loaded.
 */
- (void)reset;

/** TODO
 * Valid while loading. Returns download progress as between 0 and 1.
 *- (float)downloadProgress;
 */


@end


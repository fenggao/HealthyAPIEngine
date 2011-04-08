//
//  HealthyAPIEngine.m
//  healthy-iosapp
//
//  Created by Feng Gao on 11-3-15.
//  Copyright 2011 hciatsoton. All rights reserved.
//

#import "HealthyAPIEngine.h"
#import "HealthyAPIConnection.h"
#import "SFHFKeychainUtils.h"



#if TARGET_IPHONE_SIMULATOR 
#define API_DOMAIN          @"127.0.0.1:8000/app/api"
#else
#define API_DOMAIN          @"hci.ecs.soton.ac.uk/healthy/app/api"
#endif

#define HTTP_POST_METHOD    @"POST"
#define HTTP_GET_METHOD     @"GET"

static NSString *_username;
static NSString *_password;




@interface HealthyAPIEngine (PrivateMethods)

// Utility methods
- (NSDateFormatter *)_HTTPDateFormatter;
- (NSString *)_queryStringWithBase:(NSString *)base parameters:(NSDictionary *)params prefixed:(BOOL)prefixed;
- (NSDate *)_HTTPToDate:(NSString *)httpDate;
- (NSString *)_dateToHTTP:(NSDate *)date;
- (NSString *)_encodeString:(NSString *)string;

// Connection/Request methods

- (NSString *)_sendRequestWithMethod:(NSString *)method 
                                path:(NSString *)path 
                     queryParameters:(NSDictionary *)query
                          postparams:(NSDictionary *)params
                         requestType:(HealthyAPIRequestType)requestType 
                        responseType:(HealthyAPIResponseType)responseType
                        cachePolicy:(TTURLRequestCachePolicy)cachePolicy;

// Parsing methods
- (void)_parseDataForConnection:(HealthyAPIConnection *)connection;

// Delegate methods
- (BOOL) _isValidDelegateForSelector:(SEL)selector;

@end


@implementation HealthyAPIEngine

#pragma mark -
#pragma mark Constructors


+ (HealthyAPIEngine *)APIEngineWithDelegate:(id)theDelegate
{
    return [[[HealthyAPIEngine alloc] initWithDelegate:theDelegate] autorelease];
}


- (HealthyAPIEngine *)initWithDelegate:(id)newDelegate
{
    if (self = [super init]) {
        _delegate = newDelegate; // deliberately weak reference
        _connections = [[NSMutableDictionary alloc] initWithCapacity:0];
		_APIDomain = [API_DOMAIN retain];
    }
    
    return self;
}


- (void)dealloc
{
    _delegate = nil;
    [[_connections allValues] makeObjectsPerformSelector:@selector(cancel)];
    TT_RELEASE_SAFELY(_connections);
    
    TT_RELEASE_SAFELY(_APIDomain);

    [super dealloc];
}


#pragma mark -
#pragma mark Configuration and Accessors


+ (NSString *)username
{
	if(!_username)
		_username = [[[NSUserDefaults standardUserDefaults] stringForKey:@"DefaultAccount"] retain];
    return [[_username retain] autorelease];
}


+ (NSString *)password
{
	if(!_password && [HealthyAPIEngine username])
	{
#if !TARGET_IPHONE_SIMULATOR
        NSError *sferror = nil;
        _password = [SFHFKeychainUtils getPasswordForUsername:[HealthyAPIEngine username] andServiceName:@"Healthy@SOTON" error:sferror];

#else
		_password = [[[NSUserDefaults standardUserDefaults] objectForKey:@"DefaultPassword"] retain];
#endif
	}
	
    return [[_password retain] autorelease];
}



+ (void)setUsername:(NSString *)newUsername password:(NSString *)newPassword remember:(BOOL)storePassword
{
    // Set new credentials.
    [_username release];
    _username = [newUsername retain];
    [_password release];
    _password = [newPassword retain];
	NSError *sferror = nil;
    
    //use excellent SFMFKeychain to store credentials
	if(storePassword)
	{
        [[NSUserDefaults standardUserDefaults] setObject:_username forKey:@"DefaultAccount"];
        
        [SFHFKeychainUtils storeUsername:_username andPassword:_password forServiceName:@"HealthyAPI@SOTON" updateExisting:TRUE error:&sferror];
        
	}
    else
	{
		[[NSUserDefaults standardUserDefaults] removeObjectForKey:@"DefaultAccount"];
	}
	

}

+ (void)forgetPassword
{
	[[NSUserDefaults standardUserDefaults] removeObjectForKey:@"DefaultAccount"];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

+ (void)remindPassword
{
	[[NSUserDefaults standardUserDefaults] setObject:[HealthyAPIEngine username] forKey:@"DefaultAccount"];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSString *)APIDomain
{
	return [[_APIDomain retain] autorelease];
}


- (void)setAPIDomain:(NSString *)domain
{
	[_APIDomain release];
	if (!domain || [domain length] == 0) {
		_APIDomain = [API_DOMAIN retain];
	} else {
		_APIDomain = [domain retain];
	}
}

#pragma mark -
#pragma mark Connection methods


- (int)numberOfConnections
{
    return [_connections count];

}


- (NSArray *)connectionIdentifiers
{
    return [_connections allKeys];
}


- (void)closeConnection:(NSString *)identifier isFinished:(BOOL) finished
{
    
    HealthyAPIConnection *connection = [_connections objectForKey:identifier];
    if (connection) {
        [connection cancel];
        [_connections removeObjectForKey:identifier];
        if ([self _isValidDelegateForSelector:@selector(connectionFinished)] && !finished)
			[_delegate connectionFinished];
    }
}


- (void)closeAllConnections: (BOOL) finished
{
    [[_connections allValues] makeObjectsPerformSelector:@selector(cancel)];
    [_connections removeAllObjects];
    if ([self _isValidDelegateForSelector:@selector(connectionFinished)] && !finished)
        [_delegate connectionFinished];
}

#pragma mark -
#pragma mark Delegate methods

- (void) removeDelegate
{
	_delegate = nil;
}



- (BOOL) _isValidDelegateForSelector:(SEL)selector
{
	return ((_delegate != nil) && [_delegate respondsToSelector:selector]);
}

#pragma mark -
#pragma mark Utility methods


- (NSDateFormatter *)_HTTPDateFormatter
{
    // Returns a formatter for dates in HTTP format (i.e. RFC 822, updated by RFC 1123).
    // e.g. "Sun, 06 Nov 1994 08:49:37 GMT"
	NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
	//[dateFormatter setDateFormat:@"%a, %d %b %Y %H:%M:%S GMT"]; // won't work with -init, which uses new (unicode) format behaviour.
	[dateFormatter setFormatterBehavior:NSDateFormatterBehavior10_4];
	[dateFormatter setDateFormat:@"EEE, dd MMM yyyy HH:mm:ss GMT"];
	return dateFormatter;
}


- (NSString *)_queryStringWithBase:(NSString *)base parameters:(NSDictionary *)params prefixed:(BOOL)prefixed
{
    // Append base if specified.
    NSMutableString *str = [NSMutableString stringWithCapacity:0];
    if (base) {
        [str appendString:base];
    }
    
    // Append each name-value pair.
    if (params) {
        int i;
        NSArray *names = [params allKeys];
        for (i = 0; i < [names count]; i++) {
            if (i == 0 && prefixed) {
                [str appendString:@"?"];
            } else if (i > 0) {
                [str appendString:@"&"];
            }
            NSString *name = [names objectAtIndex:i];
            [str appendString:[NSString stringWithFormat:@"%@=%@", 
                               name, [self _encodeString:[params objectForKey:name]]]];
        }
    }
    
    return str;
}


- (NSDate *)_HTTPToDate:(NSString *)httpDate
{
    NSDateFormatter *dateFormatter = [self _HTTPDateFormatter];
    return [dateFormatter dateFromString:httpDate];
}


- (NSString *)_dateToHTTP:(NSDate *)date
{
    NSDateFormatter *dateFormatter = [self _HTTPDateFormatter];
    return [dateFormatter stringFromDate:date];
}


- (NSString *)_encodeString:(NSString *)string
{
    NSString *result = (NSString *)CFURLCreateStringByAddingPercentEscapes(NULL, 
        (CFStringRef)string, NULL, (CFStringRef)@";/?:@&=$+{}<>,",kCFStringEncodingUTF8);
    return [result autorelease];
}

#pragma mark -
#pragma mark Request sending methods



- (NSString *)_sendRequestWithMethod:(NSString *)method 
                                path:(NSString *)path 
                     queryParameters:(NSDictionary *)query 
                          postparams:(NSDictionary *)params
                         requestType:(HealthyAPIRequestType)requestType 
                        responseType:(HealthyAPIResponseType)responseType
                         cachePolicy:(TTURLRequestCachePolicy)cachePolicy
{
    // Construct appropriate URL string.
    NSString *fullPath = path;
    if (query) {
        fullPath = [self _queryStringWithBase:fullPath parameters:query prefixed:YES];
    }
    

	NSString *domain = _APIDomain;
	NSString *connectionType = @"http";   
    NSString *urlString = [NSString stringWithFormat:@"%@://%@/%@", 
                           connectionType,
                           domain, fullPath];
    //create APIConnection with provided URL
    HealthyAPIConnection *connection;
    connection = [HealthyAPIConnection requestWithURL:urlString 
        delegate:self requestType:requestType responseType:responseType] ;
 
    //configure connection with params and method
    connection.httpMethod = method;
    connection.shouldHandleCookies = YES;
    connection.cachePolicy = cachePolicy;
    
    
    // Set the request parameters if this is a POST request.
    BOOL isPOST = (method && [method isEqualToString:HTTP_POST_METHOD]);
    if (isPOST) {
        [connection.parameters setDictionary:params];       
    }
   
    
    //set up response
    
    id<TTURLResponse> response = [[TTURLJSONResponse alloc] init];
    connection.response = response;
    TT_RELEASE_SAFELY(response);  
    
    

    
    //done connection, now add connection into connection pool and release it
    if (!connection) {
        return nil;
    } else {
        [_connections setObject:connection forKey:[connection identifier]];
    }
    
    [connection send];

    return [connection identifier];
}

#pragma mark -
#pragma mark HealthyAPIConnection Delegate


/**
 * The request has loaded data and been processed into a response.
 *
 * If the request is served from the cache, this is the only delegate method that will be called.
 */
- (void)requestDidFinishLoad:(HealthyAPIConnection *) connection
{

    //now handle data

    TTURLJSONResponse *response = connection.response;
    TTDASSERT([response.rootObject isKindOfClass:[NSDictionary class]]);
    
    if (response) {
        //if api call fails
        //NSLog(@"%@",[[response rootObject] valueForKey:@"success"]);
        
        if(![[[response rootObject] valueForKey:@"success"] boolValue]){
            NSString* errormsg = [NSString stringWithFormat:@"%@",[[response rootObject] valueForKey:@"error"]];
            NSString* status = [NSString stringWithFormat:@"%@",[[response rootObject] valueForKey:@"status"]];
            //NSLog(@"%@ %@",status,errormsg);
            if ([self _isValidDelegateForSelector:@selector(apiFail:withStatus:withErrorMsg:)])
                [_delegate apiFail:connection withStatus:status withErrorMsg:errormsg];

        }
        //now we could notify receiver to parse result
        else {
            if ([self _isValidDelegateForSelector:@selector(apiSucceeded:withResult:)])
                [_delegate apiSucceeded:connection withResult:[[response rootObject] valueForKey:@"result"]];
                
        }

    }
}



/**
 * The request has begun loading.
 */
- (void)requestDidStartLoad:(HealthyAPIConnection *) connection
{
    // Inform delegate.
	if ([self _isValidDelegateForSelector:@selector(requestLoading:)])
		[_delegate requestLoading:connection];

}



/**
 * The request failed to load.
 */
- (void)request:(HealthyAPIConnection *) connection didFailLoadWithError:(NSError*)error
{
    // Inform delegate.
	if ([self _isValidDelegateForSelector:@selector(requestFailed:withError:)])
		[_delegate requestFailed:connection withError:error];
}

/**
 * The request was canceled.
 */
- (void)requestDidCancelLoad:(HealthyAPIConnection *) connection 
{
    if ([self _isValidDelegateForSelector:@selector(connectionFinished)])
		[_delegate connectionFinished];
}



#pragma mark -
#pragma mark API methods

- (void)loginWithUsername:(NSString *) username withPassword:(NSString *) password
{
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:0];
    [params setObject:username forKey:@"username"];
    [params setObject:password forKey:@"password"];
    [self _sendRequestWithMethod:HTTP_POST_METHOD  
                            path:@"login/" 
                            queryParameters:nil 
                            postparams:params
                            requestType:HealthyAPILoginSend 
                            responseType:HealthyAPILoginSendResponse
                            cachePolicy:TTURLRequestCachePolicyNone];

}

- (void)getUserProfile:(NSString *) username
{
    NSMutableDictionary *query = [NSMutableDictionary dictionaryWithCapacity:0];
    [query setObject:username forKey:@"username"];
    [self _sendRequestWithMethod:HTTP_GET_METHOD  
                            path:@"people/profile/" 
                 queryParameters:query
                      postparams:nil
                     requestType:HealthyAPILoginSend 
                    responseType:HealthyAPILoginSendResponse
                    cachePolicy:TTURLRequestCachePolicyNone];
}


- (void)createFoodLog:(NSDictionary *)params
{
    [self _sendRequestWithMethod:HTTP_POST_METHOD  
                            path:@"foodlogs/create/" 
                 queryParameters:nil 
                      postparams:params
                     requestType:HealthyAPILoginSend 
                    responseType:HealthyAPILoginSendResponse
                    cachePolicy:TTURLRequestCachePolicyDefault];
}


@end

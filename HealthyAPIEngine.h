//
//  HealthyAPIEngine.h
//  healthy-iosapp
//
//  Created by Feng Gao on 11-3-15.
//  Copyright 2011 hciatsoton. All rights reserved.
//


//The design of this apiengine is inspired by MGTwitterEngine.  

#import "HealthyAPIGlobalHeader.h"
#import "HealthyAPIEngineDelegate.h"


@interface HealthyAPIEngine : NSObject {
    __weak NSObject <HealthyAPIEngineDelegate> *_delegate;
    NSMutableDictionary *_connections;   //connection pool to maintain multiple API calls on by APIENGINE instance
	NSString *_APIDomain;
}


#pragma mark Class management

// Constructors
+ (HealthyAPIEngine *)APIEngineWithDelegate: (id) delegate;
- (HealthyAPIEngine *)initWithDelegate:(id) delegate;

// Configuration and Accessors
+ (NSString *)username;
+ (NSString *)password;
+ (void)setUsername:(NSString *)newUsername password:(NSString *)newPassword remember:(BOOL)storePassword;
+ (void)forgetPassword;
+ (void)remindPassword;

- (NSString *)APIDomain;
- (void)setAPIDomain:(NSString *)domain;
- (void)removeDelegate;


// Connection methods
- (int)numberOfConnections;
- (NSArray *)connectionIdentifiers;
- (void)closeConnection:(NSString *)identifier isFinished:(BOOL) finished;
- (void)closeAllConnections:(BOOL) finished;

#pragma mark API methods

//add api call here

- (void)loginWithUsername:(NSString *) username withPassword:(NSString *) password;

- (void)getUserProfile:(NSString *) username;

- (void)createFoodLog:(NSDictionary *)params;

@end


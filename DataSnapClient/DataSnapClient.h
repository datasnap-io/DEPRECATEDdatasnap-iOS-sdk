//  DataSnapClient.h
//  Copyright (c) 2014 Datasnap.io. All rights reserved.
//

#import <Foundation/Foundation.h>

// Object to capture any properties of the DataSnap Client
@interface DataSnapSystemData : NSObject

/**
 Creates an instance of a configuration given the cliend ID string
 @param clientID Client Identification string
 @return instance of a DataSnapClientConfiguration
*/
+ (instancetype)configurationWithClientID:(NSString *)clientID;

@end


@interface DataSnapClient : NSObject

/**
 Configure singleton DataSnapClient instance
 @param configuration DataSnapClientConfiguration defining configuration for the DataSnapClient instance
*/
+ (void)setupWithConfiguration:(DataSnapSystemData *)configuration;

/**
 Record an event
 @param event NSString, event name
 @param details NSDictionary, dictionary of any metadata the user wants to include with the event
*/
- (void)record:(NSString *)event;
- (void)record:(NSString *)event details:(NSDictionary *)details;

// This shouldn't be public
///**
// Creates and returns a DataSnapClient instance
// @param configuration DataSnapConfiguration defining configuration
//*/
//- (instancetype)initWithConfiguration:(DataSnapSystemData *)configuration;

+ (instancetype)singleClient;

@end

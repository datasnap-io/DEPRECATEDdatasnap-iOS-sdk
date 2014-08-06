#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface DataSnapClient : NSObject <CLLocationManagerDelegate>

/**
 Create a sinlge instance of a DataSnapClient for the project with a project ID
 provided by DataSnap.io
 */
+ (void)setupWithProjectID:(NSString *)projectID;

/**
 Enable/disable logging.
 */
+ (void)enableLogging;
+ (void)disableLogging;
+ (BOOL)isLoggingEnabled;

///**
// Enable/disable the use of location services
// */
//+ (void)enableLocation;
//+ (void)disableLocation;

/**
 Flush all events from queue
 */
- (void)flushEvents;

/**
 Return (NSArray) current event queue
 */
-(NSArray *)getEventQueue;

/**
 Record beacon event
 */
- (void)beaconEvent:(NSObject *)event;
- (void)beaconEvent:(NSObject *)event properties:(NSDictionary *)properties;

/**
 Return client for project
 */
+ (id)sharedClient;

/**
 Register 3rd Party Integration
 */
+ (void)registerIntegration:(id)integration withIdentifier:(NSString *)name;

+ (NSDictionary *)registeredIntegrations;

@end

/**
 DSLog macro
 */
#define DSLog(message, ...)if([DataSnapClient isLoggingEnabled]) NSLog(message, ##__VA_ARGS__)
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

/**
 Enable/disable the use of location services
 */
+ (void)enableLocation;
+ (void)disableLocation;

/**
 Flush all events from queue
 */
- (void)flushEvents;

/**
 Return (NSArray) current event queue
 */
-(NSArray *)getEventQueue;

/**
 Record an event with optional details
*/
- (void)record:(NSString *)event;
- (void)record:(NSString *)event details:(NSDictionary *)details;

/**
 Return client for project
 */
+ (instancetype)client;

/**
 DSLog macro
 */
#define DSLog(message, ...)if([DataSnapClient isLoggingEnabled]) NSLog(message, ##__VA_ARGS__)

@end

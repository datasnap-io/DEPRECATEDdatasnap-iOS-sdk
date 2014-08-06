#import "DataSnapClient.h"
#import "DataSnapEventQueue.h"
#import <UIKIT/UIDevice.h>
#import "GlobalUtilities.h"
#import "DataSnapIntegration.h"
#import "DataSnapGimbleIntegration.h"
#import "DataSnapIntegrations.h"

#define GIMBLE_ANALYTICS

static DataSnapClient *__sharedInstance = nil;
static NSMutableDictionary *__registeredIntegrationClasses = nil;
static BOOL loggingEnabled = YES;
const int eventQueueSize = 5;
static NSString *__projectID;

@implementation NSMutableDictionary (AddNonNils)

- (void)addNonNilObject:(NSObject *)obj {
    if(!obj) {
        [self addNonNilObject:obj];
    }
}

@end

@interface DataSnapClient ()

/**
 Prive properties and methods
 */

// Integrations
@property NSMutableArray *integrations;

// DataSnapEventQueue instance
@property DataSnapEventQueue *eventQueue;

// Check if queue is full
- (void)checkQueue;

// Send events to server
- (void)sendEvents:(NSObject *)events;

@end


@implementation DataSnapClient

+ (void)setupWithProjectID:(NSString *)projectID {
    // Singleton DataSnapClient
    static dispatch_once_t onceToken = 0;
    dispatch_once(&onceToken, ^{
        __sharedInstance = [[self alloc] initWithProjectID:projectID];
    });
}

- (id)initWithProjectID:(NSString *)projectID {
    if(self = [self init]) {
        __projectID = projectID;
        self.eventQueue = [[DataSnapEventQueue alloc] initWithSize:eventQueueSize];
    }
    return self;
}

+ (void)disableLogging {
    loggingEnabled = NO;
}

+ (void)enableLogging {
    loggingEnabled = YES;
}

+ (BOOL)isLoggingEnabled {
    return loggingEnabled;
}

- (void)flushEvents {
    [self.eventQueue flushQueue];
}

-(NSArray *)getEventQueue {
    return [self.eventQueue getEvents];
}

- (void)beaconEvent:(NSObject *)event {
    [self beaconEvent:event properties:nil];
}

- (void)beaconEvent:(NSObject *)event properties:(NSDictionary *)properties {
    for(Class integration in __registeredIntegrationClasses) {
        [[[[self class] registeredIntegrations][integration] class] beaconEvent:event properties:properties];
    }
}

+ (id)sharedClient {
    return __sharedInstance;
}

- (void)checkQueue {
    // If queue is full, send events and flush queue
    if(self.eventQueue.numberOfQueuedEvents >= self.eventQueue.queueLength) {
        DSLog(@"Queue is full. %d will be sent to service and flushed.", (int) self.eventQueue.numberOfQueuedEvents);
        [self sendEvents:self.eventQueue.getEvents];
        [self flushEvents];
    }
}


// TODO: Lots of configuration hard-coded in this method
// Method is too long
- (void)sendEvents:(NSObject *)events {
    
    NSString *json = [GlobalUtilities jsonStringFromObject:events];
    
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://10.0.0.3:3000"]];
    [urlRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [urlRequest setHTTPMethod:@"POST"];
    [urlRequest setHTTPBody:[json dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSHTTPURLResponse *res = nil;
    NSError *err = nil;
    DSLog(@"About to send request to %@.\n",urlRequest.URL);
    [NSURLConnection sendSynchronousRequest:urlRequest returningResponse:&res error:&err];
    NSInteger responseCode = [res statusCode];
    if((responseCode/100) != 2){
        DSLog(@"Error sending request to %@. Response code: %d.\n", urlRequest.URL, (int) responseCode);
        if(err){
            DSLog(@"%@\n", err.description);
        }
    }
    else {
        DSLog(@"Request successfully sent to %@.\nStatus code: %d.\nData Sent: %@.\n", urlRequest.URL, (int) responseCode, json);
    }
}

+ (NSDictionary *)registeredIntegrations {
    return [__registeredIntegrationClasses copy];
}

+ (void)registerIntegration:(id)integration withIdentifier:(NSString *)name {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __registeredIntegrationClasses = [[NSMutableDictionary alloc] init];
    });
    
    __registeredIntegrationClasses[name]= integration;
    
}


@end


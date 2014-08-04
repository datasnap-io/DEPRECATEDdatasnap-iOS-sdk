#import "DataSnapClient.h"
#import "DataSnapEventQueue.h"
#import <UIKIT/UIDevice.h>
#import "GlobalUtilities.h"
#import "DSDictionary.h"
#import "DataSnapIntegration.h"

static DataSnapClient *__singleClient = nil;
static NSMutableDictionary *__registeredIntegrations = nil;
//static BOOL locationEnabled = NO;
static BOOL loggingEnabled = YES;
const int eventQueueSize = 5;

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

// Data that you want to send with each request. (Example, device identifiers)
@property DSDictionary *globalData;

// Integrations
@property NSMutableArray *integrations;

// DataSnapEventQueue instance
@property DataSnapEventQueue *eventQueue;

// Project Identifier, provided by DataSnap
@property NSString *projectID;

// Global data from device
- (DSDictionary *)getDefaultGlobalData;

// Check if queue is full
- (void)checkQueue;

// Send events to server
- (void)sendEvents:(NSObject *)events;

//// Location Manager
//@property (nonatomic, strong) CLLocationManager *locationManager;
//- (void) getCurrentLocation;
//- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation;

@end


@implementation DataSnapClient

+ (void)setupWithProjectID:(NSString *)projectID {
    // Singleton DataSnapClient
    static dispatch_once_t onceToken = 0;
    dispatch_once(&onceToken, ^{
        __singleClient = [[self alloc] initWithProjectID:projectID];
    });
}

- (id)initWithProjectID:(NSString *)projectID {
    if(self = [self init]) {
        self.globalData = [self getDefaultGlobalData];
        self.projectID = projectID;
        self.eventQueue = [[DataSnapEventQueue alloc] initWithSize:eventQueueSize];
    }
    return self;
}

+ (void)registerIntegration:(Class)integrationClass withIdentifier:(NSString *)identifer {
    static dispatch_once_t onceToken = 0;
    dispatch_once(&onceToken, ^{
        __registeredIntegrations = [[NSMutableDictionary alloc] init];
    });
    
    __registeredIntegrations[identifer] = integrationClass;
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

//+ (void)enableLocation {
//    DSLog(@"Enabling Location");
//    locationEnabled = YES;
//}
//
//+ (void)disableLocation {
//    DSLog(@"Disabling Location");
//    locationEnabled = NO;
//}

- (void)flushEvents {
    [self.eventQueue flushQueue];
}

-(NSArray *)getEventQueue {
    return [self.eventQueue getEvents];
}

- (void)record:(NSString *)event {
    [self record:event details:nil];
}

- (void)record:(NSString *)event details:(NSDictionary *)details {
    
//    // Merge global data with event details
//    NSMutableDictionary *withDeviceData = [self.globalData mutableDictionaryCopy];
//    [withDeviceData  addEntriesFromDictionary:details];
//    
//    // Add event to queue
//    [self.eventQueue recordEvent:event details:withDeviceData];
//    
//    // Check if the queue is full
//    [self checkQueue];
    
    [self callIntegrationsWithSelector:_cmd arguments:@[event, details]];
}

- (void)callIntegrationsWithSelector:(SEL)selector arguments:(NSArray *)arguments {
    if (self.integrations.count == 0)
        DSLog(@"Warning: No integrations found.");
    
    for (id<DataSnapIntegration> integration in self.integrations)
        if([integration respondsToSelector:selector]) {
            NSInvocation *invocation = [self invocationForSelector:selector arguments:arguments];
            [invocation invokeWithTarget:integration];
        }
}

- (NSInvocation *)invocationForSelector:(SEL)selector arguments:(NSArray *)arguments {
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[SEGAnalyticsIntegration instanceMethodSignatureForSelector:selector]];
    invocation.selector = selector;
    for (int i=0; i < arguments.count; i++) {
        id argument = (arguments[i] == [NSNull null]) ? nil : arguments[i];
        [invocation setArgument:&argument atIndex:i+2];
    }
    return invocation;
}

+ (instancetype)client {
    return __singleClient;
}

- (DSDictionary *)getDefaultGlobalData{
    DSDictionary *globalData = [DSDictionary new];
    [globalData addSystemData];
    [globalData addCarrierData];
    [globalData addIPAddress];
    [globalData addBluetoothData];
    return globalData;
}

- (void)checkQueue {
    // If queue is full, send events and flush queue
    if(self.eventQueue.numberOfQueuedEvents >= self.eventQueue.queueLength) {
        DSLog(@"Queue is full. %d will be sent to service and flushed.", (int) self.eventQueue.numberOfQueuedEvents);
        [self sendEvents:self.eventQueue.getEvents];
        [self flushEvents];
    }
}

//- (void) getCurrentLocation {
//    if (locationEnabled) {
//        DSLog(@"Using location services");
//        if (!_locationManager && [CLLocationManager locationServicesEnabled]) {
//            _locationManager = [CLLocationManager new];
//            _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
//            _locationManager.delegate = self;
//        }
//    }
//}

//- (void)locationManager:(CLLocationManager *)manager
//    didUpdateToLocation:(CLLocation *)newLocation
//           fromLocation:(CLLocation *)oldLocation {
//    
//}



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

@end


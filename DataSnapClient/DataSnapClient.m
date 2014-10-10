#import "DataSnapClient.h"
#import "DataSnapEventQueue.h"
#import <UIKIT/UIDevice.h>
#import "GlobalUtilities.h"
#import "DataSnapIntegration.h"
#import "DataSnapIntegrations.h"
#import "DataSnapRequest.h"

static DataSnapClient *__sharedInstance = nil;
static NSMutableDictionary *__registeredIntegrationClasses = nil;
const int eventQueueSize = 100;
static NSString *__organizationID;
static BOOL loggingEnabled = NO;

@interface DataSnapClient ()

/**
 Private properties and methods
 */

// Integrations
@property NSMutableArray *integrations;

// DataSnapEventQueue instance
@property DataSnapEventQueue *eventQueue;

@property DataSnapRequest *requestHandler;

// Check if queue is full
- (void)checkQueue;

@end


@implementation DataSnapClient

+ (void)addIDFA:(NSString *)idfa {
    [GlobalUtilities addIDFA:idfa];
}

+ (void)setupWithOrganizationID:(NSString *)organizationID APIKey:(NSString *)APIKey APISecret:(NSString *)APISecret{
    // Singleton DataSnapClient
    static dispatch_once_t onceToken = 0;
    dispatch_once(&onceToken, ^{
        __sharedInstance = [[self alloc] initWithOrganizationID:organizationID APIKey:APIKey APISecret:APISecret];
    });
}

- (id)initWithOrganizationID:(NSString *)organizationID APIKey:(NSString *)APIKey APISecret:(NSString *)APISecret{
    if(self = [self init]) {
        __organizationID = organizationID;
        NSData *authData = [[NSString stringWithFormat:@"%@:%@", APIKey, APISecret] dataUsingEncoding:NSUTF8StringEncoding];
        NSString *authString = [authData base64EncodedStringWithOptions:0];
        self.eventQueue = [[DataSnapEventQueue alloc] initWithSize:eventQueueSize];
        self.requestHandler = [[DataSnapRequest alloc] initWithURL:@"https://api-events.datasnap.io/v1.0/events" authString:authString];
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

- (void)locationEvent:(NSObject *)event {
    [self locationEvent:event details:nil];
}

- (void)locationEvent:(NSObject *)event details:(NSDictionary *)details {
    for(Class integration in __registeredIntegrationClasses) {
        [self.eventQueue recordEvent:[[[[self class] registeredIntegrations][integration] class] locationEvent:event details:details org:__organizationID]];
    }
    
    [self checkQueue];
}


- (void)genericEvent:(NSDictionary *)eventDetails {
    
    NSMutableDictionary *eventData = [[NSMutableDictionary alloc] initWithDictionary:[DataSnapIntegration getUserAndDataSnapDictionaryWithOrg:__organizationID]];
    eventData[@"other"] = eventDetails;
    [self.eventQueue recordEvent:eventDetails];
}

+ (id)sharedClient {
    return __sharedInstance;
}

- (void)checkQueue {
    // If queue is full, send events and flush queue
    if(self.eventQueue.numberOfQueuedEvents >= self.eventQueue.queueLength) {
        DSLog(@"Queue is full. %d will be sent to service and flushed.", (int) self.eventQueue.numberOfQueuedEvents);
        [self.requestHandler sendEvents:self.eventQueue.getEvents];
        [self flushEvents];
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

#pragma mark - DataSnapUID

+ (NSString *)getDataSnapID {

    
    return @"TODO: this";
}

@end


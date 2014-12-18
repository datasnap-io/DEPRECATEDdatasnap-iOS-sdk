#import "DataSnapIntegration.h"
#import "GlobalUtilities.h"
#import "DataSnapLocation.h"
#import "DataSnapClient.h"
#import "DataSnapEventQueue.h"
#import "DataSnapRequest.h"
#import "DataSnapGimbleIntegration.h"
#import <objc/runtime.h>

static DataSnapClient *__sharedInstance = nil;
static NSMutableDictionary *__registeredIntegrationClasses = nil;
const int eventQueueSize = 100;
static NSString *__organizationID;
static NSString *__projectID;
static BOOL loggingEnabled = NO;

DataSnapRequest *requestHandler;

@interface DataSnapClient ()

// Integrations
@property NSMutableArray *integrations;

@property DataSnapEventQueue *eventQueue;

- (void)checkQueue;

@end


@implementation DataSnapClient

+ (void)addIDFA:(NSString *)idfa {
    [GlobalUtilities addIDFA:idfa];
}

+ (void)setupWithOrgAndProjIDs:(NSString *)organizationID projectId:(NSString *)projectID APIKey:(NSString *)APIKey APISecret:(NSString *)APISecret{    // Singleton DataSnapClient
    static dispatch_once_t onceToken = 0;
    dispatch_once(&onceToken, ^{
        __sharedInstance = [[self alloc] initWithOrgandProjIDs:organizationID projectId:(NSString *)projectID APIKey:APIKey APISecret:APISecret];
    });
}

- (instancetype)initWithOrgandProjIDs:(NSString *)organizationID projectId:(NSString *)projectID APIKey:(NSString *)APIKey APISecret:(NSString *)APISecret{
    if(self = [self init]) {
        __organizationID = organizationID;
        __projectID= projectID;
        NSData *authData = [[NSString stringWithFormat:@"%@:%@", APIKey, APISecret] dataUsingEncoding:NSUTF8StringEncoding];
        NSString *authString = [authData base64EncodedStringWithOptions:0];
        self.eventQueue = [[DataSnapEventQueue alloc] initWithSizeAndProject:eventQueueSize projectId:__projectID];
        requestHandler = [[DataSnapRequest alloc] initWithURL:@"https://api-events-staging.datasnap.io/v1.0/events" authString:authString];
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
        NSDictionary *eventData = [[[[self class] registeredIntegrations][integration] class] locationEvent:event details:details org:__organizationID proj:__projectID];
        NSMutableDictionary * eventDataFinal =[eventData mutableCopy];
        NSDictionary *event = [NSDictionary dictionaryWithObjectsAndKeys:@"first view", @"view_name",
                                                                         @"leaving from", @"action", nil];

        DataSnapLocation * locationService = [DataSnapLocation sharedInstance];
        NSMutableDictionary * global_position =  [locationService getGeoPosition];
        eventDataFinal[@"global_position"] = global_position[@"global_position"];
        // create adapter to add to queue and serialize  [eventStore addEvent:jsonData collection: eventCollection];
      [self.eventQueue recordEvent:eventDataFinal ];
    }
    [self.eventQueue checkQueue];
}


- (void)datasnapEvent:(NSDictionary *)userDetails communicationDetails:(NSDictionary *)communicationDetails campaignDetails:(NSDictionary *)campaignDetails
      geofenceDetails:(NSDictionary *)geofenceDetails globalpositionDetails:(NSDictionary *)globalpositionDetails placeDetails:(NSDictionary *)placeDetails
          beaconDetails:(NSDictionary *)beaconDetails{
    NSMutableDictionary *eventData = [[NSMutableDictionary alloc] initWithDictionary:[DataSnapIntegration getUserAndDataSnapDictionaryWithOrgAndProj:__organizationID projId:__projectID]];
    // allow user to overwrite anything that we set by default.
    // These keys and the data structures underneath should match this specification: http://docs.datasnapio.apiary.io/
    if (geofenceDetails) eventData[@"geo_fence"] = geofenceDetails;
    if (placeDetails) eventData[@"place"] = placeDetails;
    if (communicationDetails) eventData[@"communication"] = communicationDetails;
    if (campaignDetails) eventData[@"campaign"] = campaignDetails;
    if (globalpositionDetails) eventData[@"global_position"] = globalpositionDetails;
    if (beaconDetails) eventData[@"beacon"] = beaconDetails;
    [self.eventQueue recordEvent:eventData];
}

- (void)interactionEvent:(NSDictionary *)event {
    if (__registeredIntegrationClasses != nil)
        for (Class integration in __registeredIntegrationClasses) {
            [self.eventQueue recordEvent:[[[[self class] registeredIntegrations][integration] class] interactionEvent:event org:__organizationID proj:__projectID]];
        }
    [self.eventQueue checkQueue];
}

- (void)genericEvent:(NSDictionary *)eventDetails {
    
    NSMutableDictionary *eventData = [[NSMutableDictionary alloc] initWithDictionary:[DataSnapIntegration getUserAndDataSnapDictionaryWithOrgAndProj:__organizationID projId:__projectID]];
    eventData[@"other"] = eventDetails;
    [self.eventQueue recordEvent:eventDetails];
}

+ (id)sharedClient {
    return __sharedInstance;
}


- (void)interactionEvent:(NSDictionary *)event fromTap:(NSString *)tap {
    if(__registeredIntegrationClasses != nil)
        for(Class integration in __registeredIntegrationClasses) {
            // here there is a nil for interactionEvent details....
            [self.eventQueue recordEvent:[[[[self class] registeredIntegrations][integration] class] interactionEvent:event tap:tap org:__organizationID proj:__projectID]];
        }
    [self.eventQueue checkQueue];
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


- (NSMutableDictionary *)makeDictionaryMutable:(NSDictionary *)dict {
    return [dict mutableCopy];
}

- (NSMutableArray *)makeArrayMutable:(NSArray *)array {
    return [array mutableCopy];
}

- (DataSnapRequest *) getRequestHandler {
    return requestHandler;
}


@end


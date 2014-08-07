#import "DataSnapGimbleIntegration.h"
#import "DataSnapClient.h"
#import "GlobalUtilities.h"
#import <FYX/FYXTransmitter.h>

@implementation DataSnapGimbleIntegration

+ (void)load {
    [DataSnapClient registerIntegration:[self new] withIdentifier:@"Gimbal"];
}

- (id)init {
    if (self = [super init]) {
        self.name = @"Gimble";
    }
    
    return self;
}

+ (NSDictionary *)beaconEvent:(NSObject *)obj properties:(NSDictionary *)properties{
    
    if([obj isKindOfClass:[FYXVisit class]]) {
        
        NSMutableDictionary *eventData = [[NSMutableDictionary alloc] initWithDictionary:[self getUserAndDataSnapDictionary]];
        
        // Cast object to visit
        FYXVisit *visit = (FYXVisit *)obj;
        
        // Create dictionary from visit properties
        NSMutableDictionary *beacon= [[NSMutableDictionary alloc] initWithDictionary:[self dictionaryRepresentation:visit]];
        [beacon addEntriesFromDictionary:[self dictionaryRepresentation:visit.transmitter]];
        [beacon removeObjectForKey:@"transmitter"];
        beacon[@"hardware"] = @"Gimble";
        
        [self map:beacon withMap:@{@"identifier": @"id",
                                   @"battery": @"battery_level",
                                   @"dwellTime": @"dwell_time",
                                   @"lastUpdateTime": @"last_update_time",
                                   @"startTime": @"start_time"}];
        
        // handle NSDates
        [GlobalUtilities nsdateToNSString:beacon];
        
        [eventData addEntriesFromDictionary:@{@"event_type": @"beacon_sighting",
                                              @"beacon": beacon}];
        
//        NSString *json = [GlobalUtilities jsonStringFromObject:eventData];
        
        return eventData;
    }
    
    return NULL;
}

@end

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
    
    [self getUserAndDataSnapDictionary];
    
    if([obj isKindOfClass:[FYXVisit class]]) {
        
        // Cast object to visit
        FYXVisit *visit = (FYXVisit *)obj;
        
        // Create dictionary from visit properties
        NSMutableDictionary *beacon= [[NSMutableDictionary alloc] initWithDictionary:[self dictionaryRepresentation:visit]];
        [beacon addEntriesFromDictionary:[self dictionaryRepresentation:visit.transmitter]];
        [beacon removeObjectForKey:@"transmitter"];
        
        [self map:beacon withMap:@{}];
        
        return @{@"event_type": @"beacon_sighting",
                 @"beacon": beacon,
                 @"user": @{@"id": @"TODO"}};
    }
    
    return NULL;
}

@end

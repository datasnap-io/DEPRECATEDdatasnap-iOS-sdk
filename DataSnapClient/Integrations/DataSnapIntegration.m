#import "DataSnapIntegration.h"
#import "GlobalUtilities.h"
#import <objc/runtime.h>

@implementation DataSnapIntegration

+ (NSArray *)getBeaconKeys {
    return @[@"id",
             @"ble_uuid",
             @"ble_vender_uuid",
             @"blue_vender_id",
             @"rssi",
             @"previous_rssi",
             @"name",
             @"latitude",
             @"longitude",
             @"organization_ids",
             @"visibility",
             @"battery_level",
             @"hardware",
             @"categories",
             @"tags"];
}

+ (NSDictionary *)beaconEvent:(NSObject *)obj properties:(NSDictionary *)properties { return @{}; }

// map dictionaries keys using withWith:map
+ (NSDictionary *)map:(NSDictionary *)dictionary withMap:(NSDictionary *)map {
    
    NSMutableDictionary *mapped = [NSMutableDictionary new];

    for (NSString *key in map) {
        if ( map[key] ) {
            mapped[map[key]] = mapped[key];
        }
    }
    
    return mapped;
}

// return dictionary of an objects properties
+ (NSDictionary *)dictionaryRepresentation:(NSObject *)obj {
    
    unsigned int count = 0;
    // Get a list of all properties in the class.
    objc_property_t *properties = class_copyPropertyList([obj class], &count);
    
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] initWithCapacity:count];
    
    for (int i = 0; i < count; i++) {
        NSString *key = [NSString stringWithUTF8String:property_getName(properties[i])];
        NSString *value = [obj valueForKey:key];
        
        // Only add to the NSDictionary if it's not nil.
        if (value)
            [dictionary setObject:value forKey:key];
    }
    
    return dictionary;
}


+ (NSDictionary *)getUserAndDataSnapDictionary {
    NSMutableDictionary *data = [[GlobalUtilities getSystemData] copy];
    [data addNotNilEntriesFromDictionary:[GlobalUtilities getIPAddress]];
    [data addNotNilEntriesFromDictionary:[GlobalUtilities getCarrierData]];
                                 
    return data;
}

@end

@implementation NSMutableDictionary (AddNotNil)

- (void)addNotNilEntriesFromDictionary:(NSDictionary *)otherDictionary {
    if(otherDictionary) {
        [self addEntriesFromDictionary:otherDictionary];
    }
}

@end

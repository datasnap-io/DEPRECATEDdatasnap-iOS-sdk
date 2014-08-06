
@protocol DataSnapIntegration <NSObject>

+ (NSDictionary *)beaconEvent:(NSObject *)obj properties:(NSDictionary *)properties;


@end

@interface DataSnapIntegration : NSObject

+ (NSArray *)getBeaconKeys;

+ (NSDictionary *)map:(NSDictionary *)dictionary withMap:(NSDictionary *)map;

+ (NSDictionary *)dictionaryRepresentation:(NSObject *)obj;

+ (NSDictionary *)getUserAndDataSnapDictionary;

@end

@interface NSMutableDictionary (AddNotNil)

- (void)addNotNilEntriesFromDictionary:(NSDictionary *)otherDictionary;

@end

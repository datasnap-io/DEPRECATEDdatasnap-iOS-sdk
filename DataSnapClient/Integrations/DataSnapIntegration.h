#import <Foundation/Foundation.h>

@protocol DataSnapIntegration <NSObject>

+ (NSDictionary *)beaconEvent:(NSObject *)obj eventName:(NSString *)name;


@end

@interface DataSnapIntegration : NSObject

+ (NSDictionary *)map:(NSDictionary *)dictionary withMap:(NSDictionary *)map;

+ (NSDictionary *)dictionaryRepresentation:(NSObject *)obj;

+ (NSDictionary *)getUserAndDataSnapDictionary;

@end


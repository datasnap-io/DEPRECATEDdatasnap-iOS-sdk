#import <Foundation/Foundation.h>

@protocol DataSnapIntegration <NSObject>

+ (NSDictionary *)locationEvent:(NSObject *)obj details:(NSDictionary *)details;


@end

@interface DataSnapIntegration : NSObject

+ (NSDictionary *)map:(NSDictionary *)dictionary withMap:(NSDictionary *)map;

+ (NSDictionary *)dictionaryRepresentation:(NSObject *)obj;

+ (NSDictionary *)getUserAndDataSnapDictionary;

@end


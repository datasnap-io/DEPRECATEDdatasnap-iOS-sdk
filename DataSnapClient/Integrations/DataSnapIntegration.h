#import <Foundation/Foundation.h>

@protocol DataSnapIntegration <NSObject>

+ (NSDictionary *)locationEvent:(NSObject *)obj details:(NSDictionary *)details org:(NSString *)orgID;


@end

@interface DataSnapIntegration : NSObject

+ (NSDictionary *)map:(NSDictionary *)dictionary withMap:(NSDictionary *)map;

+ (NSDictionary *)dictionaryRepresentation:(NSObject *)obj;

+ (NSDictionary *)getUserAndDataSnapDictionaryWithOrg:(NSString *)orgID;

@end


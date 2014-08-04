#import <Foundation/Foundation.h>

@protocol DataSnapIntegration <NSObject>

- (NSString *)name;

- (void)recordEvent:(NSString *)event details:(NSDictionary *)details;

@end

@interface DataSnapIntegration : NSObject <DataSnapIntegration>

- (void)start;

@end
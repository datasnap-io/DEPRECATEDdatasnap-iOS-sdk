#import <Foundation/Foundation.h>

@interface GlobalUtilities : NSObject

// Serialize object into JSON string
+ (NSString *)jsonStringFromObject:(NSObject *)obj;
+ (NSString *)jsonStringFromObject:(NSObject *)obj prettyPrint:(BOOL)pretty;

@end

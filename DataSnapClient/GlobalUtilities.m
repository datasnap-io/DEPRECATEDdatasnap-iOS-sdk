#import "GlobalUtilities.h"

@implementation GlobalUtilities

+ (NSString *)jsonStringFromObject:(NSObject *)obj {
    return [self jsonStringFromObject:obj prettyPrint:NO];
}

+ (NSString *)jsonStringFromObject:(NSObject *)obj prettyPrint:(BOOL)pretty {
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:obj
                                                       options:(NSJSONWritingOptions) (pretty ? NSJSONWritingPrettyPrinted : 0)
                                                         error:&error];
    
    if (! jsonData) {
        NSLog(@"jsonStringFromObject: error: %@", error.localizedDescription);
        return @"{}";
    } else {
        return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
}

@end

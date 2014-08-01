//
//  JSONUtilities.m
//  DataSnapClient
//
//  Created by Mark Watson on 7/31/14.
//  Copyright (c) 2014 Datasnap.io. All rights reserved.
//

#import "JSONUtilities.h"

@implementation JSONUtilities

+ (NSString *)jsonString:(NSObject *)obj {
    return [self jsonString:obj prettyPrint:false];
}

+ (NSString *)jsonString:(NSObject *)obj prettyPrint:(BOOL)pretty {
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:obj
                                                       options:(NSJSONWritingOptions) (pretty ? NSJSONWritingPrettyPrinted : 0)
                                                         error:&error];
    
    if (! jsonData) {
        NSLog(@"bv_jsonStringWithPrettyPrint: error: %@", error.localizedDescription);
        return @"{}";
    } else {
        return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
}

@end

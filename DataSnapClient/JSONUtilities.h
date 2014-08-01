//
//  JSONUtilities.h
//  DataSnapClient
//
//  Created by Mark Watson on 7/31/14.
//  Copyright (c) 2014 Datasnap.io. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JSONUtilities : NSObject

+ (NSString *)jsonString:(NSObject *)obj;
+ (NSString *)jsonString:(NSObject *)obj prettyPrint:(BOOL)pretty;

@end

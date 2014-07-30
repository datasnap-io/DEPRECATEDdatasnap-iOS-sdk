//  DataSnapClient.h
//  Copyright (c) 2014 Datasnap.io. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (BVJSONString)
-(NSString*) bv_jsonStringWithPrettyPrint:(BOOL) prettyPrint;
@end

@interface DataSnapCleint : NSObject

@property NSMutableDictionary *defaultID;

- (void)registerInitialValuesForUserDefaults;

@end

//
//  DataSnapLocation.h
//  DataSnapClient
//
//  Created by Mark Watson on 8/15/14.
//  Copyright (c) 2014 Datasnap.io. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>

@interface DataSnapLocation : NSObject <CLLocationManagerDelegate>

/**
 * gets singleton object.
 * @return singleton
 */
+ (DataSnapLocation*)sharedInstance;

- (NSArray *)getLocation;

@end

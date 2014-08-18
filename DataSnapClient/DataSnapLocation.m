//
//  DataSnapLocation.m
//  DataSnapClient
//
//  Created by Mark Watson on 8/15/14.
//  Copyright (c) 2014 Datasnap.io. All rights reserved.
//

#import "DataSnapLocation.h"

@implementation DataSnapLocation

static DataSnapLocation *SINGLETON = nil;
static CLLocationManager *locationManager  = nil;

static bool isFirstAccess = YES;

#pragma mark - Public Method

+ (id)sharedInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        isFirstAccess = NO;
        SINGLETON = [[super allocWithZone:NULL] init];    
    });
    
    return SINGLETON;
}

#pragma mark - Life Cycle

+ (id) allocWithZone:(NSZone *)zone
{
    return [self sharedInstance];
}

+ (id)copyWithZone:(struct _NSZone *)zone
{
    return [self sharedInstance];
}

+ (id)mutableCopyWithZone:(struct _NSZone *)zone
{
    return [self sharedInstance];
}

- (id)copy
{
    return [[DataSnapLocation alloc] init];
}

- (id)mutableCopy
{
    return [[DataSnapLocation alloc] init];
}

- (id) init
{
    if(SINGLETON){
        return SINGLETON;
    }
    if (isFirstAccess) {
        [self doesNotRecognizeSelector:_cmd];
    }
    self = [super init];
    
    locationManager = [[CLLocationManager alloc]init]; // initializing locationManager
    locationManager.delegate = self; // we set the delegate of locationManager to self.
    locationManager.desiredAccuracy = kCLLocationAccuracyBest; // setting the accuracy
    
    [locationManager startUpdatingLocation];  //requesting location updates
    
    return self;
}


- (NSArray *)getLocation {
    return @[[NSString stringWithFormat:@"%f",locationManager.location.coordinate.latitude],
             [NSString stringWithFormat:@"%f",locationManager.location.coordinate.longitude]];
}

@end

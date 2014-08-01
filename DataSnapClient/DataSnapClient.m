//  DataSnapClient.m
//  Copyright (c) 2014 Datasnap.io. All rights reserved.
//

#import "DataSnapClient.h"
#import "DataSnapEventQueue.h"
#import "IPGetter.h"
#import <UIKIT/UIDevice.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <CoreTelephony/CTCarrier.h>
#import <AdSupport/ASIdentifierManager.h>
#import "JSONUtilities.h"

static DataSnapClient *__singleClient = nil;

@interface DataSnapSystemData ()

//// Client Identification string provided by DataSnap.io
@property (nonatomic) NSMutableDictionary *configuration;
@property (nonatomic) UIDevice *currentDevice;

@end


@implementation DataSnapSystemData

+ (instancetype)configurationWithClientID:(NSString *)clientID {
    return [[self alloc] initWithClientID:clientID];
}

///**
// Sets clientID property during initialization
// @param clientID Client Identification string
//*/
- (id)initWithClientID:(NSString *)clientID {
    if (self = [self init]) {
        self.configuration[@"clientID"] = clientID;
    }
    return self;
}

- (instancetype)init {
    if (self = [super init]) {
        
        self.currentDevice = [UIDevice currentDevice];
        
        self.configuration = [NSMutableDictionary new];
        
        // Append system-wide data (that won't change) to configuration
        [self addSystemInformation];
        [self addIPAddress];
        [self addCarrierInformation];
    }
    return self;
}

- (void)addSystemInformation {
    NSMutableDictionary *systemInfo = [NSMutableDictionary
                                       dictionaryWithDictionary:@{
                                                                  @"name": self.currentDevice.name,
                                                                  @"systemName": self.currentDevice.systemName,
                                                                  @"systemVersion": self.currentDevice.systemVersion,
                                                                  @"model": self.currentDevice.model,
                                                                  @"localizedModel": self.currentDevice.localizedModel,
                                                                  @"identifierForVendor": [self.currentDevice.identifierForVendor UUIDString],
                                                                  @"manufacturer": @"Apple"
                                                                  }];
    
    // Get Advertising ID if available
    if ([ASIdentifierManager class]){
        NSString *idfa = ASIdentifierManager.sharedManager.advertisingIdentifier.UUIDString;
        if (idfa.length){
            systemInfo[@"idfa"] = idfa;
        }
    }
    
    if(systemInfo){
        [self.configuration addEntriesFromDictionary:systemInfo];
    }
}

- (void)addIPAddress {
    IPGetter *ipGetter = [IPGetter new];
    NSString *ipAddresses = [ipGetter getIPAddress:true];
    if (ipAddresses.length) {
        self.configuration[@"ipAddress"] = ipAddresses;
    }
}

-(void) addCarrierInformation {
    CTCarrier *carrier = [[CTTelephonyNetworkInfo new] subscriberCellularProvider];
    if (carrier.carrierName.length) {
        [self.configuration addEntriesFromDictionary:[self getCarrierInfo:carrier]];
    }
}

- (NSDictionary *)getCarrierInfo:(CTCarrier *)carrier {
    NSDictionary *carrierInfo = @{
                                  @"carrierName": carrier.carrierName,
                                  @"isoCountryCode": carrier.isoCountryCode,
                                  @"mobileCountryCode": carrier.mobileCountryCode,
                                  @"mobileNetworkCode": carrier.mobileNetworkCode
                                  };
    return carrierInfo;
}

-(NSDictionary *)getSystemInformation {
    return self.configuration;
}

@end

@interface DataSnapClient ()

@property (nonatomic) DataSnapSystemData *configuration;
@property DataSnapEventQueue *eventQueue;

@end


@implementation DataSnapClient

+ (void)setupWithConfiguration:(DataSnapSystemData *)configuration {
    // Singleton DataSnapClient
    static dispatch_once_t onceToken = 0;
    dispatch_once(&onceToken, ^{
        __singleClient = [[self alloc] initWithConfiguration:configuration];
    });
}

- (void)record:(NSString *)event {
    [self record:event details:nil];
}

// for now only record one event, future allow batching
- (void)record:(NSString *)event details:(NSDictionary *)details {
    NSParameterAssert(event.length > 0);
    
    NSMutableDictionary *withDeviceData = [self.configuration.getSystemInformation mutableCopy];
    [withDeviceData  addEntriesFromDictionary:details];
    
    [self.eventQueue queueEvent:event details:withDeviceData withTimestamp:false];
    
    [self checkQueue];
}

- (void)checkQueue {
    // If queue is full, send events and flush queue
    if(self.eventQueue.getCurrentSize >= self.eventQueue.maxSize) {
        
#if( DEBUG )
        NSLog(@"Queue is full. %d will be sent to service and flushed.", (int) self.eventQueue.queue.count);
#endif
        [self sendEvents];
        [self.eventQueue flushQueue];
    }
}

- (id)initWithConfiguration:(DataSnapSystemData *)configuration {
    NSParameterAssert(configuration != nil);
    
    if (self = [super init]) {
        self.configuration = configuration;
        self.eventQueue = [[DataSnapEventQueue alloc] initWithSize:25];
    }
    
    return self;
}

+ (instancetype)singleClient {
    NSParameterAssert(__singleClient != nil);
    return __singleClient;
}

// TODO: Lots of configuration hard-coded in this method
// Pull out into config and grab when DataSnap Client is initialized
// Method is too long
- (void)sendEvents {
    
    NSString *json = [JSONUtilities jsonString:self.eventQueue.getEvents];
    
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://10.0.0.3:3000"]];
    [urlRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [urlRequest setHTTPMethod:@"POST"];
    [urlRequest setHTTPBody:[json dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSHTTPURLResponse *res = nil;
    NSError *err = nil;
    NSLog(@"About to send request to %@.\n",urlRequest.URL);
    [NSURLConnection sendSynchronousRequest:urlRequest returningResponse:&res error:&err];
    NSInteger responseCode = [res statusCode];
    if((responseCode/100) != 2){
        NSLog(@"Error sending request to %@. Response code: %d.\n", urlRequest.URL, (int) responseCode);
        if(err){
            NSLog(@"%@\n", err.description);
        }
    }
#if (DEBUG)
    else {
        NSLog(@"Request successfully sent to %@.\nStatus code: %d.\nData Sent: %@.\n", urlRequest.URL, (int) responseCode, json);
    }
#endif
}

@end

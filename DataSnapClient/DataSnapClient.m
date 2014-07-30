//  DataSnapInsights.m
//  Copyright (c) 2014 Datasnap.io. All rights reserved.
//

#import "DataSnapClient.h"
#import "IPGetter.h"
#import <UIKIT/UIDevice.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <CoreTelephony/CTCarrier.h>
#import <AdSupport/ASIdentifierManager.h>

#define TimeStamp [NSString stringWithFormat:@"%f",[[NSDate date] timeIntervalSince1970] * 1000]

@implementation NSDictionary (BVJSONString)

-(NSString*) bv_jsonStringWithPrettyPrint:(BOOL) prettyPrint {
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:self
                                                       options:(NSJSONWritingOptions)    (prettyPrint ? NSJSONWritingPrettyPrinted : 0)
                                                         error:&error];
    
    if (! jsonData) {
        NSLog(@"bv_jsonStringWithPrettyPrint: error: %@", error.localizedDescription);
        return @"{}";
    } else {
        return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
}
@end

@implementation DataSnapCleint

- (void)registerInitialValuesForUserDefaults {
    
    
    // Create a new dictionary to hold the default values to register
    NSMutableDictionary *defaultID = [NSMutableDictionary new];

    UIDevice *currentDevice = [UIDevice currentDevice];
    
    // Get device info
    defaultID[@"device"] = [NSMutableDictionary
                            dictionaryWithDictionary:@{
                                                       @"name": currentDevice.name,
                                                       @"systemName": currentDevice.systemName,
                                                       @"systemVersion": currentDevice.systemVersion,
                                                       @"model": currentDevice.model,
                                                       @"localizedModel": currentDevice.localizedModel,
                                                       @"identifierForVendor": [currentDevice.identifierForVendor UUIDString],
                                                       @"manufacturer": @"Apple"
                                                       }];
    
    // Get Advertising ID if available
    if ([ASIdentifierManager class]){
        NSString *idfa = ASIdentifierManager.sharedManager.advertisingIdentifier.UUIDString;
        if (idfa.length){
            defaultID[@"device"][@"idfa"] = idfa;
        }
    }
    
    // Get carrier info if available
    CTCarrier *carrier = [[CTTelephonyNetworkInfo new] subscriberCellularProvider];
    if (carrier.carrierName.length){
        defaultID[@"carrier"] = @{
                                  @"carrier": carrier.carrierName,
                                  @"isoCountryCode": carrier.isoCountryCode,
                                  @"mobileCountryCode": carrier.mobileCountryCode,
                                  @"mobileNetworkCode": carrier.mobileNetworkCode
                                  };
    }
    
    IPGetter *ipGetter = [IPGetter new];
    
    NSString *ipAddresses = [ipGetter getIPAddress:true];
    if (ipAddresses.length){
        defaultID[@"network"] = @{@"ipaddress": ipAddresses};
    }
    
    defaultID[@"timestamp"] = TimeStamp;
    
    NSString *json = [defaultID bv_jsonStringWithPrettyPrint:TRUE];
    
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://127.0.0.1:3000"]];
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
    else {
        NSLog(@"Request successfully sent to %@.\nStatus code: %d.\nData Sent: %@.\n", urlRequest.URL, (int) responseCode, json);
    }
}

@end

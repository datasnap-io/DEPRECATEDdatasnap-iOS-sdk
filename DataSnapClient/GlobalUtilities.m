#import "GlobalUtilities.h"
#import <AdSupport/ASIdentifierManager.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <CoreTelephony/CTCarrier.h>
#import <UIKit/UIDevice.h>
#import <CommonCrypto/CommonDigest.h>
#import "IPGetter.h"

static NSDictionary *__globalData;

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


+ (void)nsdateToNSString:(NSMutableDictionary *)dict {
    NSMutableDictionary *copy = [dict mutableCopy];
    
    for(NSString *key in dict) {
        if([dict[key] isKindOfClass:[NSDate class]]) {
            copy[key] = [dict[key] description];
        }
    }
    
    [dict removeAllObjects];
    [dict addEntriesFromDictionary:copy];
}

+ (NSDictionary *)getSystemData {
    
    // Set global data on first call, this will not change over time
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        UIDevice *device = [UIDevice currentDevice];
        NSMutableDictionary *data = [NSMutableDictionary new];
        
        data[@"name"] = [GlobalUtilities sha1:device.name];
        data[@"platform"] = device.systemName;
        data[@"os_version"] = device.systemVersion;
        data[@"model"] = device.model;
        data[@"localizedModel"] = device.localizedModel;
        data[@"vender_id"] = [device.identifierForVendor UUIDString];
        data[@"manufacturer"] = @"Apple";
        
        // Get Advertising ID if available
        if ([ASIdentifierManager class]){
            NSString *idfa = ASIdentifierManager.sharedManager.advertisingIdentifier.UUIDString;
            if (idfa.length){
                data[@"mobile_device_ios_idfa"] = idfa;
            }
        }
        __globalData = data;
    });
    
    return __globalData;
}

+ (NSDictionary *)getIPAddress {
    IPGetter *ipGetter = [IPGetter new];
    NSString *ipAddresses = [ipGetter getIPAddress:true];
    if (ipAddresses.length) {
        return @{@"ip_address": ipAddresses};
    }
    return NULL;
}

+ (NSDictionary *)getCarrierData {
    CTCarrier *carrier = [[CTTelephonyNetworkInfo new] subscriberCellularProvider];
    if (carrier.carrierName.length) {
        return @{@"carrier_name": carrier.carrierName,
                 @"iso_county_code": carrier.isoCountryCode,
                 @"country_code": carrier.mobileCountryCode,
                 @"network_code": carrier.mobileNetworkCode
                 };
    }
    return NULL;
}

+ (NSString *)sha1:(NSString *)str {
    NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
    uint8_t digest[CC_SHA1_DIGEST_LENGTH];
    
    CC_SHA1(data.bytes, data.length, digest);
    
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH * 2];
    
    for (int i = 0; i < CC_SHA1_DIGEST_LENGTH; i++)
    {
        [output appendFormat:@"%02x", digest[i]];
    }
    
    return output;
}

@end

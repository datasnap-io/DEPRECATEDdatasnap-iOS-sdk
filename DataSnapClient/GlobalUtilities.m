#import "GlobalUtilities.h"
#import <AdSupport/ASIdentifierManager.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <CoreTelephony/CTCarrier.h>
#import <UIKit/UIDevice.h>
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

+ (NSDictionary *)getSystemData {
    
    // Set global data on first call, this will not change over time
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        UIDevice *device = [UIDevice currentDevice];
        NSMutableDictionary *data = [NSMutableDictionary new];
        
        data[@"name"] = device.name;
        data[@"systemName"] = device.systemName;
        data[@"systemVersion"] = device.systemVersion;
        data[@"model"] = device.model;
        data[@"localizedModel"] = device.localizedModel;
        data[@"identifierForVendor"] = [device.identifierForVendor UUIDString];
        data[@"manufacturer"] = @"Apple";
        
        // Get Advertising ID if available
        if ([ASIdentifierManager class]){
            NSString *idfa = ASIdentifierManager.sharedManager.advertisingIdentifier.UUIDString;
            if (idfa.length){
                data[@"idfa"] = idfa;
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
        return @{@"ipAddress": ipAddresses};
    }
    return NULL;
}

+ (NSDictionary *)getCarrierData {
    CTCarrier *carrier = [[CTTelephonyNetworkInfo new] subscriberCellularProvider];
    if (carrier.carrierName.length) {
        return @{@"carrierName": carrier.carrierName,
                 @"isoCountyCode": carrier.isoCountryCode,
                 @"mobileCountyCode": carrier.mobileCountryCode,
                 @"mobileNetworkCode": carrier.mobileNetworkCode
                 };
    }
    return NULL;
}

@end

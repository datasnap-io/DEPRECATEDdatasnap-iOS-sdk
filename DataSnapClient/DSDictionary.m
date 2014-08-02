#import <AdSupport/ASIdentifierManager.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <CoreTelephony/CTCarrier.h>
#import <UIKit/UIDevice.h>
#import "DSDictionary.h"
#import "IPGetter.h"

@implementation DSDictionary

- (id) init {
    if (self = [super init]) {
        self.data = [NSMutableDictionary new];
    }
    return self;
}

- (void)addSystemData {
    
    UIDevice *device = [UIDevice currentDevice];
    
    NSMutableDictionary *systemInfo = [NSMutableDictionary
                                       dictionaryWithDictionary:@{
                                                                  @"name": device.name,
                                                                  @"systemName": device.systemName,
                                                                  @"systemVersion": device.systemVersion,
                                                                  @"model": device.model,
                                                                  @"localizedModel": device.localizedModel,
                                                                  @"identifierForVendor": [device.identifierForVendor UUIDString],
                                                                  @"manufacturer": @"Apple"
                                                                  }];
    
    // Get Advertising ID if available
    if ([ASIdentifierManager class]){
        NSString *idfa = ASIdentifierManager.sharedManager.advertisingIdentifier.UUIDString;
        if (idfa.length){
            systemInfo[@"idfa"] = idfa;
        }
    }
    
    [self.data addEntriesFromDictionary:systemInfo];
}

- (void)addIPAddress {
    IPGetter *ipGetter = [IPGetter new];
    NSString *ipAddresses = [ipGetter getIPAddress:true];
    if (ipAddresses.length) {
        self.data[@"ipAddress"] = ipAddresses;
    }
}

- (void)addCarrierData {
    CTCarrier *carrier = [[CTTelephonyNetworkInfo new] subscriberCellularProvider];
    if (carrier.carrierName.length) {
        [self.data addEntriesFromDictionary:[self getCarrierInfo:carrier]];
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

- (void)addBluetoothData {
    // TODO: Add Bluetooth Data
}

- (NSMutableDictionary *)mutableDictionaryCopy {
    return [self.data mutableCopyWithZone:NULL];
}

@end

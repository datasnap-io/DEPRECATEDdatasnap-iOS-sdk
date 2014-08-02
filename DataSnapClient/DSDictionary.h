#import <Foundation/Foundation.h>

@interface DSDictionary : NSObject

@property NSMutableDictionary *data;

- (void)addSystemData;
- (void)addIPAddress;
- (void)addCarrierData;
- (void)addBluetoothData;

- (NSMutableDictionary *)mutableDictionaryCopy;

@end

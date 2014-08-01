//  IPGetter.h
//

#import <Foundation/Foundation.h>

//Object for encapselating IP Address getter methods
@interface IPGetter : NSObject

/**
 Returns a string of the device IP Address
 @param preferIPv4 BOOL preferring IPv4 over IPv6
 @return NSString of the device's IP Address
*/
- (NSString *)getIPAddress:(BOOL)preferIPv4;

/**
 Returns a dictionary containing every network address associated with the device
 @return NSDictionary
*/
- (NSDictionary *)getIPAddresses;

@end

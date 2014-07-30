//  IPGetter.h
//  Copyright (c) 2014 Datasnap.io. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IPGetter : NSObject

- (NSString *)getIPAddress:(BOOL)preferIPv4;
- (NSDictionary *)getIPAddresses;

@end

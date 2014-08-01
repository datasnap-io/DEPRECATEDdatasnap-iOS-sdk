//  DataSnapEventQueue.h
//  Copyright (c) 2014 Datasnap.io. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DataSnapEventQueue : NSObject

// Number of events to queue
@property NSInteger maxSize;
@property NSMutableArray *queue;

- (id)initWithSize:(NSInteger)size;

- (NSInteger)getCurrentSize;

- (void)queueEvent:(NSString *)event details:(NSDictionary *)details;
- (void)queueEvent:(NSString *)event details:(NSDictionary *)details withTimestamp:(bool)withTimestamp;

- (void)flushQueue;

- (NSArray *)getEvents;

@end

//  DataSnapEventQueue.m
//  Copyright (c) 2014 Datasnap.io. All rights reserved.
//

#import "DataSnapEventQueue.h"

@interface DataSnapEventQueue ()

@property NSDictionary *deviceID;

@end

@implementation DataSnapEventQueue

- (id)initWithSize:(NSInteger)size{
    if (self = [self init]) {
        self.maxSize = size;
    }
    return self;
}

- (instancetype)init {
    if(self = [super init]) {
        self.queue = [NSMutableArray new];
    }
    return self;
}

-(NSInteger)getCurrentSize {
    return self.queue.count;
}


- (void)queueEvent:(NSString *)event details:(NSDictionary *)details {
    [self queueEvent:event details:details withTimestamp:true];
}

- (void)queueEvent:(NSString *)event details:(NSDictionary *)details withTimestamp:(bool)withTimestamp{
    
    NSMutableDictionary *currentEvent = [[NSMutableDictionary alloc] initWithDictionary:@{@"event": event}];
    
    // add timestamp
    if (withTimestamp) currentEvent[@"timestamp"] = [[NSDate new] description];
    
    // if there are details, add them
    if (details) currentEvent[@"details"] = details;
    
    [self.queue addObject:currentEvent];
    
    return;
}

// Called when queue is full
- (void)flushQueue {
    [self.queue removeAllObjects];
}

- (NSArray *)getEvents {
    return self.queue;
}

@end

#import "DataSnapEventQueue.h"

@interface DataSnapEventQueue ()

@property NSMutableArray *eventQueue;

@end

@implementation DataSnapEventQueue

- (id)initWithSize:(NSInteger)queueLength{
    if (self = [self init]) {
        self.queueLength = queueLength;
    }
    return self;
}

- (instancetype)init {
    if(self = [super init]) {
        self.eventQueue = [NSMutableArray new];
    }
    return self;
}

- (void)recordEvent:(NSString *)event {
    [self recordEvent:event details:nil];
}

- (void)recordEvent:(NSString *)event details:(NSDictionary *)details{
    
    NSMutableDictionary *currentEvent = [[NSMutableDictionary alloc] initWithDictionary:@{@"event": event}];
    
    // add timestamp
    currentEvent[@"timestamp"] = [[NSDate new] description];
    
    // if there are details, add them
    if (details) currentEvent[@"details"] = details;
    
    [self.eventQueue addObject:currentEvent];
    
    return;
}

- (NSArray *)getEvents {
    return self.eventQueue;
}

- (void)flushQueue {
    [self.eventQueue removeAllObjects];
}

-(NSInteger)numberOfQueuedEvents {
    return self.eventQueue.count;
}

@end

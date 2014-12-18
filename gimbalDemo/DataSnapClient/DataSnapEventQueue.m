#import "DataSnapEventQueue.h"
#import "DataSnapClient.h"
#import "OfflineEventStore.h"
#import "DataSnapRequest.h"

@interface DataSnapEventQueue ()

@property NSMutableArray *eventQueue;

@end

@implementation DataSnapEventQueue {
    id anError;
}

@synthesize anError;
static OfflineEventStore *eventStore;
DataSnapRequest *requestHandler;

- (id)initWithSizeAndProject:(NSInteger)queueLength projectId:(NSString*)__projectID{
    if (self = [self init]) {
        self.queueLength = queueLength;
        eventStore.projectId = __projectID;
        requestHandler = [[DataSnapClient sharedClient] getRequestHandler];

    }
    return self;
}

- (OfflineEventStore *) getEventStore {
    return eventStore;
}

- (void)clearAllEvents {
    [eventStore deleteAllEvents];
}

- (void)checkQueue {
    // If queue is full, send events and flush queue
    NSInteger *eventCount = (NSInteger) [eventStore getTotalEventCount];
    if(eventCount >= self.queueLength) {
        NSLog(@"Queue is full. %d will be sent to service and flushed.", (int) eventCount);
        [requestHandler sendEventsOfflineEventStore:eventStore];
        //[self.requestHandler sendEvents:self.eventQueue.getEvents];
        [[DataSnapClient sharedClient] flushEvents];
    }
}


- (BOOL)addEvent:(NSDictionary *)event toEventCollection:(NSString *)eventCollection error:(NSError **) anError {
    NSLog(@"Adding event to collection: %@", eventCollection);
    NSMutableDictionary *newEvent = [NSMutableDictionary dictionary];
    [newEvent addEntriesFromDictionary:event];
    event = newEvent;
    NSMutableDictionary *eventToWrite = [NSMutableDictionary dictionaryWithDictionary:event];
    NSError *error = nil;
    NSData *jsonData = [self serializeEventToJSON:eventToWrite error:&error];
    // write JSON to store
    [eventStore addEvent:jsonData collection: eventCollection];
    return YES;
}

- (id)handleInvalidJSONInObject:(id)value {
    if (!value) {
        return value;
    }
    if ([value isKindOfClass:[NSDictionary class]]) {
        NSMutableDictionary *mutDict = [self makeDictionaryMutable:value];
        NSArray *keys = [mutDict allKeys];
        for (NSString *dictKey in keys) {
            id newValue = [self handleInvalidJSONInObject:[mutDict objectForKey:dictKey]];
            [mutDict setObject:newValue forKey:dictKey];
        }
        return mutDict;
    } else if ([value isKindOfClass:[NSArray class]]) {
        // make sure the array is mutable and then recurse for every element
        NSMutableArray *mutArr = [self makeArrayMutable:value];
        for (NSUInteger i=0; i<[mutArr count]; i++) {
            id arrVal = [mutArr objectAtIndex:i];
            arrVal = [self handleInvalidJSONInObject:arrVal];
            [mutArr setObject:arrVal atIndexedSubscript:i];
        }
        return mutArr;
    } else if ([value isKindOfClass:[NSDate class]]) {
        return [self convertDate:value];
    } else {
        return value;
    }
}


- (id)convertDate:(id)date {
    NSString *string = [eventStore convertNSDateToISO8601:date];
    return string;
}


- (instancetype)init {
    if(self = [super init]) {
        self.eventQueue = [NSMutableArray new];
        eventStore = [[OfflineEventStore alloc] init];
    }
    return self;
}

- (void)recordEvent:(NSDictionary *)details{
    // TODO handle generic request data (like orgID) here
    [self addEvent:details toEventCollection:@"gimbalevents" error:nil];
    // write JSON to store
    return;
}

- (NSArray *)getEvents {
    return self.eventQueue;
}

- (NSArray *)serializeEventQueue {
    return self.eventQueue;
}

- (NSArray *)deserializeEventQueue {
    return self.eventQueue;
}


- (void)flushQueue {
    [eventStore deleteAllEvents];
    //[self.eventQueue removeAllObjects];
}

-(NSInteger)numberOfQueuedEvents {
    return self.eventQueue.count;
}


- (NSMutableDictionary *)makeDictionaryMutable:(NSDictionary *)dict {
    return [dict mutableCopy];
}

- (NSMutableArray *)makeArrayMutable:(NSArray *)array {
    return [array mutableCopy];
}

- (NSData *)serializeEventToJSON:(NSMutableDictionary *)event error:(NSError **) anError {
    id fixed = [self handleInvalidJSONInObject:event];
    if (![NSJSONSerialization isValidJSONObject:fixed]) {
     //   [self handleError:anError withErrorMessage:@"Event contains an invalid JSON type!"];
        return nil;
    }
    return [NSJSONSerialization dataWithJSONObject:fixed options:0 error:anError];
}

@end

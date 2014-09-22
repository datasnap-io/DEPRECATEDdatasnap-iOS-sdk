DataSnapClient
=================

An iOS SDK for [DataSnap.io](https://datasnap.io)

## Documentation

### Quickstart

1) Link DataSnapClient.framework to your project.
2) `#import "DataSnapClient/Client.h"` in your source
3) ```obj-c
[DataSnapClient setupWithOrganizationID:@""
                                     APIKey:@""
                                  APISecret:@""];
```

### Example Events
```obj-c
[[DataSnapClient sharedClient] genericEvent:@{@"key": @"value"}]

[[DataSnapClient sharedClient] locationEvent:(FYXVisit *)visit details:@{@"event_type": @"beacon_arrive"}]

[[DataSnapClient sharedClient] locationEvent:(QLPlaceEvent *)placeEvent details:@{@"name": @"Geofence Event"}]
```

## Development

During developtment, Gimbal's iOS SDK is required with the project structure:
```
root\
 DataSnapClient\
 Frameworks\
  Common.embeddedframework\
  ContextLocation.embeddedframework\
  NetworkServices.embeddedframework\
  ContextCore.embeddedframework\
  ContextProfiling.embeddedframework\
  FYX.framework
```
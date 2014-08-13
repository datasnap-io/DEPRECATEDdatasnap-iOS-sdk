#import <Foundation/Foundation.h>
#import <FYX/FYXVisit.h>
#import <FYX/FYXVisitManager.h>
#import "DataSnapIntegration.h"

@interface DataSnapGimbleIntegration : DataSnapIntegration <FYXVisitDelegate>

@property NSString *name;

+ (NSDictionary *)locationEvent:(FYXVisit *)obj details:(NSDictionary *)details;

@end

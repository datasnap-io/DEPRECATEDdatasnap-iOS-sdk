#import <Foundation/Foundation.h>
#import <FYX/FYXVisit.h>
#import <FYX/FYXVisitManager.h>
#import "DataSnapIntegration.h"

@interface DataSnapGimbleIntegration : DataSnapIntegration <FYXVisitDelegate>

@property NSString *name;

+ (NSDictionary *)communicationSentEvent:(NSDictionary *)details org:(NSString *)orgID proj:(NSString *)projID;
+ (NSDictionary *)locationEvent:(FYXVisit *)obj details:(NSDictionary *)details org:(NSString *)orgID proj:(NSString *)projID;
+ (NSDictionary *)interactionEvent:(FYXVisit *)obj details:(NSDictionary *)details org:(NSString *)orgID proj:(NSString *)projID status:(NSString *)status;
+ (NSDictionary *)interactionEvent:(NSDictionary *)details org:(NSString *)orgID proj:(NSString *)projID;
+ (NSDictionary *)interactionEvent:(NSDictionary *)details tap:(NSString *)tap org:(NSString *)orgID proj:(NSString *)projID status:(NSString *)status;


@end

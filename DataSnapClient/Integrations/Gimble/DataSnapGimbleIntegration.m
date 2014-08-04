#import "DataSnapGimbleIntegration.h"
#import "DataSnapClient.h"

@implementation DataSnapGimbleIntegration

+ (void) load {
    [DataSnapClient registerIntegration:self withName:@"Gimble"];
}

- (id)init {
    if (self = [super init]) {
        self.name = @"Gimble";
    }
    return self;
}

- (void) start {
    [DataSnapClient client];
}

- (void)recordEvent:(NSString *)event details:(NSDictionary *)details {
    
    
}

@end

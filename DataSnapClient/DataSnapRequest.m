#import "DataSnapRequest.h"
#import "GlobalUtilities.h"

@interface DataSnapRequest ()

@property NSString *url;

@end

@implementation DataSnapRequest

-(id)initWithURL:(NSString *)url {
    if(self = [super init]) {
        self.url = url;
    }
    
    return self;
}

-(void)sendObject:(NSObject *)obj {
    
    NSString *json = [GlobalUtilities jsonStringFromObject:obj];
    
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:self.url]];
    [urlRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [urlRequest setHTTPMethod:@"POST"];
    [urlRequest setHTTPBody:[json dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSHTTPURLResponse *res = nil;
    NSError *err = nil;
    [NSURLConnection sendSynchronousRequest:urlRequest returningResponse:&res error:&err];
    NSInteger responseCode = [res statusCode];
    if((responseCode/100) != 2){
        if(err){
            NSLog(@"%@\n", err.description);
        }
    }
    
}

@end

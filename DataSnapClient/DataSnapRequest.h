#import <Foundation/Foundation.h>

@interface DataSnapRequest : NSObject

-(id)initWithURL:(NSString *)url;

-(void)sendEvents:(NSObject *)events;

@end

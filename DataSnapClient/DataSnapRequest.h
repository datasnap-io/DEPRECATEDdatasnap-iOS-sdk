#import <Foundation/Foundation.h>

@interface DataSnapRequest : NSObject

-(id)initWithURL:(NSString *)url;

-(void)sendObject:(NSObject *)obj;

@end

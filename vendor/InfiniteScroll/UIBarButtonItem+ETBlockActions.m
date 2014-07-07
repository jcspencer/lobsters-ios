#import "UIBarButtonItem+ETBlockActions.h"
#import <objc/runtime.h>

@implementation UIBarButtonItem (ETBlockActions)

- (id) initWithTitle:(NSString *)title style:(UIBarButtonItemStyle)style eventHandler:(void(^)(void))handler {
    class_addMethod([self class], @selector(eventHandler), imp_implementationWithBlock((__bridge void *)(handler)), "v@:");
    
    return [self initWithTitle:title style:style target:self action:@selector(eventHandler)];
}

@end

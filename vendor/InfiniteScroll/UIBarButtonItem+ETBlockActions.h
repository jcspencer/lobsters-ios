#import <UIKit/UIKit.h>

@interface UIBarButtonItem (ETBlockActions)

- (id) initWithTitle:(NSString *)title style:(UIBarButtonItemStyle)style eventHandler:(void(^)(void))handler;

@end

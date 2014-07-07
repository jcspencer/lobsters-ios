/*
 * This file is part of the http://ioscodesnippet.com
 * (c) Jamz Tang <jamz@jamztang.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

// JTTargetActionBlock is built with ARC environment

#import <UIKit/UIKit.h>

typedef void(^UIControlEventHandler)(id sender, UIEvent *event);

@interface UIControl (JTTargetActionBlock)

- (void)addEventHandler:(UIControlEventHandler)handler forControlEvent:(UIControlEvents)controlEvent;
- (void)removeEventHandlersForControlEvent:(UIControlEvents)controlEvent;

@end

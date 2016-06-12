//
//  People.m
//  runtimeTest
//
//  Created by ian on 16/1/22.
//  Copyright © 2016年 ian. All rights reserved.
//

#import "People.h"

#if TARGET_IPHONE_SIMULATOR
#import <objc/objc-runtime.h>
#else
#import <objc/runtime.h>
#import <objc/message.h>
#endif


/**
 *  使用场景
 在一个函数找不到时，Objective-C提供了三种方式去补救：
 
 1、调用resolveInstanceMethod给个机会让类添加这个实现这个函数
 
 2、调用forwardingTargetForSelector让别的对象去执行这个函数
 
 3、调用methodSignatureForSelector（函数符号制造器）和forwardInvocation（函数执行器）灵活的将目标函数以其他形式执行。
 
 如果都不中，调用doesNotRecognizeSelector抛出异常。
 */


@implementation People

// 第一步：我们不动态添加方法，返回NO，进入第二步；
//这个函数在运行时(runtime)，没有找到SEL的IML时就会执行。如果实现了添加函数代码则返回YES，未实现返回NO
+ (BOOL)resolveInstanceMethod:(SEL)sel
{
    return NO;
}

// 第二部：我们不指定备选对象响应aSelector，流程到了这里，系统给了个将这个SEL转给其他对象的机会,进入第三步；
// 返回参数是一个对象，如果这个对象非nil、非self的话，系统会将运行的消息转发给这个对象执行
- (id)forwardingTargetForSelector:(SEL)aSelector
{
    return nil;
}
// 第三步：返回方法选择器，然后进入第四部；
// 这个函数和后面的forwardInvocation:是最后一个寻找IML的机会。这个函数让重载方有机会抛出一个函数的签名，再由后面的forwardInvocation:去执行。
- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector
{
    if ([NSStringFromSelector(aSelector) isEqualToString:@"sing"]) {
        return [NSMethodSignature signatureWithObjCTypes:"v@:"];
    }
    //如果还找不到，就去父类中找
    return [super methodSignatureForSelector:aSelector];
}

// 第四部：这步我们修改调用方法 相当于不执行原函数，执行新函数
// 真正执行从methodSignatureForSelector:返回的NSMethodSignature。在这个函数里可以将NSInvocation多次转发到多个对象中，这也是这种方式灵活的地方。（forwardingTargetForSelector只能以Selector的形式转向一个对象）
- (void)forwardInvocation:(NSInvocation *)anInvocation
{
    [anInvocation setSelector:@selector(dance)];
    // 这还要指定是哪个对象的方法
    [anInvocation invokeWithTarget:self];
}

// 若forwardInvocation没有实现，则会调用此方法
//作为找不到函数实现的最后一步，NSObject实现这个函数只有一个功能，就是抛出异常。
//虽然理论上可以重载这个函数实现保证不抛出异常（不调用super实现），但是苹果文档着重提出“一定不能让这个函数就这么结束掉，必须抛出异常”。
- (void)doesNotRecognizeSelector:(SEL)aSelector
{
    NSLog(@"消息无法处理：%@", NSStringFromSelector(aSelector));
}

- (void)dance
{
    NSLog(@"跳舞！！！come on！");
}

@end

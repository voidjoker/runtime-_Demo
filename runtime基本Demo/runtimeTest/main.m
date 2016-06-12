//
//  main.m
//  runtimeTest
//
//  Created by ian on 16/1/21.
//  Copyright © 2016年 ian. All rights reserved.
//

#import <Foundation/Foundation.h>
#if TARGET_IPHONE_SIMULATOR
#import <objc/objc-runtime.h>
#else
#import <objc/runtime.h>
#import <objc/message.h>
#endif


// 自定义一个方法
void sayFunction(id self, SEL _cmd, id some) {
    NSLog(@"%@岁的%@说：%@", object_getIvar(self, class_getInstanceVariable([self class], "_age")),[self valueForKey:@"name"],some);
}
int main(int argc, const char * argv[]) {
    @autoreleasepool {
        
        // 动态创建对象 创建一个Person 继承自 NSObject类
        //第一个参数是超类的类对象。第二个参数是新类的C字符串名。第三个和最后一个参数指定额外的分配字节，通常为0
        //关于第四个参数：如果变量类型为指针，则传入log2(sizeof(pointer_type))；其他类型传入sizeof(value_type)。
        Class People = objc_allocateClassPair([NSObject class], "Person", 0);
        // 为该类动态添加NSString *_name成员变量   第四个参数是对其方式，第五个参数是参数类型
        class_addIvar(People, "_name", sizeof(NSString*), log2(sizeof(NSString*)), @encode(NSString*));
        // 为该类添加int _age成员变量
        class_addIvar(People, "_age", sizeof(int), sizeof(int), @encode(int));
        // 注册方法名为say的方法
        SEL s = sel_registerName("say:");
        // 为该类增加名为say的方法
        //第四个参数types：一个定义该函数返回值类型和参数类型的字符串
        //v表示返回值类型void @表示参数id(self) :表示SEL(_cmd) @表示传入的参数
        class_addMethod(People, s, (IMP)sayFunction, "v@:@");
        // 注册该类
        objc_registerClassPair(People);
        
        // 创建一个类的实例
        id peopleInstance = [[People alloc] init];
        
        // KVC 动态改变 对象peopleInstance 中的实例变量
        [peopleInstance setValue:@"苍老师" forKey:@"name"];
        
        // 从类中获取成员变量Ivar
        Ivar ageIvar = class_getInstanceVariable(People, "_age");
        // 为peopleInstance的成员变量赋值
        object_setIvar(peopleInstance, ageIvar, @18);
        
        // 调用 peopleInstance 对象中的 s 方法选择器对应的方法
        // objc_msgSend(peopleInstance, s, @"大家好!"); // 这样写也可以，请看我博客说明
         ((void (*)(id, SEL, id))objc_msgSend)(peopleInstance, s, @"大家好");
        peopleInstance = nil; //当People类或者它的子类的实例还存在，则不能调用objc_disposeClassPair这个方法；因此这里要先销毁实例对象后才能销毁类；
        
        // 销毁类
        objc_disposeClassPair(People);

    }
    return 0;
}

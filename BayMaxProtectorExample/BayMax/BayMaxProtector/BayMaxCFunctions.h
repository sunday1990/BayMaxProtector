//
//  BayMaxCFunctions.h
//  BayMaxProtector
//
//  Created by ccSunday on 2018/1/22.
//  Copyright © 2018年 ccSunday. All rights reserved.
//

#import <objc/runtime.h>

#ifndef BayMaxCFunctions_h
#define BayMaxCFunctions_h

#define BMP_SuppressPerformSelectorLeakWarning(Stuff)\
do { \
_Pragma("clang diagnostic push") \
_Pragma("clang diagnostic ignored \"-Warc-performSelector-leaks\"") \
Stuff; \
_Pragma("clang diagnostic pop") \
} while (0)

static inline void BMP_EXChangeInstanceMethod(Class _originalClass ,SEL _originalSel,Class _targetClass ,SEL _targetSel){
    Method methodOriginal = class_getInstanceMethod(_originalClass, _originalSel);
    Method methodNew = class_getInstanceMethod(_targetClass, _targetSel);
    method_exchangeImplementations(methodOriginal, methodNew);
}

static inline void BMP_EXChangeClassMethod(Class _class ,SEL _originalSel,SEL _exchangeSel){
    Method methodOriginal = class_getClassMethod(_class, _originalSel);
    Method methodNew = class_getClassMethod(_class, _exchangeSel);
    method_exchangeImplementations(methodOriginal, methodNew);
}

#endif /* BayMaxCFunctions_h */

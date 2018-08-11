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
@class BayMaxCatchError;

typedef void(^BMPErrorHandler)(BayMaxCatchError * error);

typedef struct IMPNode *PtrToIMP;
typedef PtrToIMP IMPlist;
struct IMPNode{
    IMP imp;
    PtrToIMP next;
};

/*向IMP链表中追加imp*/
static inline void BMP_InsertIMPToList(IMPlist list,IMP imp){
    PtrToIMP nextNode = malloc(sizeof(struct IMPNode));
    nextNode->imp = imp;
    nextNode->next = list->next;
    list->next = nextNode;
}

/*判断IMP链表中有没有此元素。
 注意：libobjc中的c函数无效，这时候需要通过手动建立映射关系来替代
 */
static inline BOOL BMP_ImpExistInList(IMPlist list, IMP imp){
    if (list->imp == imp) {
        return YES;
    }else{
        if (list->next != NULL) {
            return BMP_ImpExistInList(list->next,imp);
        }else{
            return NO;
        }
    }
}

struct ErrorBody{
    const char *function_name;
    const char *function_class;
};
typedef struct ErrorBody ErrorInfos;
/*创建错误信息*/
static inline ErrorInfos ErrorInfosMake(const char *function_class,const char *function_name)
{
    ErrorInfos errorInfos;
    errorInfos.function_name = function_name;
    errorInfos.function_class = function_class;
    return errorInfos;
}
/*交换实例方法*/
static inline void BMP_EXChangeInstanceMethod(Class _originalClass ,SEL _originalSel,Class _targetClass ,SEL _targetSel){
    Method methodOriginal = class_getInstanceMethod(_originalClass, _originalSel);
    Method methodNew = class_getInstanceMethod(_targetClass, _targetSel);
    BOOL didAddMethod = class_addMethod(_originalClass, _originalSel, method_getImplementation(methodNew), method_getTypeEncoding(methodNew));
    if (didAddMethod) {
        class_replaceMethod(_originalClass, _targetSel, method_getImplementation(methodOriginal), method_getTypeEncoding(methodOriginal));
    }else{
        method_exchangeImplementations(methodOriginal, methodNew);
    }    
}
/*交换类方法*/
static inline void BMP_EXChangeClassMethod(Class _class ,SEL _originalSel,SEL _exchangeSel){
    Method methodOriginal = class_getClassMethod(_class, _originalSel);
    Method methodNew = class_getClassMethod(_class, _exchangeSel);
    method_exchangeImplementations(methodOriginal, methodNew);
}

#endif /* BayMaxCFunctions_h */

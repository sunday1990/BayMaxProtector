//
//  BayMaxProtector.m
//  BayMaxProtector
//
//  Created by ccSunday on 2017/3/23.
//  Copyright © 2018年 ccSunday. All rights reserved.
//
#import <UIKit/UIKit.h>
#import <objc/runtime.h>
#import "BayMaxProtector.h"
#import "BayMaxKVODelegate.h"
#import "BayMaxTimerSubTarget.h"
#import "BayMaxCFunctions.h"
#import "BayMaxDegradeAssist.h"

typedef void(^BMPErrorHandler)(BayMaxCatchError *_Nullable error);
BMPErrorHandler _Nullable _errorHandler;

static NSArray *_ignorePrefixes;

struct ErrorBody{
    const char *function_name;
    const char *function_class;
};
typedef struct ErrorBody ErrorInfos;
static ErrorInfos errors;

static inline int DynamicAddMethodIMP(id self,SEL _cmd,...){
#ifdef DEBUG
#else
#endif
    return 0;
}

static inline ErrorInfos ErrorInfosMake(const char *function_class,const char *function_name)
{
    ErrorInfos errorInfos;
    errorInfos.function_name = function_name;
    errorInfos.function_class = function_class;
    return errorInfos;
}

static inline BOOL IsSystemClass(Class cls){
    __block BOOL isSystem = NO;
    NSString *className = NSStringFromClass(cls);
    if ([className hasPrefix:@"NS"]) {
        isSystem = YES;
        return isSystem;
    }
    NSBundle *mainBundle = [NSBundle bundleForClass:cls];
    if (mainBundle == [NSBundle mainBundle]) {
        isSystem = NO;
    }else{
        isSystem = YES;
    }
    if (_ignorePrefixes.count>0) {
        [_ignorePrefixes enumerateObjectsUsingBlock:^(NSString * prefix, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([className hasPrefix:prefix]) {
                isSystem = YES;
                *stop = YES;
            }
        }];
    }
    return isSystem;
}

//static inline BOOL IsPrivateClass(Class cls){
//    __block BOOL isPrivate = NO;
//    NSString *className = NSStringFromClass(cls);
//    if ([className containsString:@"_UI"] ||
//        [className containsString:@"_NS"]||
//        [className hasPrefix:@"_"]||
//        [className hasPrefix:@"__"]||
//        [className hasPrefix:@"NS"]||
//        [className hasPrefix:@"CA"]||
//        [className hasPrefix:@"UI"]||
//        [className hasPrefix:@"AV"]) {
//        isPrivate = YES;
//        return isPrivate;
//    }
//    if (_ignorePrefixes.count>0) {
//        [_ignorePrefixes enumerateObjectsUsingBlock:^(NSString * prefix, NSUInteger idx, BOOL * _Nonnull stop) {
//            if ([className hasPrefix:prefix]) {
//                isPrivate = YES;
//                *stop = YES;
//            }
//        }];
//    }
//    return isPrivate;
//}

static inline NSString *GetClassNameOfViewControllerIfErrorHappensInViewDidloadProcessWithCallStackSymbols(NSArray *callStackSymbolsArr){
    __block NSString *className;
    if (callStackSymbolsArr != nil) {
        for (int i = 3; i<=callStackSymbolsArr.count; i++) {
            NSString *symbol = callStackSymbolsArr[i];
            if ([symbol containsString:@"BayMaxProtector"]) {
                if ([symbol containsString:@"viewDidLoad"]) {
                    NSRange beginRange = [symbol rangeOfString:@"-["];
                    NSRange endRange = [symbol rangeOfString:@"viewDidLoad"];
                    NSInteger length = endRange.location-1-(beginRange.location+beginRange.length);
                    className = [symbol substringWithRange:NSMakeRange(beginRange.location+beginRange.length, length)];
                    break;
                }
            }else{
                break;
            }
        }
    }
    return className;
}

#pragma mark  BayMaxCrashHandler
@interface BayMaxCrashHandler : NSObject
+ (nonnull instancetype)sharedBayMaxCrashHandler;
- (void)forwardingCrashMethodInfos:(NSDictionary *_Nullable)infos;
@end

@implementation BayMaxCrashHandler

static BayMaxCrashHandler *_instance;

+ (id)allocWithZone:(struct _NSZone *)zone{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [super allocWithZone:zone];
    });
    return _instance;
}

+ (nonnull instancetype)sharedBayMaxCrashHandler{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc] init];
    });
    return _instance;
}

- (id)copyWithZone:(NSZone *)zone{
    return _instance;
}

- (void)forwardingCrashMethodInfos:(NSDictionary *_Nullable)infos{
#ifdef DEBUG
#else
#endif
}

@end

#pragma mark NSObject + UNRecognizedSelHandler
@interface NSObject (UNRecognizedSelHandler)
@end

@implementation NSObject (UNRecognizedSelHandler)
static NSString *const ErrorClassName = @"BMPError_ClassName";
static NSString *const ErrorFunctionName = @"BMPError_FunctionName";
static NSString *const ErrorViewController = @"BMPError_ViewController";

//将崩溃信息转发到一个指定的类中执行FastForwarding
- (id)BMP_forwardingTargetForSelector:(SEL)selector{
    /*判断当前类有没有重写消息转发的相关方法*/
        if ([self isEqual:[NSNull null]] || ![self overideForwardingMethods]) {//没有重写消息转发方法
            NSArray *callStackSymbolsArr = [NSThread callStackSymbols];
            NSString *vcClassName = GetClassNameOfViewControllerIfErrorHappensInViewDidloadProcessWithCallStackSymbols(callStackSymbolsArr);
            //判断是否是viewdidload方法出错
            errors = ErrorInfosMake([NSStringFromClass(self.class) cStringUsingEncoding:NSASCIIStringEncoding], [NSStringFromSelector(selector) cStringUsingEncoding:NSASCIIStringEncoding]);
            class_addMethod([BayMaxCrashHandler class], selector, (IMP)DynamicAddMethodIMP, "v@:");
            [[BayMaxCrashHandler sharedBayMaxCrashHandler]forwardingCrashMethodInfos:@{ErrorClassName:NSStringFromClass(self.class),
                                                                                    ErrorFunctionName:NSStringFromSelector(selector),
                                                                                  ErrorViewController:[[BayMaxDegradeAssist Assist]topViewController]
                                                                           }];
            
            
            BayMaxCatchError *bmpError = [BayMaxCatchError BMPErrorWithType:BayMaxErrorTypeUnrecognizedSelector infos:@{
                                                                                                                        BMPErrorUnrecognizedSel_Reason:[NSString stringWithFormat:@"UNRecognized Selector:%@ sent to instance %@",NSStringFromSelector(selector),self],
                                                                                                       BMPErrorUnrecognizedSel_Receiver:self==nil?@"":self,                                                                                                     BMPErrorUnrecognizedSel_Func:NSStringFromSelector(selector),
                                                                                                       BMPErrorUnrecognizedSel_VC:vcClassName == nil?([[BayMaxDegradeAssist Assist]topViewController] == nil?@"":[[BayMaxDegradeAssist Assist]topViewController]):vcClassName
                                                                                                       }];
            [[BayMaxDegradeAssist Assist]handleError:bmpError];
            if (_errorHandler) {
                _errorHandler(bmpError);
            }
            return [BayMaxCrashHandler sharedBayMaxCrashHandler];
        }
    return [self BMP_forwardingTargetForSelector:selector];
}

- (BOOL)overideForwardingMethods{
    BOOL overide = NO;
    overide = (class_getMethodImplementation([NSObject class], @selector(forwardInvocation:)) != class_getMethodImplementation([self class], @selector(forwardInvocation:))) ||
    (class_getMethodImplementation([NSObject class], @selector(forwardingTargetForSelector:)) != class_getMethodImplementation([self class], @selector(forwardingTargetForSelector:)));
    return overide;
}

@end

#pragma mark NSObject + KVOProtector
@interface NSObject (KVOProtector)
@end

@implementation NSObject (KVOProtector)
static void *KVOProtectorKey = &KVOProtectorKey;
static NSString *const KVOProtectorValue = @"BMP_KVOProtector";
static void *BayMaxKVODelegateKey = &BayMaxKVODelegateKey;

- (void)setBayMaxKVODelegate:(BayMaxKVODelegate *)BayMaxKVODelegate{
    objc_setAssociatedObject(self, BayMaxKVODelegateKey, BayMaxKVODelegate, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BayMaxKVODelegate *)bayMaxKVODelegate{
    id bayMaxKVODelegate = objc_getAssociatedObject(self, BayMaxKVODelegateKey);
    if (bayMaxKVODelegate == nil) {
        bayMaxKVODelegate = [[BayMaxKVODelegate alloc]init];
        self.bayMaxKVODelegate = bayMaxKVODelegate;
    }
    return bayMaxKVODelegate;
}

- (void)BMP_addObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options context:(void *)context{
    if (!IsSystemClass(self.class)) {
        __weak typeof(self) weakSelf = self;
        objc_setAssociatedObject(self, KVOProtectorKey, KVOProtectorValue, OBJC_ASSOCIATION_RETAIN);
        [self.bayMaxKVODelegate addKVOInfoToMapsWithObserver:observer forKeyPath:keyPath options:options context:context success:^{
            [weakSelf BMP_addObserver:weakSelf.bayMaxKVODelegate forKeyPath:keyPath options:options context:context];
        } failure:^(NSError *error) {
            
            //Cannot remove an observer <BayMaxKVODelegate 0x17001eb00> for the key path "state" from <UIScrollViewPanGestureRecognizer 0x1019459a0> because it is not registered as an observer.'
            
            BayMaxCatchError *bmpError = [BayMaxCatchError BMPErrorWithType:BayMaxErrorTypeKVO infos:@{
                                                                                                       BMPErrorKVO_Reason:[NSString stringWithFormat:@"Repeated additions to the observer for the key path:'%@' from '%@'",keyPath,NSStringFromClass(weakSelf.class) == nil?@"":NSStringFromClass(weakSelf.class)],
                                                                                                       BMPErrorKVO_Observer:observer == nil?@"":observer,
                                                                                                       BMPErrorKVO_Keypath:keyPath == nil?@"":keyPath,
                                                                                                       BMPErrorKVO_Target:NSStringFromClass(weakSelf.class) == nil?@"":NSStringFromClass(weakSelf.class)
                                                                                                       }];
            if (_errorHandler) {
                _errorHandler(bmpError);
            }            
        }];
    }else{
        [self BMP_addObserver:observer forKeyPath:keyPath options:options context:context];
    }
}

- (void)BMP_removeObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath{
    if (!IsSystemClass(self.class)) {
        if ([self.bayMaxKVODelegate removeKVOInfoInMapsWithObserver:observer forKeyPath:keyPath]) {
            [self BMP_removeObserver:self.bayMaxKVODelegate forKeyPath:keyPath];
        }else{
//            NSLog(@"移除的keypath不存在\n{\n keypath：%@\n observer :%@\n}",keyPath,observer);            
        }
    }else{
        [self BMP_removeObserver:observer forKeyPath:keyPath];
    }
}

- (void)BMPKVO_dealloc{
    if (!IsSystemClass(self.class)) {
        NSString *value = (NSString *)objc_getAssociatedObject(self, KVOProtectorKey);
        if ([value isEqualToString:KVOProtectorValue]) {
            NSArray *keypaths = [self.bayMaxKVODelegate getAllKeypaths];
            [keypaths enumerateObjectsUsingBlock:^(NSString *keyPath, NSUInteger idx, BOOL * _Nonnull stop) {
                //这个方法容易发生崩溃
                [self BMP_removeObserver:self.bayMaxKVODelegate forKeyPath:keyPath];
                
            }];
        }
    }
     [self BMPKVO_dealloc];
}

@end

#pragma mark NSNotificationCenter+NotificationProtector
static void *NSNotificationProtectorKey = &NSNotificationProtectorKey;
static NSString *const NSNotificationProtectorValue = @"BMP_NotificationProtector";

@interface NSNotificationCenter (NotificationProtector)
@end

#pragma mark UIViewController+NotificationProtector
@interface UIViewController (NotificationProtector)
@end

@implementation NSNotificationCenter (NotificationProtector)
- (void)BMP_addObserver:(id)observer selector:(SEL)aSelector name:(NSNotificationName)aName object:(id)anObject{
    objc_setAssociatedObject(observer, NSNotificationProtectorKey, NSNotificationProtectorValue, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self BMP_addObserver:observer selector:aSelector name:aName object:anObject];
}

@end

@implementation UIViewController (NotificationProtector)
- (void)BMP_dealloc{
    NSString *value = (NSString *)objc_getAssociatedObject(self, NSNotificationProtectorKey);
    if ([value isEqualToString:NSNotificationProtectorValue]) {
        [[NSNotificationCenter defaultCenter] removeObserver:self];
    }
    [self BMP_dealloc];
}

@end

#pragma mark NSTimer+TimerProtector
@interface NSTimer (TimerProtector)

@end

@implementation NSTimer (TimerProtector)
+ (NSTimer *)BMP_scheduledTimerWithTimeInterval:(NSTimeInterval)ti target:(id)aTarget selector:(SEL)aSelector userInfo:(id)userInfo repeats:(BOOL)yesOrNo{
    if (!IsSystemClass([aTarget class])) {
        BayMaxTimerSubTarget *subtarget = [BayMaxTimerSubTarget targetWithTimeInterval:ti target:aTarget selector:aSelector userInfo:userInfo repeats:yesOrNo catchErrorHandler:^(BayMaxCatchError *error) {
            _errorHandler(error);
        }];
        return [self BMP_scheduledTimerWithTimeInterval:ti target:subtarget selector:NSSelectorFromString(@"fireProxyTimer:") userInfo:userInfo repeats:yesOrNo];
    }else{
        return [self BMP_scheduledTimerWithTimeInterval:ti target:aTarget selector:aSelector userInfo:userInfo repeats:yesOrNo];
    }
}

@end

#pragma mark BayMaxProtector
@interface BayMaxProtector()

@end

@implementation BayMaxProtector

+ (void)openProtectionsOn:(BayMaxProtectionType)protectionType{
    [self openProtectionsOn:protectionType catchErrorHandler:nil];
}

+ (void)openProtectionsOn:(BayMaxProtectionType)protectionType catchErrorHandler:(void(^_Nullable)(BayMaxCatchError * _Nullable error))errorHandler{
    _errorHandler = errorHandler;    
    if (protectionType > (1<<3)) {
        [self openOneProtectionOn:BayMaxProtectionTypeTimer];
        protectionType -= (1<<3) ;
    }
    switch ((long)protectionType) {
        case BayMaxProtectionTypeUnrecognizedSelector:
        case BayMaxProtectionTypeKVO:
        case BayMaxProtectionTypeNotification:
        case BayMaxProtectionTypeTimer:
        case BayMaxProtectionTypeAll:
        {
            [self openOneProtectionOn:protectionType];
        }
            break;
        case 3:
        {
            [self openOneProtectionOn:BayMaxProtectionTypeUnrecognizedSelector];
            [self openOneProtectionOn:BayMaxProtectionTypeKVO];
        }
            break;
        case 5:
        {
            [self openOneProtectionOn:BayMaxProtectionTypeUnrecognizedSelector];
            [self openOneProtectionOn:BayMaxProtectionTypeNotification];
        }
            break;
        case 6:
        {
            [self openOneProtectionOn:BayMaxProtectionTypeKVO];
            [self openOneProtectionOn:BayMaxProtectionTypeNotification];
        }
            break;
        case 7:
        {
            [self openOneProtectionOn:BayMaxProtectionTypeUnrecognizedSelector];
            [self openOneProtectionOn:BayMaxProtectionTypeKVO];
            [self openOneProtectionOn:BayMaxProtectionTypeNotification];
        }
            break;
            
        default:
            break;
    }
}

+ (void)openOneProtectionOn:(BayMaxProtectionType)protectionType{
    switch (protectionType) {
        case BayMaxProtectionTypeUnrecognizedSelector:
        {
          BMP_EXChangeInstanceMethod([NSObject class], @selector(forwardingTargetForSelector:), [NSObject class], @selector(BMP_forwardingTargetForSelector:));
        }
            break;
    case BayMaxProtectionTypeKVO:
        {
            BMP_EXChangeInstanceMethod([NSObject class], @selector(addObserver:forKeyPath:options:context:), [NSObject class], @selector(BMP_addObserver:forKeyPath:options:context:));
            BMP_EXChangeInstanceMethod([NSObject class], @selector(removeObserver:forKeyPath:), [NSObject class], @selector(BMP_removeObserver:forKeyPath:));
            BMP_EXChangeInstanceMethod([NSObject class], NSSelectorFromString(@"dealloc"), [NSObject class], @selector(BMPKVO_dealloc));
        }
        break;
        
    case BayMaxProtectionTypeNotification:
        {
            BMP_EXChangeInstanceMethod([NSNotificationCenter class], @selector(addObserver:selector:name:object:), [NSNotificationCenter class], @selector(BMP_addObserver:selector:name:object:));
            BMP_EXChangeInstanceMethod([UIViewController class], NSSelectorFromString(@"dealloc"), [self class], NSSelectorFromString(@"BMP_dealloc"));
        }
        break;
    case BayMaxProtectionTypeTimer:
        {
            BMP_EXChangeInstanceMethod([NSTimer class], @selector(scheduledTimerWithTimeInterval:target:selector:userInfo:repeats:), [NSTimer class], @selector(BMP_scheduledTimerWithTimeInterval:target:selector:userInfo:repeats:));
        }
        break;
    case BayMaxProtectionTypeAll:
        {
            BMP_EXChangeInstanceMethod([NSObject class], @selector(forwardingTargetForSelector:), [NSObject class], @selector(BMP_forwardingTargetForSelector:));
            BMP_EXChangeInstanceMethod([NSObject class], @selector(addObserver:forKeyPath:options:context:), [NSObject class], @selector(BMP_addObserver:forKeyPath:options:context:));
            BMP_EXChangeInstanceMethod([NSObject class], @selector(removeObserver:forKeyPath:), [NSObject class], @selector(BMP_removeObserver:forKeyPath:));
            BMP_EXChangeInstanceMethod([NSObject class], NSSelectorFromString(@"dealloc"), [NSObject class], @selector(BMPKVO_dealloc));
            BMP_EXChangeInstanceMethod([NSNotificationCenter class], @selector(addObserver:selector:name:object:), [NSNotificationCenter class], @selector(BMP_addObserver:selector:name:object:));
            BMP_EXChangeInstanceMethod([UIViewController class], NSSelectorFromString(@"dealloc"), [self class], NSSelectorFromString(@"BMP_dealloc"));
            BMP_EXChangeClassMethod([NSTimer class], @selector(scheduledTimerWithTimeInterval:target:selector:userInfo:repeats:),  @selector(BMP_scheduledTimerWithTimeInterval:target:selector:userInfo:repeats:));
        }
        break;
   
        default:
            break;
    }
}

+ (void)ignoreProtectionsOnClassesWithPrefix:(NSArray *_Nonnull)ignorePrefixes{
    _ignorePrefixes = ignorePrefixes;
}

@end

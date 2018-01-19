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
#import "BayMaxCrashHandler.h"
#import "BayMaxKVODelegate.h"
#import "BayMaxTimerSubTarget.h"

typedef void(^BMPErrorHandler)(BayMaxCatchError *_Nullable error);
BMPErrorHandler _Nullable _errorHandler;

static NSArray *_ignorePrefixes;

struct ErrorBody{
    const char *function_name;
    const char *function_class;
};
typedef struct ErrorBody ErrorInfos;
static ErrorInfos errors;

static inline void EXChangeInstanceMethod(Class _originalClass ,SEL _originalSel,Class _targetClass ,SEL _targetSel){
    Method methodOriginal = class_getInstanceMethod(_originalClass, _originalSel);
    Method methodNew = class_getInstanceMethod(_targetClass, _targetSel);
    method_exchangeImplementations(methodOriginal, methodNew);
}

static inline void EXChangeClassMethod(Class _class ,SEL _originalSel,SEL _exchangeSel){
    Method methodOriginal = class_getClassMethod(_class, _originalSel);
    Method methodNew = class_getClassMethod(_class, _exchangeSel);
    method_exchangeImplementations(methodOriginal, methodNew);
}

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

static inline BOOL IsPrivateClass(Class cls){
    __block BOOL isPrivate = NO;
    NSString *className = NSStringFromClass(cls);
    if ([className containsString:@"_UI"] ||
        [className containsString:@"_NS"]||
        [className hasPrefix:@"_"]||
        [className hasPrefix:@"__"]||
        [className hasPrefix:@"NS"]||
        [className hasPrefix:@"CA"]||
        [className hasPrefix:@"UI"]||
        [className hasPrefix:@"AV"]) {
        isPrivate = YES;
        return isPrivate;
    }
    if (_ignorePrefixes.count>0) {
        [_ignorePrefixes enumerateObjectsUsingBlock:^(NSString * prefix, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([className hasPrefix:prefix]) {
                isPrivate = YES;
                *stop = YES;
            }
        }];
    }
    return isPrivate;
}

#pragma mark UNRecognizedSelHandler
@interface NSObject (UNRecognizedSelHandler)
@end

@implementation NSObject (UNRecognizedSelHandler)
static NSString *const ErrorClassName = @"BMPError_ClassName";
static NSString *const ErrorFunctionName = @"BMPError_FunctionName";
static NSString *const ErrorViewController = @"BMPError_ViewController";

//将崩溃信息转发到一个指定的类中执行FastForwarding
- (id)BMP_forwardingTargetForSelector:(SEL)selector{
    /*判断当前类有没有重写消息转发的相关方法*/
    if ([self isEqual:[NSNull null]] || ![self isPrivateClass]) {//不是私有类，这一步判断不准确，只会筛选出一些明显的,需要到下一步进行进一步的筛选
        if (![self overideForwardingMethods]) {//没有重写消息转发方法
            errors = ErrorInfosMake([NSStringFromClass(self.class) cStringUsingEncoding:NSASCIIStringEncoding], [NSStringFromSelector(selector) cStringUsingEncoding:NSASCIIStringEncoding]);
            class_addMethod([BayMaxCrashHandler class], selector, (IMP)DynamicAddMethodIMP, "v@:");
           
            [[BayMaxCrashHandler sharedBayMaxCrashHandler]forwardingCrashMethodInfos:@{ErrorClassName:NSStringFromClass(self.class),
                                                                                    ErrorFunctionName:NSStringFromSelector(selector),
                                                                                  ErrorViewController:[self getCurrentVC]
                                                                           }];
            
            BayMaxCatchError *bmpError = [BayMaxCatchError BMPErrorWithType:BayMaxErrorTypeUnrecognizedSelector infos:@{
                                                                                                       BMPErrorUnrecognizedSel_Reason:@"UNRecognized Selector",
                                                                                                       BMPErrorUnrecognizedSel_Receiver:self==nil?@"":self,                                                                                                     BMPErrorUnrecognizedSel_Func:NSStringFromSelector(selector),
                                                                                                       BMPErrorUnrecognizedSel_VC:[self getCurrentVC] == nil?@"":[self getCurrentVC]
                                                                                                       }];
            if (_errorHandler) {
                _errorHandler(bmpError);
            }
            return [BayMaxCrashHandler sharedBayMaxCrashHandler];
        }
    }
    return [self BMP_forwardingTargetForSelector:selector];
}

- (UIViewController *)getCurrentVC{
    if ([self isKindOfClass:[UIViewController class]]) {
        return (UIViewController *)self;
    }
    UIViewController *result = nil;
    UIWindow * window = [[UIApplication sharedApplication] keyWindow]; //app默认windowLevel是UIWindowLevelNormal，如果不是，找到UIWindowLevelNormal的
    if (window.windowLevel != UIWindowLevelNormal) {
        NSArray *windows = [[UIApplication sharedApplication] windows];
        for(UIWindow * tmpWin in windows) {
            if (tmpWin.windowLevel == UIWindowLevelNormal) {
                window = tmpWin;
                break;
            }
        }
    }
    id nextResponder = nil;
    UIViewController *appRootVC = window.rootViewController; // 如果是present上来的appRootVC.presentedViewController 不为nil
    if (appRootVC.presentedViewController) {
        nextResponder = appRootVC.presentedViewController;
    }else{
        UIView *frontView = [[window subviews] objectAtIndex:0];
        nextResponder = [frontView nextResponder];
    }
    if ([nextResponder isKindOfClass:[UITabBarController class]]){
        UITabBarController * tabbar = (UITabBarController *)nextResponder;
        UINavigationController * nav = (UINavigationController *)tabbar.viewControllers[tabbar.selectedIndex];
        result = nav.childViewControllers.lastObject;
    }else if ([nextResponder isKindOfClass:[UINavigationController class]]){
        UIViewController * nav = (UIViewController *)nextResponder;
        result = nav.childViewControllers.lastObject;
    }else{
        result = nextResponder;
    }
    return result;
}


- (BOOL)overideForwardingMethods{
    BOOL overide = NO;
    NSArray *methods = [self getAllInstanceMethods];
    if ([methods containsObject:@"forwardingTargetForSelector:"]||
        [methods containsObject:@"forwardInvocation:"]) {
        overide = YES;
    }
    return overide;
}

-(NSArray *)getAllInstanceMethods{
    unsigned int methodCount = 0;
    Method *methodLists = class_copyMethodList([self class],&methodCount);
    NSMutableArray *methodsArray = [NSMutableArray arrayWithCapacity:methodCount];
    for(int i=0; i<methodCount; i++)
    {
        Method tempM = methodLists[i];
        //方法
        SEL selName = method_getName(tempM);
        NSString *methodString = NSStringFromSelector(selName);
        [methodsArray addObject:methodString];
    }
    free(methodLists);
    return methodsArray;
}

#pragma mark 是否是私有，只能初步过滤
- (BOOL)isPrivateClass{
    BOOL isPrivate = NO;
    NSString *className = NSStringFromClass(self.class);
    if ([className hasPrefix:@"_UI"] ||
        [className hasPrefix:@"_NS"]||
        [className hasPrefix:@"_"]||
        [className hasPrefix:@"__"]) {
        isPrivate = YES;
    }
    return isPrivate;
}
//||
//[className hasPrefix:@"UIWeb"]
@end

#pragma mark KVOProtector
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
    if (!IsPrivateClass(self.class)) {
        __weak typeof(self) weakSelf = self;
        objc_setAssociatedObject(self, KVOProtectorKey, KVOProtectorValue, OBJC_ASSOCIATION_RETAIN);
        [self.bayMaxKVODelegate addKVOInfoToMapsWithObserver:observer forKeyPath:keyPath options:options context:context success:^{
            [weakSelf BMP_addObserver:weakSelf.bayMaxKVODelegate forKeyPath:keyPath options:options context:context];
        } failure:^(NSError *error) {
            BayMaxCatchError *bmpError = [BayMaxCatchError BMPErrorWithType:BayMaxErrorTypeKVO infos:@{
                                                                                                       BMPErrorKVO_Reason:@"Repeated additions to the observer",
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
    if (!IsPrivateClass(self.class)) {
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
    if (!IsPrivateClass(self.class)) {
        NSString *value = (NSString *)objc_getAssociatedObject(self, KVOProtectorKey);
        if ([value isEqualToString:KVOProtectorValue]) {
            NSArray *keypaths = [self.bayMaxKVODelegate getAllKeypaths];
            [keypaths enumerateObjectsUsingBlock:^(NSString *keyPath, NSUInteger idx, BOOL * _Nonnull stop) {
                [self BMP_removeObserver:self.bayMaxKVODelegate forKeyPath:keyPath];
            }];
        }
    }
     [self BMPKVO_dealloc];
}

@end

#pragma mark NotificationProtector
static void *NSNotificationProtectorKey = &NSNotificationProtectorKey;
static NSString *const NSNotificationProtectorValue = @"BMP_NotificationProtector";

@interface NSNotificationCenter (NotificationProtector)
@end

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

#pragma mark NSTimer
@interface NSTimer (TimerProtector)

@end

@implementation NSTimer (TimerProtector)
+ (NSTimer *)BMP_scheduledTimerWithTimeInterval:(NSTimeInterval)ti target:(id)aTarget selector:(SEL)aSelector userInfo:(id)userInfo repeats:(BOOL)yesOrNo{
    if (!IsPrivateClass([aTarget class])) {
        BayMaxTimerSubTarget *subtarget = [BayMaxTimerSubTarget targetWithTimeInterval:ti target:aTarget selector:aSelector userInfo:userInfo repeats:yesOrNo catchErrorHandler:^(BayMaxCatchError *error) {
            _errorHandler(error);
        }];
        return [self BMP_scheduledTimerWithTimeInterval:ti target:subtarget selector:NSSelectorFromString(@"fireProxyTimer:") userInfo:userInfo repeats:yesOrNo];
    }else{
        return [self BMP_scheduledTimerWithTimeInterval:ti target:aTarget selector:aSelector userInfo:userInfo repeats:yesOrNo];
    }
}

@end


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
          EXChangeInstanceMethod([NSObject class], @selector(forwardingTargetForSelector:), [NSObject class], @selector(BMP_forwardingTargetForSelector:));
        }
            break;
    case BayMaxProtectionTypeKVO:
        {
            EXChangeInstanceMethod([NSObject class], @selector(addObserver:forKeyPath:options:context:), [NSObject class], @selector(BMP_addObserver:forKeyPath:options:context:));
            EXChangeInstanceMethod([NSObject class], @selector(removeObserver:forKeyPath:), [NSObject class], @selector(BMP_removeObserver:forKeyPath:));
            EXChangeInstanceMethod([NSObject class], NSSelectorFromString(@"dealloc"), [NSObject class], @selector(BMPKVO_dealloc));
        }
        break;
        
    case BayMaxProtectionTypeNotification:
        {
            EXChangeInstanceMethod([NSNotificationCenter class], @selector(addObserver:selector:name:object:), [NSNotificationCenter class], @selector(BMP_addObserver:selector:name:object:));
            EXChangeInstanceMethod([UIViewController class], NSSelectorFromString(@"dealloc"), [self class], NSSelectorFromString(@"BMP_dealloc"));
        }
        break;
    case BayMaxProtectionTypeTimer:
        {
            EXChangeInstanceMethod([NSTimer class], @selector(scheduledTimerWithTimeInterval:target:selector:userInfo:repeats:), [NSTimer class], @selector(BMP_scheduledTimerWithTimeInterval:target:selector:userInfo:repeats:));
        }
        break;
    case BayMaxProtectionTypeAll:
        {
            EXChangeInstanceMethod([NSObject class], @selector(forwardingTargetForSelector:), [NSObject class], @selector(BMP_forwardingTargetForSelector:));
            EXChangeInstanceMethod([NSObject class], @selector(addObserver:forKeyPath:options:context:), [NSObject class], @selector(BMP_addObserver:forKeyPath:options:context:));
            EXChangeInstanceMethod([NSObject class], @selector(removeObserver:forKeyPath:), [NSObject class], @selector(BMP_removeObserver:forKeyPath:));
            EXChangeInstanceMethod([NSObject class], NSSelectorFromString(@"dealloc"), [NSObject class], @selector(BMPKVO_dealloc));
            EXChangeInstanceMethod([NSNotificationCenter class], @selector(addObserver:selector:name:object:), [NSNotificationCenter class], @selector(BMP_addObserver:selector:name:object:));
            EXChangeInstanceMethod([UIViewController class], NSSelectorFromString(@"dealloc"), [self class], NSSelectorFromString(@"BMP_dealloc"));
            EXChangeClassMethod([NSTimer class], @selector(scheduledTimerWithTimeInterval:target:selector:userInfo:repeats:),  @selector(BMP_scheduledTimerWithTimeInterval:target:selector:userInfo:repeats:));
        }
        break;
   
        default:
            break;
    }
}

+ (void)ignoreProtectionsOnFrameworksWithPrefix:(NSArray *_Nonnull)ignorePrefixes{
    _ignorePrefixes = ignorePrefixes;
}

@end

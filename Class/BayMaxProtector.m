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
#import "BayMaxContainers.h"
#import "BayMaxDebugView.h"
#import "BayMaxCatchError.h"

//声明一个全局的IMP链表
static IMPlist impList;
//声明一个全局的错误信息结构体
static ErrorInfos errors;
//声明错误信息处理handler
BMPErrorHandler _Nullable _errorHandler;
//声明保存需要忽略的类前缀数组
static NSArray *_ignorePrefixes;
static BOOL _showDebugView;
/*动态添加方法的imp*/
static inline int DynamicAddMethodIMP(id self,SEL _cmd,...){
#ifdef DEBUG
#else
#endif
    return 0;
}

/*是否是系统类*/
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

/*错误发生在viewdidload中的时候获取发生错误的视图控制器的类名*/
static inline NSString *GetClassNameOfViewControllerIfErrorHappensInViewDidloadProcessWithCallStackSymbols(NSArray *callStackSymbolsArr){
    __block NSString *className;
    if (callStackSymbolsArr != nil) {
        for (int i = 3; i < callStackSymbolsArr.count; i++) {
            NSString *symbol = callStackSymbolsArr[i];
            if ([symbol containsString:@"UIKit"]) {
                NSString *lastSymbol = callStackSymbolsArr[i-1];
                if ([lastSymbol containsString:@"viewDidLoad"]) {
                    if ([lastSymbol rangeOfString:@"-["].length>0) {
                        NSRange beginRange = [lastSymbol rangeOfString:@"-["];
                        NSRange endRange = [lastSymbol rangeOfString:@"viewDidLoad"];
                        NSInteger length = endRange.location-1-(beginRange.location+beginRange.length);
                        className = [lastSymbol substringWithRange:NSMakeRange(beginRange.location+beginRange.length, length)];
                        break;
                    }else{
                        
                    }
                }
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
                                                                                                                        BMPErrorUnrecognizedSel_Reason:[NSString stringWithFormat:@"UNRecognized Selector:'%@' sent to instance %@",NSStringFromSelector(selector),self],
                                                                                                       BMPErrorUnrecognizedSel_VC:vcClassName == nil?([[BayMaxDegradeAssist Assist]topViewController] == nil?@"":[[BayMaxDegradeAssist Assist]topViewController]):vcClassName,
                                                                                                                        BMPErrorCallStackSymbols:callStackSymbolsArr
                                                                                                       }];
            if (_showDebugView) {
                [[BayMaxDebugView sharedDebugView]addErrorInfo:bmpError.errorInfos];
            }
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
            NSArray *callStackSymbolsArr = [NSThread callStackSymbols];
            BayMaxCatchError *bmpError = [BayMaxCatchError BMPErrorWithType:BayMaxErrorTypeKVO infos:@{
                                                                                                       BMPErrorKVO_Reason:[NSString stringWithFormat:@"Repeated additions to the observer:%@ for the key path:'%@' from %@",observer == nil?@"":observer,keyPath,NSStringFromClass(weakSelf.class) == nil?@"":NSStringFromClass(weakSelf.class)]
                                                                                                       }];
            if (_showDebugView) {
                [[BayMaxDebugView sharedDebugView]addErrorInfo:bmpError.errorInfos];
            }
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
            NSArray *callStackSymbolsArr = [NSThread callStackSymbols];
            NSString *reson = [NSString stringWithFormat:@"Cannot remove an observer %@ for the key path '%@' from %@ because it is not registered as an observer",observer,keyPath,NSStringFromClass(self.class) == nil?@"":NSStringFromClass(self.class)];
            BayMaxCatchError *bmpError = [BayMaxCatchError BMPErrorWithType:BayMaxErrorTypeKVO infos:@{
                                                                                                       BMPErrorKVO_Reason:reson
                                                                                                       }];
            if (_showDebugView) {
                [[BayMaxDebugView sharedDebugView]addErrorInfo:bmpError.errorInfos];
            }
            if (_errorHandler) {
                _errorHandler(bmpError);
            }    
        }
    }else{
        [self BMP_removeObserver:observer forKeyPath:keyPath];
    }
}

- (void)BMP_removeObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath context:(nullable void *)context{
    if (!IsSystemClass(self.class)) {
        if ([self.bayMaxKVODelegate removeKVOInfoInMapsWithObserver:observer forKeyPath:keyPath]) {
            [self BMP_removeObserver:self.bayMaxKVODelegate forKeyPath:keyPath];
        }else{
            NSArray *callStackSymbolsArr = [NSThread callStackSymbols];
            NSString *reson = [NSString stringWithFormat:@"Cannot remove an observer %@ for the key path '%@' from %@ because it is not registered as an observer",observer,keyPath,NSStringFromClass(self.class) == nil?@"":NSStringFromClass(self.class)];
            BayMaxCatchError *bmpError = [BayMaxCatchError BMPErrorWithType:BayMaxErrorTypeKVO infos:@{
                                                                                                       BMPErrorKVO_Reason:reson
                                                                                                       }];
            if (_showDebugView) {
                [[BayMaxDebugView sharedDebugView]addErrorInfo:bmpError.errorInfos];
            }
            if (_errorHandler) {
                _errorHandler(bmpError);
            }
        }
    }else{
        [self BMP_removeObserver:observer forKeyPath:keyPath context:context];
    }
}

- (void)BMPKVO_dealloc{
    if (!IsSystemClass(self.class)) {
        NSString *value = (NSString *)objc_getAssociatedObject(self, KVOProtectorKey);
        if ([value isEqualToString:KVOProtectorValue]) {
            NSArray *keypaths = [self.bayMaxKVODelegate getAllKeypaths];
            if (keypaths.count>0) {
                NSArray *callStackSymbolsArr = [NSThread callStackSymbols];
                NSString *reson = [NSString stringWithFormat:@"An instance %@ was deallocated while key value observers were still registered with it. The Keypaths is:'%@'",self,[keypaths componentsJoinedByString:@","]];
                BayMaxCatchError *bmpError = [BayMaxCatchError BMPErrorWithType:BayMaxErrorTypeKVO infos:@{
                                                                                                           BMPErrorKVO_Reason:reson
                                                                                                           }];
                if (_showDebugView) {
                    [[BayMaxDebugView sharedDebugView]addErrorInfo:bmpError.errorInfos];
                }
                if (_errorHandler) {
                    _errorHandler(bmpError);
                }
            }
            [keypaths enumerateObjectsUsingBlock:^(NSString *keyPath, NSUInteger idx, BOOL * _Nonnull stop) {
                //错误信息
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
    if (yesOrNo == NO) {
        return [self BMP_scheduledTimerWithTimeInterval:ti target:aTarget selector:aSelector userInfo:userInfo repeats:yesOrNo];
    }else{
        if (!IsSystemClass([aTarget class])) {
            BayMaxTimerSubTarget *subtarget = [BayMaxTimerSubTarget targetWithTimeInterval:ti target:aTarget selector:aSelector userInfo:userInfo repeats:yesOrNo catchErrorHandler:^(BayMaxCatchError *error) {
                if (_showDebugView) {
                    [[BayMaxDebugView sharedDebugView]addErrorInfo:error.errorInfos];
                }
                if (_errorHandler) {
                    _errorHandler(error);
                }
            }];
            return [self BMP_scheduledTimerWithTimeInterval:ti target:subtarget selector:NSSelectorFromString(@"fireProxyTimer:") userInfo:userInfo repeats:yesOrNo];
        }else{
            return [self BMP_scheduledTimerWithTimeInterval:ti target:aTarget selector:aSelector userInfo:userInfo repeats:yesOrNo];
        }
    }
}

+ (NSTimer *)BMP_timerWithTimeInterval:(NSTimeInterval)ti target:(id)aTarget selector:(SEL)aSelector userInfo:(id)userInfo repeats:(BOOL)yesOrNo{
    if (yesOrNo == NO) {
        return [self BMP_timerWithTimeInterval:ti target:aTarget selector:aSelector userInfo:userInfo repeats:yesOrNo];
    }else{
        if (!IsSystemClass([aTarget class])) {
            BayMaxTimerSubTarget *subtarget = [BayMaxTimerSubTarget targetWithTimeInterval:ti target:aTarget selector:aSelector userInfo:userInfo repeats:yesOrNo catchErrorHandler:^(BayMaxCatchError *error) {
                if (_showDebugView) {
                    [[BayMaxDebugView sharedDebugView]addErrorInfo:error.errorInfos];
                }
                if (_errorHandler) {
                    _errorHandler(error);
                }        }];
            return [self BMP_timerWithTimeInterval:ti target:subtarget selector:NSSelectorFromString(@"fireProxyTimer:") userInfo:userInfo repeats:yesOrNo];
        }else{
            return [self BMP_timerWithTimeInterval:ti target:aTarget selector:aSelector userInfo:userInfo repeats:yesOrNo];
        }
    }   
}

@end

#pragma mark BayMaxProtector
@interface BayMaxProtector()

@end

@implementation BayMaxProtector

+ (void)load{
    IMP maping_ForwardingTarget_IMP = class_getMethodImplementation([BayMaxProtector class], @selector(BMP_mappingForwardingTargetForSelectorMethod));
    IMP KVO_IMP = class_getMethodImplementation([NSObject class], @selector(addObserver:forKeyPath:options:context:));
    IMP maping_Timer_IMP = class_getMethodImplementation([BayMaxProtector class], @selector(BMP_mappingTimerMethod));
    IMP notification_IMP = class_getMethodImplementation([NSNotificationCenter class], @selector(addObserver:selector:name:object:));
    IMP mapping_Containers_IMP = class_getMethodImplementation([BayMaxProtector class], @selector(BMP_mappingContainersMethods));
    impList = malloc(sizeof(struct IMPNode));
    impList->next = NULL;
    BMP_InsertIMPToList(impList, maping_ForwardingTarget_IMP);
    BMP_InsertIMPToList(impList, KVO_IMP);
    BMP_InsertIMPToList(impList, maping_Timer_IMP);
    BMP_InsertIMPToList(impList, notification_IMP);
    BMP_InsertIMPToList(impList, mapping_Containers_IMP);
}

+ (void)openProtectionsOn:(BayMaxProtectionType)protectionType{
    [self filterProtectionsOn:protectionType operation:YES];
}

+ (void)closeProtectionsOn:(BayMaxProtectionType)protectionType{
    [self filterProtectionsOn:protectionType operation:NO];
}

+ (void)filterProtectionsOn:(BayMaxProtectionType)protectionType operation:(BOOL)openOperation{
    IMP imp;
    if (protectionType > (1<<4)) {
        imp = class_getMethodImplementation([BayMaxProtector class], @selector(BMP_mappingContainersMethods));
        [self filterProtectionsOn:BayMaxProtectionTypeContainers protectionName:@"Containers" operation:openOperation imp:imp];
        protectionType -= (1<<4) ;
    }
    if (protectionType > (1<<3) && protectionType != BayMaxProtectionTypeContainers) {
        imp = class_getMethodImplementation([BayMaxProtector class], @selector(BMP_mappingTimerMethod));
        [self filterProtectionsOn:BayMaxProtectionTypeTimer protectionName:@"Timer" operation:openOperation imp:imp];
        protectionType -= (1<<3) ;
    }
    switch (protectionType) {
        case BayMaxProtectionTypeUnrecognizedSelector:
            imp = class_getMethodImplementation([BayMaxProtector class], @selector(BMP_mappingForwardingTargetForSelectorMethod));
            [self filterProtectionsOn:protectionType protectionName:@"UnrecognizedSelector" operation:openOperation imp:imp];
            break;
            
        case BayMaxProtectionTypeKVO:
            imp = class_getMethodImplementation([NSObject class], @selector(addObserver:forKeyPath:options:context:));
            [self filterProtectionsOn:protectionType protectionName:@"KVO" operation:openOperation imp:imp];
            break;
        case BayMaxProtectionTypeNotification:
            imp = class_getMethodImplementation([NSNotificationCenter class], @selector(addObserver:selector:name:object:));
            [self filterProtectionsOn:protectionType protectionName:@"Notification" operation:openOperation imp:imp];
            break;
        case BayMaxProtectionTypeTimer:
            imp = class_getMethodImplementation([BayMaxProtector class], @selector(BMP_mappingTimerMethod));
            [self filterProtectionsOn:protectionType protectionName:@"Timer" operation:openOperation imp:imp];
            break;
        case BayMaxProtectionTypeContainers:
            imp = class_getMethodImplementation([BayMaxProtector class], @selector(BMP_mappingContainersMethods));
            [self filterProtectionsOn:protectionType protectionName:@"Containers" operation:openOperation imp:imp];
            break;
        case BayMaxProtectionTypeAll:
            [self filterProtectionsOn:BayMaxProtectionTypeUnrecognizedSelector protectionName:@"UnrecognizedSelector" operation:openOperation imp:class_getMethodImplementation([BayMaxProtector class], @selector(BMP_mappingForwardingTargetForSelectorMethod))];
            [self filterProtectionsOn:BayMaxProtectionTypeKVO protectionName:@"KVO" operation:openOperation imp:class_getMethodImplementation([NSObject class], @selector(addObserver:forKeyPath:options:context:))];
            [self filterProtectionsOn:BayMaxProtectionTypeNotification protectionName:@"Notification" operation:openOperation imp:class_getMethodImplementation([NSNotificationCenter class], @selector(addObserver:selector:name:object:))];
            [self filterProtectionsOn:BayMaxProtectionTypeTimer protectionName:@"Timer" operation:openOperation imp:class_getMethodImplementation([BayMaxProtector class], @selector(BMP_mappingTimerMethod))];
    }
}

+ (void)filterProtectionsOn:(BayMaxProtectionType)protectionType protectionName:(NSString *)protectionName operation:(BOOL)openOperation imp:(IMP)imp{
    if (openOperation) {//开启
        if (BMP_ImpExistInList(impList, imp)) {//存在该imp，说明没有被交换，此时应该进行交换
            NSLog(@"开启保护:%@",protectionName);
            [self openProtectionsOn:protectionType catchErrorHandler:nil];
        }else{//说明此时已经被交换过了，不需要再次进行交换，空处理即可。
            NSString * duplicateProtection = [NSString stringWithFormat:@"[%@] Is Already In The Protection State And Do not Need To Open This Protection mode again",protectionName];
            [[BayMaxDebugView sharedDebugView]addErrorInfo:@{@"waring":duplicateProtection}];
        }
    }else{             //关闭防护
        if (!BMP_ImpExistInList(impList, imp)) {//如果此时不存在该imp,说明发生过方法交换，此时应该进行再次交换，已关闭崩溃保护
            NSLog(@"关闭保护:%@",protectionName);
            [self openProtectionsOn:protectionType catchErrorHandler:nil];
        }else{//说明该方法没有被交换，即没有列在保护名单里，空处理即可
            NSString * duplicateClose = [NSString stringWithFormat:@"[%@] Is Not In The Protection State Before And Don't Need To Close This Protection Again",protectionName];
            [[BayMaxDebugView sharedDebugView]addErrorInfo:@{@"waring":duplicateClose}];
        }
    }
}

+ (void)openProtectionsOn:(BayMaxProtectionType)protectionType catchErrorHandler:(void(^_Nullable)(BayMaxCatchError * _Nullable error))errorHandler{
    _errorHandler = errorHandler;
    if (protectionType > (1<<4)) {
        [self exchangeMethodWithType:BayMaxProtectionTypeContainers];
        protectionType -= (1<<4);
    }
    if (protectionType > (1<<3) && protectionType != BayMaxProtectionTypeContainers) {
        [self exchangeMethodWithType:BayMaxProtectionTypeTimer];
        protectionType -= (1<<3) ;
    }
    switch ((long)protectionType) {
        case BayMaxProtectionTypeUnrecognizedSelector:
        case BayMaxProtectionTypeKVO:
        case BayMaxProtectionTypeNotification:
        case BayMaxProtectionTypeTimer:
        case BayMaxProtectionTypeContainers:
        case BayMaxProtectionTypeAll:
        {
            [self exchangeMethodWithType:protectionType];
        }
            break;
        case 3:
        {
            [self exchangeMethodWithType:BayMaxProtectionTypeUnrecognizedSelector];
            [self exchangeMethodWithType:BayMaxProtectionTypeKVO];
        }
            break;
        case 5:
        {
            [self exchangeMethodWithType:BayMaxProtectionTypeUnrecognizedSelector];
            [self exchangeMethodWithType:BayMaxProtectionTypeNotification];
        }
            break;
        case 6:
        {
            [self exchangeMethodWithType:BayMaxProtectionTypeKVO];
            [self exchangeMethodWithType:BayMaxProtectionTypeNotification];
        }
            break;
        case 7:
        {
            [self exchangeMethodWithType:BayMaxProtectionTypeUnrecognizedSelector];
            [self exchangeMethodWithType:BayMaxProtectionTypeKVO];
            [self exchangeMethodWithType:BayMaxProtectionTypeNotification];
        }
            break;
    }
}

+ (void)exchangeMethodWithType:(BayMaxProtectionType)protectionType{
    switch (protectionType) {
        case BayMaxProtectionTypeUnrecognizedSelector:
        {
            BMP_EXChangeInstanceMethod([NSObject class], @selector(forwardingTargetForSelector:), [NSObject class], @selector(BMP_forwardingTargetForSelector:));
            BMP_EXChangeInstanceMethod([BayMaxProtector class], @selector(BMP_mappingForwardingTargetForSelectorMethod), [BayMaxProtector class], @selector(BMP_excMappingForwardingTargetForSelectorMethod));
        }
            break;
    case BayMaxProtectionTypeKVO:
        {
            BMP_EXChangeInstanceMethod([NSObject class], @selector(addObserver:forKeyPath:options:context:), [NSObject class], @selector(BMP_addObserver:forKeyPath:options:context:));
            BMP_EXChangeInstanceMethod([NSObject class], @selector(removeObserver:forKeyPath:), [NSObject class], @selector(BMP_removeObserver:forKeyPath:));
            BMP_EXChangeInstanceMethod([NSObject class], @selector(removeObserver:forKeyPath:context:), [NSObject class], @selector(BMP_removeObserver:forKeyPath:context:));
            BMP_EXChangeInstanceMethod([NSObject class], NSSelectorFromString(@"dealloc"), [NSObject class], @selector(BMPKVO_dealloc));
        }
        break;
        
    case BayMaxProtectionTypeNotification:
        {
            BMP_EXChangeInstanceMethod([NSNotificationCenter class], @selector(addObserver:selector:name:object:), [NSNotificationCenter class], @selector(BMP_addObserver:selector:name:object:));
            BMP_EXChangeInstanceMethod([UIViewController class], NSSelectorFromString(@"dealloc"), [UIViewController class], NSSelectorFromString(@"BMP_dealloc"));
        }
        break;
    case BayMaxProtectionTypeTimer:
        {
            BMP_EXChangeClassMethod([NSTimer class], @selector(scheduledTimerWithTimeInterval:target:selector:userInfo:repeats:),  @selector(BMP_scheduledTimerWithTimeInterval:target:selector:userInfo:repeats:));
            BMP_EXChangeClassMethod([NSTimer class], @selector(timerWithTimeInterval:target:selector:userInfo:repeats:), @selector(BMP_timerWithTimeInterval:target:selector:userInfo:repeats:));
            BMP_EXChangeInstanceMethod([BayMaxProtector class], @selector(BMP_mappingTimerMethod), [BayMaxProtector class], @selector(BMP_excMappingTimerMethod));
        }
        break;
            
    case BayMaxProtectionTypeContainers:
    {
        /*containes*/
        [BayMaxContainers BMPExchangeContainersMethodsWithCatchErrorHandler:^(BayMaxCatchError *error) {
            if (_showDebugView) {
                [[BayMaxDebugView sharedDebugView]addErrorInfo:error.errorInfos];
            }
            if (_errorHandler) {
                _errorHandler(error);
            }
        }];
        BMP_EXChangeInstanceMethod([BayMaxProtector class], @selector(BMP_mappingContainersMethods), [BayMaxProtector class], @selector(BMP_excMappingContainersMethods));
        
    }
        break;
    case BayMaxProtectionTypeAll:
        {
            BMP_EXChangeInstanceMethod([NSObject class], @selector(forwardingTargetForSelector:), [NSObject class], @selector(BMP_forwardingTargetForSelector:));
            BMP_EXChangeInstanceMethod([self class], @selector(BMP_mappingForwardingTargetForSelectorMethod), [self class], @selector(BMP_excMappingForwardingTargetForSelectorMethod));
            BMP_EXChangeInstanceMethod([NSObject class], @selector(addObserver:forKeyPath:options:context:), [NSObject class], @selector(BMP_addObserver:forKeyPath:options:context:));
            BMP_EXChangeInstanceMethod([NSObject class], @selector(removeObserver:forKeyPath:), [NSObject class], @selector(BMP_removeObserver:forKeyPath:));
            BMP_EXChangeInstanceMethod([NSObject class], @selector(removeObserver:forKeyPath:context:), [NSObject class], @selector(BMP_removeObserver:forKeyPath:context:));
            BMP_EXChangeInstanceMethod([NSObject class], NSSelectorFromString(@"dealloc"), [NSObject class], @selector(BMPKVO_dealloc));
            BMP_EXChangeInstanceMethod([NSNotificationCenter class], @selector(addObserver:selector:name:object:), [NSNotificationCenter class], @selector(BMP_addObserver:selector:name:object:));
            BMP_EXChangeInstanceMethod([UIViewController class], NSSelectorFromString(@"dealloc"), [UIViewController class], NSSelectorFromString(@"BMP_dealloc"));
            BMP_EXChangeClassMethod([NSTimer class], @selector(scheduledTimerWithTimeInterval:target:selector:userInfo:repeats:),  @selector(BMP_scheduledTimerWithTimeInterval:target:selector:userInfo:repeats:));
            BMP_EXChangeClassMethod([NSTimer class], @selector(timerWithTimeInterval:target:selector:userInfo:repeats:), @selector(BMP_timerWithTimeInterval:target:selector:userInfo:repeats:));
            BMP_EXChangeInstanceMethod([self class], @selector(BMP_mappingTimerMethod), [self class], @selector(BMP_excMappingTimerMethod));
            /*containers*/
            [BayMaxContainers BMPExchangeContainersMethodsWithCatchErrorHandler:^(BayMaxCatchError *error) {
                if (_showDebugView) {
                    [[BayMaxDebugView sharedDebugView]addErrorInfo:error.errorInfos];
                }
                if (_errorHandler) {
                    _errorHandler(error);
                }
            }];
            BMP_EXChangeInstanceMethod([BayMaxProtector class], @selector(BMP_mappingContainersMethods), [BayMaxProtector class], @selector(BMP_excMappingContainersMethods));
        }
        break;
    }
}

+ (void)ignoreProtectionsOnClassesWithPrefix:(NSArray *_Nonnull)ignorePrefixes{
    _ignorePrefixes = ignorePrefixes;
}

+ (void)showDebugView{
    _showDebugView = YES;
    [BayMaxDebugView sharedDebugView].hidden = NO;
}

+ (void)hideDebugView{
    _showDebugView = NO;
    [BayMaxDebugView sharedDebugView].hidden = YES;
}


#pragma mark libobjc.A.dylib IMP映射
/**
 NSObject ForwardingTargetForSelector方法的映射
 */
- (void)BMP_mappingForwardingTargetForSelectorMethod{
}

- (void)BMP_excMappingForwardingTargetForSelectorMethod{
}
/**
 NSTimer  scheduledTimerWithTimeInterval:target:selector:userInfo:repeats:方法的映射
 */
- (void)BMP_mappingTimerMethod{
}

- (void)BMP_excMappingTimerMethod{
}

#pragma mark Containers IMP映射
- (void)BMP_mappingContainersMethods{
}

- (void)BMP_excMappingContainersMethods{
}

@end

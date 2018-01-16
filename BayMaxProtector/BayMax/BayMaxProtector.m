//
//  NSObject+UNRecognizedSelHandler.m
//  SpaceHome
//
//  Created by ccSunday on 2017/3/23.
//
//
#import <UIKit/UIKit.h>
#import <objc/runtime.h>
#import "BayMaxProtector.h"
#import "BayMaxCrashHandler.h"
#import "BayMaxKVODelegate.h"

static inline void MethodEXChange(Class _originalClass ,SEL _originalSel,Class _targetClass ,SEL _targetSel){
    Method methodOriginal = class_getInstanceMethod(_originalClass, _originalSel);
    Method methodNew = class_getInstanceMethod(_targetClass, _targetSel);
    method_exchangeImplementations(methodOriginal, methodNew);
}

struct ErrorBody{    
    const char *function_name;
    const char *function_class;
};

typedef struct ErrorBody ErrorInfos;
static ErrorInfos errors;
static inline ErrorInfos ErrorInfosMake(const char *function_class,const char *function_name)
{
    ErrorInfos errorInfos;
    errorInfos.function_name = function_name;
    errorInfos.function_class = function_class;
    return errorInfos;
}

static inline int DynamicAddMethodIMP(id self,SEL _cmd,...){
#ifdef DEBUG
#else
#endif
    return 0;
}

#pragma mark UNRecognizedSelHandler
@interface NSObject (UNRecognizedSelHandler)
@end

@implementation NSObject (UNRecognizedSelHandler)
static NSString *const ErrorClassName = @"BMP_ErrorClassName";
static NSString *const ErrorFunctionName = @"BMP_ErrorFunctionName";
static NSString *const ErrorViewController = @"BMP_ErrorViewController";

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
    if (![self isPrivateClass]) {
        __weak typeof(self) weakSelf = self;
        objc_setAssociatedObject(self, KVOProtectorKey, KVOProtectorValue, OBJC_ASSOCIATION_RETAIN);
        [self.bayMaxKVODelegate addKVOInfoToMapsWithObserver:observer forKeyPath:keyPath options:options context:context success:^{
            [weakSelf BMP_addObserver:weakSelf.bayMaxKVODelegate forKeyPath:keyPath options:options context:context];
        } failure:^(NSError *error) {
            NSLog(@"BMPError_KVO_Details:\n%@",error.description);
            
        }];
    }else{
        [self BMP_addObserver:observer forKeyPath:keyPath options:options context:context];
    }
}

- (void)BMP_removeObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath{
    if (![self isPrivateClass]) {
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
    if (![self isPrivateClass]) {
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

#pragma mark 以下面这些为前缀的，将不会对其进行kvo保护，默认这些为系统行为，由系统进行管理。
- (BOOL)isPrivateClass{
    BOOL isPrivate = NO;
    NSString *className = NSStringFromClass(self.class);
    if ([className containsString:@"_UI"] ||
        [className containsString:@"_NS"]||
        [className hasPrefix:@"_"]||
        [className hasPrefix:@"__"]||
        [className hasPrefix:@"NS"]||
        [className hasPrefix:@"CA"]||
        [className hasPrefix:@"UI"]) {
        isPrivate = YES;
    }
    return isPrivate;
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

@interface BayMaxProtector()

@end

@implementation BayMaxProtector

+ (void)openProtectionsOn:(BayMaxProtectionType)protectionType{
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
          MethodEXChange([NSObject class], @selector(forwardingTargetForSelector:), [NSObject class], @selector(BMP_forwardingTargetForSelector:));
        }
            break;
    case BayMaxProtectionTypeKVO:
        {
            MethodEXChange([NSObject class], @selector(addObserver:forKeyPath:options:context:), [NSObject class], @selector(BMP_addObserver:forKeyPath:options:context:));
            MethodEXChange([NSObject class], @selector(removeObserver:forKeyPath:), [NSObject class], @selector(BMP_removeObserver:forKeyPath:));
            MethodEXChange([NSObject class], NSSelectorFromString(@"dealloc"), [NSObject class], @selector(BMPKVO_dealloc));
        }
        break;
        
    case BayMaxProtectionTypeNotification:
        {
            MethodEXChange([NSNotificationCenter class], @selector(addObserver:selector:name:object:), [NSNotificationCenter class], @selector(BMP_addObserver:selector:name:object:));
            MethodEXChange([UIViewController class], NSSelectorFromString(@"dealloc"), [self class], NSSelectorFromString(@"BMP_dealloc"));
        }
        break;
    case BayMaxProtectionTypeTimer:
        {
            
        }
        break;
    case BayMaxProtectionTypeAll:
        {
            MethodEXChange([NSObject class], @selector(forwardingTargetForSelector:), [NSObject class], @selector(BMP_forwardingTargetForSelector:));
            MethodEXChange([NSObject class], @selector(addObserver:forKeyPath:options:context:), [NSObject class], @selector(BMP_addObserver:forKeyPath:options:context:));
            MethodEXChange([NSObject class], @selector(removeObserver:forKeyPath:), [NSObject class], @selector(BMP_removeObserver:forKeyPath:));
            MethodEXChange([NSObject class], NSSelectorFromString(@"dealloc"), [NSObject class], @selector(BMPKVO_dealloc));
            MethodEXChange([NSNotificationCenter class], @selector(addObserver:selector:name:object:), [NSNotificationCenter class], @selector(BMP_addObserver:selector:name:object:));
            MethodEXChange([UIViewController class], NSSelectorFromString(@"dealloc"), [self class], NSSelectorFromString(@"BMP_dealloc"));
        }
        break;
   
        default:
            break;
    }
    
}

@end

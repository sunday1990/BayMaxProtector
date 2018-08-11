> BayMaxProtector is a framework that can block common crashes , thereby enhancing your App's stability. Not only that, but you can also use the downgrade mechanism it provides to reduce a page that has a problem to a corresponding web page, So as not to affect the continuation of the business.

> 这是一个可以对常见崩溃进行拦阻，从而增强你App稳定性的框架，不仅如此，你还可以使用它提供的降级机制，将发生问题的页面降为对应的web页面，从而不影响业务的继续。

#### BayMax思路来自网易团队：[大白健康系统--iOS APP运行时Crash自动修复系统](https://neyoufan.github.io/2017/01/13/ios/BayMax_HTSafetyGuard/)

#### 注意：需要对BayMaxContainer文件设置非arc支持（-fno-objc-arc）

#### 2.0主要是对[1.0](https://juejin.im/post/5a65b8056fb9a01ca87217fb)的升级与改造。
## 2月26日新增功能
#### 新增容器类防护，针对NSArray/NSMutableArray/NSDictionary/NSMutableDictionary/NSString/NSMutableString进行崩溃保护。

## 一、新增功能
#### 1、增加BayMaxDebugView
`BayMaxDebugView`可以在开发中更直观的展示它所拦截到的异常，会展示捕获异常的数目，并且可以跟随手指移动，点击后可以展示错误的详细信息。收起后，错误信息清零，长按错误信息可以复制分享。

#### 2、新增自定义IMP方法链表，支持IMP的插入与查找功能
该功能主要用来帮助判断某些系统方法有没有被替换。
```
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
/*
递归判断IMP链表中有没有此元素。
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
```
#### 3、增加关闭防护的功能
可以在任意页面，关闭或者打开防护功能，并且可以对重复操作进行过滤，重复的添加或者移除，会作为异常显示在`debugView`中。
```
1、保存系统原有的IMP
static IMPlist impList;
+ (void)load{
    //maping_ForwardingTarget_IMP为ForwardingTarget方法的映射
    IMP maping_ForwardingTarget_IMP = class_getMethodImplementation([BayMaxProtector class], @selector(BMP_mappingForwardingTargetForSelectorMethod));
    //maping_Timer_IMP为原有timer方法的映射
    IMP maping_Timer_IMP = class_getMethodImplementation([BayMaxProtector class], @selector(BMP_mappingTimerMethod));
    IMP KVO_IMP = class_getMethodImplementation([NSObject class], @selector(addObserver:forKeyPath:options:context:));
    IMP notification_IMP = class_getMethodImplementation([NSNotificationCenter class], @selector(addObserver:selector:name:object:));

    impList = malloc(sizeof(struct IMPNode));
    impList->next = NULL;

    BMP_InsertIMPToList(impList, maping_ForwardingTarget_IMP);
    BMP_InsertIMPToList(impList, KVO_IMP);
    BMP_InsertIMPToList(impList, maping_Timer_IMP);
    BMP_InsertIMPToList(impList, notification_IMP);
}

2、根据操作的protectionType获取对应的IMP，然后判断该IMP在不在原有的impList中，在的话，说明该防护之前没有开启过，不在的话，说明该防护之前开启过。
    if (!BMP_ImpExistInList(impList, imp)) {
        NSLog(@"关闭保护");
        //再执行一次交换操作
        [self openProtectionsOn:protectionType catchErrorHandler:nil];
    }else{//说明该方法没有被交换，即没有列在保护名单里，空处理即可
        NSString * duplicateClose = [NSString stringWithFormat:@"[%@] Is Not In The Protection State Before And Don't Need To Close This Protection Again",protectionName];
        [[BayMaxDebugView sharedDebugView]addErrorInfo:@{@"waring":duplicateClose}];
    }

```
#### 4、增加针对`libobjc.A.dylib`部分方法的方法映射

```
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

```
#### 5、增加一系列测试用例

## 二、原有功能
#### 1、防止`unrecognizedSelector`类型的崩溃

#### 2、防止`kvo`类型的崩溃
如keypath重复监听、移除了未注册的观察者、移除了不存在的keypath，观察者未移除
#### 3、防止`Timer`类型的错误
退出页面时，`timer`可以自动`invalidate`
#### 4、防止`NSNotification`类型的错误
在未移除监听者的时候，自动帮你移除监听者
#### 5、支持页面自动降级
可以通过配置在页面发生`unrecognizedSelector`类型错误的时候，自动降级为对应的web页面，自动降级又分两种，一种是能拿到参数，然后拼成一个完整的url传给web，另一种是发生在`viewdidload`中，且接收错误消息的对象不是视图控制器，这时候拿不到参数，只能拿到对应的url。】
#### 6、支持页面主动降级
在某些页面发生业务逻辑错误时，比如粗心的把价格单位“元”写成了“万元”,可以手动的将该页面将为对应的web页面，本质上是向该页面发送一个它不能够响应的消息，然后再走自动降级的逻辑。

## 三、安装
* 手动：将`BayMaxProtector`下的所有文件拖入项目
* `CocoaPod`:`podfile`加入 `pod 'BayMaxProtector'`

## 四、使用
#### 1、开启防护
```
//开启全部防护
[BayMaxProtector openProtectionsOn:BayMaxProtectionTypeAll catchErrorHandler:^(BayMaxCatchError * _Nullable error) {
//do your business
}];
//开启某一防护
[BayMaxProtector openProtectionsOn:BayMaxProtectionTypeUnrecognizedSelector];
//开启组合防护
[BayMaxProtector openProtectionsOn:BayMaxProtectionTypeUnrecognizedSelector|BayMaxProtectionTypeTimer];
//设置白名单
[BayMaxProtector ignoreProtectionsOnClassesWithPrefix:@[@"AV"]];
```
#### 2、关闭防护
```
//同上
[BayMaxProtector closeProtectionsOn:BayMaxProtectionTypeAll];

```
#### 3、显示DebugView
```
[BayMaxProtector showDebugView];
```
#### 4、隐藏DebugView
```
[BayMaxProtector hideDebugView];
```
#### 5、页面降级（可选）
实现相对应的代理方法`BayMaxDegradeAssistDelegate`与数据源协议`BayMaxDegradeAssistDataSource`

## 五、在swift环境下的表现
`BayMax`在`swift`环境下绝大部分功能仍然可用，但是如果在`viewdidload`方法中发生`unrecognizedSelector`类型的错误，这时候获取当前显示的视图控制器存在问题，从而会影响自动降级相关的流程，其他的暂时没发现问题，如果使用中有新的问题，请留言。

## 六、效果展示
#### 1、unrecognizedSelector防护

![unrecognizedSelector防护](https://user-gold-cdn.xitu.io/2018/2/2/16155eb1683a9422?w=298&h=504&f=gif&s=448254)

#### 2、unrecognizedSelector-viewdidload防护

![unrecognizedSelector-viewdidload防护](https://user-gold-cdn.xitu.io/2018/2/2/16155eb7dd4680b3?w=298&h=504&f=gif&s=90331)

#### 3、TimerErrorBlock
![TimerErrorBlock](https://user-gold-cdn.xitu.io/2018/2/2/16155ec1e927c2b9?w=298&h=504&f=gif&s=140941)

#### 4、KVOErrorBlock

![KVOErrorBlock](https://user-gold-cdn.xitu.io/2018/2/2/16155ec986e2a849?w=298&h=508&f=gif&s=92752)
#### 5、自动降级

![自动降级](https://user-gold-cdn.xitu.io/2018/2/2/16155ed317baefc5?w=298&h=508&f=gif&s=450994)

#### 6、手动降级

![手动降级](https://user-gold-cdn.xitu.io/2018/2/2/16155eda25a9e5d3?w=298&h=508&f=gif&s=798726)


GitHub下载地址：[BayMaxProtector](https://github.com/sunday1990/BayMaxProtector)

#### 欢迎加入`BayMaxProtector`交流群，群聊号码：466377115

欢迎大家star!







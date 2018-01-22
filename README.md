# BayMaxProtector
Crash protector -take care of your application like BayMax

## 一、what can BayMaxProtector do?
1、`BayMaxProtector` 可以提高你App的稳定性，减少因为常见错误而引发的崩溃，目前支持的保护类型有四种，分别是`UnrecognizedSelector`、`KVO（KVO重复添加、移除、或dealloc时未移除observer）、NSNotification（dealloc时未移除）`、`NSTimer（去除了timer对target的强引用，target可以自由释放而不会产生崩溃，同时timer可以自动invalid）`这四种情况。容器类的考虑到已经有较为成熟的框架，便没有加进来，如果后期有需要的话，再加入。
2、`BayMaxProtector`不仅为你的应用提供崩溃保护的功能，并且还通过`BayMaxDegradeAssist`提供了一套页面降级机制，按照该套机制的规则与约定，可以实现页面自动降级为对应的`H5`页面，也可以实现页面的手动降级。所谓自动降级，是指在程序发生`UnrecognizedSelector`错误时，会从配置中将该页面对应的`url`和`params(注意：如果viewdidload方法中发生错误，并且消息接受者不是视图控制器的话，获取不到参数，其他情况都可以（如网络null错误、解析错误、数据源model混乱等）)`,传给外界，外界可以通过这个展示对应的`H5`页面。手动降级是指程序本来并没有发生`UnrecognizedSelector`相关错误，但是由于代码业务逻辑发生错误，我们需要强制换成对应的`H5`页面，通过`BayMaxDegradeAssist`提供的接口，可以轻松地做到这些，这样就能够避免传统的防崩溃机制导致的空转状态，所谓空转是指程序不崩溃，但是无法继续进行接下来的业务逻辑。
3、`BayMaxProtector`将发生的错误封装为一个`BayMaxCatchError`对象，这个对象会根据不同的错误类型，将对应错误的描述信息打包，并通过统一的方式将错误信息回调给外界，外界可以对错误进行分类处理。
4、其他功能你可以自己探索
## 二、how to use?
1、 手动方式：将`BayMax`文件夹下的内容拖入拖入项目。
2、 `Appdelegate` 中设置你想要保护的类型(建议debug模式下不要开启)，保护的类型是枚举类型，支持枚举的或运算。
```
示例：
一、带错误回调的所有类型
[BayMaxProtector openProtectionsOn:BayMaxProtectionTypeAll catchErrorHandler:^(BayMaxCatchError * _Nullable error) {
    if (error.errorType == BayMaxErrorTypeUnrecognizedSelector) {
        NSLog(@"ErrorUnRecognizedSelInfos:%@",error.errorInfos);

    }else if (error.errorType == BayMaxErrorTypeTimer){
        NSLog(@"ErrorTimerinfos:%@",error.errorInfos);


    }else if (error.errorType == BayMaxErrorTypeKVO){
        NSLog(@"ErrorKVOinfos:%@",error.errorInfos);

    }else{
        NSLog(@"infos:%@",error.errorInfos);
    }
}];

二、指定某一类型
[BayMaxProtector openProtectionsOn:BayMaxProtectionTypeUnrecognizedSelector];


三、组合类型
[BayMaxProtector openProtectionsOn:BayMaxProtectionTypeNotification|BayMaxProtectionTypeTimer];


四、过滤带有指定前缀的类
[BayMaxProtector ignoreProtectionsOnClassesWithPrefix:@[@"UI",@"CA"]];

```
3、如何进行页面降级？
```
1、引入`BayMaxDegradeAssist.h`头文件。
2、设置数据源（BayMaxDegradeAssistDataSource）与事件回调代理（BayMaxDegradeAssistDelegate）
3、实现数据源代理BayMaxDegradeAssistDataSource，其中要实现四个`required`方法和一个`optional`方法
@required:
//共有多少组H5-iOS对应关系,一个视图控制器对应一组关系
- (NSInteger)numberOfRelations;
//第index组iOS试图控制器的名字
- (NSString *)nameOfViewControllerAtIndex:(NSInteger)index;
//第index组下试图控制器对应的url
- (NSString *)urlOfViewControllerAtIndex:(NSInteger)index;
//第index组下H5与iOS之间参数的对应关系集合
- (NSArray<NSDictionary<NSString * , NSString *> *> *)correspondencesBetweenH5AndIOSParametersAtIndex:(NSInteger)index;

@optional://用来实现手动降级
//手动降级的某些页面，处理后，最终还是会走BayMaxDegradeAssistDelegate中的自动降级相关方法
- (NSArray<NSDictionary<NSString * , NSString *> *> *)correspondencesBetweenH5AndIOSParametersAtIndex:(NSInteger)index;

4、实现BayMaxDegradeAssistDelegate，其中有两个可选方法，在这里可以获取到发生错误的视图控制器实例或者类，以及该页面对应的带参数的完整URL或者不带参数的URL，和配置中该视图控制器对应的所有信息。外界可以针对这两种情况分别处理,由于手动降级最终还是走的自动降级，所以只需要处理自动降级的代理事件即可。

// 非viewdidload方法出错，可以获取当前页面对应的H5完整url（带参数），然后进行页面降级，展示自己的webview
- (void)autoDegradeInstanceOfViewController:(UIViewController *)degradeVC ifErrorHappensInProcessExceptViewDidLoadWithReplacedCompleteURL:(NSString *)completeURL relation:(NSDictionary *)relation;

//在viewdidload方法中出错，可以获取出错页面对应的不完整url（不带参数），然后进行页面降级，展示自己的webview
- (void)autoDegradeClassOfViewController:(Class)degradeCls ifErrorHappensInViewDidLoadProcessWithReplacedURL:(NSString *)URL relation:(NSDictionary *)relation;

5、流程：启动App->请求配置或者从缓存中读取配置->调用`BayMaxDegradeAssist`的`reloadRelations`方法

```
## 三、why BayMax Can do This?
主要参考了网易的健康系统，踩了一些坑，加了一些新的东西进来，然而目前还有很多需要优化的地方，会不断完善。
列一下目前需要解决的问题，希望您能够提供宝贵的建议。
1、如何自动识别出系统类，并对这些类进行自动的过滤。
2、页面降级中针对发生在`viewDidLoad`方法中的`unrecognizedSelector`错误，如果消息接受者不是视图控制器，该如何获取这个视图控制器实例。
3、页面降级如何处理回调？
4、其他

如果您有兴趣一起做或者有好的建议，可以加我QQ：`935143023`


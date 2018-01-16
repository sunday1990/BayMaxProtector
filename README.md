# BayMaxProtector
Crash protector -take care of your application like BayMax

## 一、what can I do?
1、`BayMaxProtector`可以提高你App的稳定性，减少因为常见错误而引发的崩溃，目前支持的保护类型有三种（`timer`尚未加入），分别是`UnrecognizedSelector`、`KVO（KVO重复添加、移除、或dealloc时未移除observer）、NSNotification`这三种情况。
2、其中对于`UnrecognizedSelector`引起的错误，你可以在`BayMaxCrashHandler`类中获取到相对应的错误信息，上传服务器，同时你也可以在这个地方发挥想象力，做一套完善的页面自动降级机制。
3、其他功能你可以自己探索

## 二、how to use?
1、 将`BayMax`文件夹（`BayMaxProtector、BayMaxKVODelegate、BayMaxCrashHandler三个类`）拖入项目
2、 `Appdelegate`中设置你想要保护的类型(建议debug模式下不要开启)
```
/*所有类型*/
[BayMaxProtector openProtectionsOn:BayMaxProtectionTypeAll];

/*UnrecognizedSelector类型*/
[BayMaxProtector openProtectionsOn:BayMaxProtectionTypeUnrecognizedSelector];

/*组合类型*/
[BayMaxProtector openProtectionsOn:BayMaxProtectionTypeNotification||BayMaxProtectionTypeTimer];

```
## 三、why BayMax Can do This?
原理分析还未完善，稍后奉上，参考了网易的健康系统，并踩了一些坑。



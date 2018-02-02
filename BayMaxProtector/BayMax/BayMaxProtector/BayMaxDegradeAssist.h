//
//  BayMaxDegradeAssist.h
//  BayMaxProtector
//
//  Created by ccSunday on 2018/1/19.
//  Copyright © 2018年 ccSunday. All rights reserved.
//
/*
    页面降级辅助类：保存/刷新对应关系、查找对应关系、转换完整url。
    支持手动降级与自动降级。
    其中自动降级只针对unrecognizedSelector与容器类错误【暂未加入】进行降级处理。
 */

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
/*vc*/
FOUNDATION_EXPORT NSString *const BMPAssistKey_VC;
/*params:H5-iOS参数对应关系*/
FOUNDATION_EXPORT NSString *const BMPAssistKey_Params;
/*url*/
FOUNDATION_EXPORT NSString *const BMPAssistKey_Url;

@class BayMaxCatchError;
@protocol BayMaxDegradeAssistProtocol
- (void)handleError:(BayMaxCatchError *)error;
@end

@protocol BayMaxDegradeAssistDataSource
@required;
/**
 共有多少组H5-iOS对应关系
 一个视图控制器对应一组关系
 @return    关系数目
 */
- (NSInteger)numberOfRelations;

/**
 第index组iOS试图控制器的名字

 @param index 第几组
 @return iOS视图控制器名字
 */
- (NSString *)nameOfViewControllerAtIndex:(NSInteger)index;

/**
 第index组下试图控制器对应的url

 @param index 第几组
 @return 对应的url
 */
- (NSString *)urlOfViewControllerAtIndex:(NSInteger)index;

/**
 第index组下H5与iOS之间参数的对应关系集合
 对应关系中key为H5字段名，value为iOS字段名
 @param index 第几组
 @return 对应关系数组@[
                     @{H5Param:iOSParam},
                     @{H5Param:iOSParam},
                     @{H5Param:iOSParam},
                     ]
 */
- (NSArray<NSDictionary<NSString * , NSString *> *> *)correspondencesBetweenH5AndIOSParametersAtIndex:(NSInteger)index;

@optional
/**
 主动降级某些页面，处理后，最终还是会走BayMaxDegradeAssistDelegate中的自动降级相关方法
 注意：主动降级也就是让向该对象发送一个不能响应的消息，然后走消息转发流程
 @return 视图控制器类名数组
 */
- (NSArray *)viewControllersToDegradeInitiative;

@end

@protocol BayMaxDegradeAssistDelegate

/**
 自动降级：
 非viewdidload方法出错，可以获取当前页面对应的H5完整url（带参数），然后进行页面降级

 @param degradeVC 需要降级的视图控制器实例
 @param completeURL 完整URL
 @param relation 该视图控制器对应的相关信息
 */
- (void)autoDegradeInstanceOfViewController:(UIViewController *)degradeVC ifErrorHappensInProcessExceptViewDidLoadWithReplacedCompleteURL:(NSString *)completeURL relation:(NSDictionary *)relation;

/**
 自动降级：
 在viewdidload方法中出错，可以获取出错页面对应的不完整url（不带参数），然后进行页面降级

 @param degradeCls 需要降级的视图控制器类
 @param URL 不带参数的url
 @param relation 该视图控制器对应的相关信息
 */
- (void)autoDegradeClassOfViewController:(Class)degradeCls ifErrorHappensInViewDidLoadProcessWithReplacedURL:(NSString *)URL relation:(NSDictionary *)relation;

@end

@interface BayMaxDegradeAssist : NSObject<BayMaxDegradeAssistProtocol>

@property (nonatomic, strong) NSMutableArray<NSDictionary *> *relations;

@property (nonatomic, assign) id<BayMaxDegradeAssistDataSource>degradeDatasource;

@property (nonatomic, assign) id<BayMaxDegradeAssistDelegate>degradeDelegate;

/**
 获取Assist单例

 @return Assist单例
 */
+ (instancetype)Assist;

/**
 获取跟Class的对应关系

 @param cls 视图控制器类
 @return 对应关系的字典，字段有控制器名称（NSString *）、参数对应关系（NSArray *）、对应的url（NSString *）

 */
- (NSDictionary *)relationForViewController:(Class)cls;
/**
 刷新对应关系相关配置
 */
- (void)reloadRelations;
/**
 获取当前显示的视图控制器

 @return 视图控制器实例
 */
- (UIViewController *)topViewController;

@end

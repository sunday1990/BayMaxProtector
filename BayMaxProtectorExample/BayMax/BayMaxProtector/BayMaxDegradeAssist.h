//
//  BayMaxDegradeAssist.h
//  BayMaxProtector
//
//  Created by ccSunday on 2018/1/19.
//  Copyright © 2018年 ccSunday. All rights reserved.
//

/*
    页面降级辅助类：保存/刷新对应关系、查找对应关系、转换完整url
 */

#import <Foundation/Foundation.h>

/*vc*/
FOUNDATION_EXPORT NSString *const BMPAssistKey_VC;
/*params*/
FOUNDATION_EXPORT NSString *const BMPAssistKey_Params;
/*url*/
FOUNDATION_EXPORT NSString *const BMPAssistKey_Url;

@protocol BayMaxDegradeAssistDelegate
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
 @return 对应关系数组
 */
- (NSArray<NSDictionary<NSString * , NSString *> *> *)correspondencesBetweenH5AndIOSParametersAtIndex:(NSInteger)index;

@end

@interface BayMaxDegradeAssist : NSObject

@property (nonatomic, strong) NSMutableArray<NSDictionary *> *relations;

@property (nonatomic, assign) id<BayMaxDegradeAssistDelegate>degradeDelegate;

/**
 获取Assist单例

 @return Assist单例
 */
+ (instancetype)Assist;

/**
 刷新对应关系
 */
- (void)reloadRelations;

/**
 获取跟Class的对应关系

 @param cls 视图控制器类
 @return 对应关系的字典，字段有控制器名称（NSString *）、参数对应关系（NSArray *）、对应的url（NSString *）

 */
- (NSDictionary *)relationForViewController:(Class)cls;

/**
 获取对应vc下的完整的url

 @param vc 试图控制器实例
 @return 完整的url
 */
- (NSString *)getCompleteUrlForViewController:(id)vc;

@end
